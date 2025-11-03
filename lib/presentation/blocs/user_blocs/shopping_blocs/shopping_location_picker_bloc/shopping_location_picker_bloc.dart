import 'dart:async';
import 'dart:math' as math;
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:printfast_rebuild/config/constants/api_keys.dart';
import 'package:printfast_rebuild/domain/repositories/location_repository.dart';
import 'package:printfast_rebuild/domain/repositories/user_repository.dart';
import '../../../../../domain/entities/entities.dart';

part 'shopping_location_picker_event.dart';
part 'shopping_location_picker_state.dart';

class ShoppingLocationPickerBloc
    extends Bloc<ShoppingLocationPickerEvent, ShoppingLocationPickerState> {
  final Color polylineColor;
  final LocationRepository locationRepository;
  final UserRepository userRepository;
  final double totalPrice;
  ShoppingLocationPickerBloc({
    required this.polylineColor,
    required this.locationRepository,
    required this.userRepository,
    required this.totalPrice,
  }) : super(ShoppingLocationPickerInitial()) {
    on<MapCreated>(_onMapCreated);
    on<NextLocation>(_onNextLocation);
    on<PreviousLocation>(_onPreviousLocation);
    on<SelectLocationIndex>(_onSelectLocationIndex);
    on<FetchRouteForIndex>(_onFetchRouteForIndex);
    on<SetPolylines>(_onSetPolylines);
    on<ClearPolylines>(_onClearPolylines);
    on<UpdateShopDistanceInfo>(_onUpdateShopDistanceInfo);
    on<SetLoadingState>(_onSetLoadingState);
    on<SetFetchingRouteState>(_onSetFetchingRouteState);
    on<SetErrorState>(_onSetErrorState);
    on<GetCurrentLocation>(_onGetCurrentLocation);
    on<SetCurrentLocation>(_onSetCurrentLocation);
    on<UseCurrentLocationAsOrigin>(_onUseCurrentLocationAsOrigin);
    on<CenterMapOnUser>(_onCenterMapOnUser);
    on<AdjustCameraToRoute>(_onAdjustCameraToRoute);
    on<LoadShopsData>(_onLoadShopsData);
    on<RetryLoading>(_onRetryLoading);
    on<RequestLocationPermission>(_onRequestLocationPermission);
    on<AllDataReady>(_onAllDataReady);
    on<ApplyMathematicalModel>(_onApplyMathematicalModel);
    on<ResetAll>(_onResetAll);
  }

  static const LatLng initCoordinates = LatLng(
    25.721534676539743,
    -100.31223736703396,
  );
  static const String _googleDirectionsApiKey = ApiKeys.firebaseApiKey;
  static const double initZoom = 15.333834648132324;
  static const int translationAnimationDurationInMilliseconds = 195;
  static const double _mapZoom = 17.5;
  static const int defaultVerticalOffsetPx = -150;
  static const int _cameraPadding = 34;

  // CONSTANTES DEL MODELO MATEMÁTICO
  static const double _timePerPage = 2.0; // t_p = 2 segundos por página
  static const double _weightDistance =
      0.5; // W_d = 0.5 (importancia distancia)
  static const double _weightTime =
      0.5; // W_t = 0.5 (importancia tiempo espera)

  Completer<GoogleMapController>? _controllerCompleter;
  final PolylinePoints _polylinePoints = PolylinePoints(
    apiKey:_googleDirectionsApiKey,
  );

  StreamSubscription<Position>? _locationSubscription;
  bool _hasInitialLocation = false;
  LatLng? _firstUserLocation;

  // Variables para controlar qué datos están listos
  bool _shopsLoaded = false;
  bool _locationReady = false;

  // bandera para indicar que estamos cerrando el BLoC
  bool _isClosing = false;

  // helper para añadir eventos de forma segura
  void _safeAdd(ShoppingLocationPickerEvent event) {
    if (!_isClosing && !isClosed) {
      add(event);
    }
  }

  // Método para verificar si todos los datos están listos
  void _checkIfAllDataReady(Emitter<ShoppingLocationPickerState> emit) {
    if (_shopsLoaded && _locationReady && !_isClosing && !isClosed) {
      _safeAdd(AllDataReady());
    }
  }

  @override
  Future<void> close() async {
    _isClosing = true;
    try {
      await _locationSubscription?.cancel();
    } catch (e) {
      print('Error cancelando location subscription en close: $e');
    }
    _locationSubscription = null;
    _controllerCompleter = null;
    return super.close();
  }

  // -----------------------
  // NUEVO EVENTO: ResetAll - Resetea TODO el estado
  // -----------------------
  Future<void> _onResetAll(
    ResetAll event,
    Emitter<ShoppingLocationPickerState> emit,
  ) async {
    if (_isClosing || isClosed) return;

    print('🔄 RESETEANDO COMPLETAMENTE EL SHOPPING LOCATION PICKER BLOC');

    // 1. Cancelar suscripción de ubicación
    try {
      await _locationSubscription?.cancel();
    } catch (e) {
      print('Error cancelando location subscription en reset: $e');
    }
    _locationSubscription = null;

    // 2. Resetear todas las variables internas
    _hasInitialLocation = false;
    _firstUserLocation = null;
    _shopsLoaded = false;
    _locationReady = false;

    // 3. Mover la cámara a la posición inicial si el controlador está disponible
    if (_controllerCompleter != null) {
      try {
        final controller = await _controllerCompleter!.future;
        if (!_isClosing && !isClosed) {
          await controller.moveCamera(
            CameraUpdate.newLatLngZoom(initCoordinates, initZoom),
          );
          print('📍 Cámara movida a posición inicial');
        }
      } catch (e) {
        print('Error moviendo cámara a posición inicial: $e');
      }
    }

    // 4. Emitir el estado inicial completo
    emit(ShoppingLocationPickerInitial());

    print('✅ Reset completo - Estado reiniciado a valores iniciales');

    // 5. Opcional: Volver a cargar los datos automáticamente
    _safeAdd(LoadShopsData());
  }

  // -----------------------
  // MODELO MATEMÁTICO
  // -----------------------

  /// Calcula el tiempo estimado de espera para una copyshop
  /// T_i = Σ (p_ij * t_p * c_ij) para cada pedido j en la copyshop i
  double _calculateWaitTime(CopyShopEntity shop) {
    double totalTime = 0.0;

    shop.aorders.forEach((orderId, order) {
      // Factor de color: 1 para B/N, 2 para color (según PDF)
      double colorFactor = order.isColor ? 2.0 : 1.0;

      // Tiempo para este pedido = páginas * tiempoPorPágina * factorColor
      totalTime += order.pages * _timePerPage * colorFactor;
    });

    return totalTime; // en segundos
  }

  /// Calcula el tiempo estimado mínimo de entrega en minutos
  /// Tiempo total = tiempo de espera + tiempo de viaje
  int _calculateEstimatedDeliveryTime(
    CopyShopEntity shop,
    double waitTimeSeconds,
    double travelTimeSeconds,
  ) {
    // Convertir todo a minutos
    double waitTimeMinutes = waitTimeSeconds / 60;
    double travelTimeMinutes = travelTimeSeconds / 60;

    // Tiempo total estimado en minutos (redondeado hacia arriba)
    double totalTimeMinutes = waitTimeMinutes + travelTimeMinutes;
    return totalTimeMinutes.ceil();
  }

  /// Calcula la puntuación S_i para una copyshop según el PDF
  /// S_i = W_d * (d_i / d_max) + W_t * (T_i / T_max)
  double _calculateShopScore(
    CopyShopEntity shop,
    double distance,
    double waitTime,
    double maxDistance,
    double maxWaitTime,
  ) {
    // Normalizar distancia y tiempo (entre 0 y 1)
    double normalizedDistance = maxDistance > 0 ? distance / maxDistance : 0;
    double normalizedWaitTime = maxWaitTime > 0 ? waitTime / maxWaitTime : 0;

    // Calcular puntuación según fórmula del PDF
    return (_weightDistance * normalizedDistance) +
        (_weightTime * normalizedWaitTime);
  }

  /// Aplica el modelo matemático para ordenar las copyshops de mejor a peor
  List<CopyShopEntity> _applyMathematicalModel(
    List<CopyShopEntity> shops,
    LatLng userLocation,
  ) {
    if (shops.isEmpty) return shops;

    // 1. Filtrar shops que tienen pauseReception en true
    List<CopyShopEntity> availableShops = shops
        .where((shop) => !shop.pauseReception)
        .toList();

    if (availableShops.isEmpty) {
      return availableShops;
    }

    // 2. Calcular distancias y tiempos de espera para cada shop disponible
    List<double> distances = [];
    List<double> waitTimes = [];

    for (var shop in availableShops) {
      // Calcular distancia en metros
      double distance = Geolocator.distanceBetween(
        userLocation.latitude,
        userLocation.longitude,
        shop.latDouble,
        shop.longDouble,
      );
      distances.add(distance);

      // Calcular tiempo de espera según modelo matemático
      double waitTime = _calculateWaitTime(shop);
      waitTimes.add(waitTime);
    }

    // 3. Encontrar valores máximos para normalización
    double maxDistance = distances.reduce(math.max);
    double maxWaitTime = waitTimes.reduce(math.max);

    // 4. Calcular puntuación para cada shop y crear lista con scores
    List<Map<String, dynamic>> shopScores = [];

    for (int i = 0; i < availableShops.length; i++) {
      double score = _calculateShopScore(
        availableShops[i],
        distances[i],
        waitTimes[i],
        maxDistance,
        maxWaitTime,
      );

      // Calcular tiempo estimado de entrega mínimo
      int estimatedDeliveryTime = _calculateEstimatedDeliveryTime(
        availableShops[i],
        waitTimes[i],
        distances[i] /
            1.39, // Asumir velocidad promedio de 5 km/h (1.39 m/s) para tiempo de viaje
      );

      shopScores.add({
        'shop': availableShops[i],
        'score': score,
        'distance': distances[i],
        'waitTime': waitTimes[i],
        'estimatedDeliveryTime': estimatedDeliveryTime,
      });
    }

    // 5. Ordenar por score (menor score = mejor, según PDF: arg min S_i)
    shopScores.sort((a, b) => a['score'].compareTo(b['score']));

    // 6. Reconstruir lista de shops con nueva ordenación y datos actualizados
    List<CopyShopEntity> sortedShops = [];

    for (int i = 0; i < shopScores.length; i++) {
      var shopData = shopScores[i];
      CopyShopEntity originalShop = shopData['shop'];

      // Crear DateTime estimado sumando minutos a la hora actual
      DateTime? estimatedDeliveryDateTime = DateTime.now().add(
        Duration(minutes: shopData['estimatedDeliveryTime']),
      );

      // Actualizar shop con distancia, tiempo de espera, tiempo estimado y si es recomendada
      CopyShopEntity updatedShop = originalShop.copyWith(
        price: totalPrice,
        distance: shopData['distance'],
        duration: shopData['waitTime'].round(), // convertir a segundos enteros
        estimatedDeliveryTime: estimatedDeliveryDateTime,
        isRecommended: i == 0, // La primera es la recomendada
      );

      sortedShops.add(updatedShop);
    }

    return sortedShops;
  }

  // -----------------------
  // EVENTO: Aplicar Modelo Matemático
  // -----------------------
  Future<void> _onApplyMathematicalModel(
    ApplyMathematicalModel event,
    Emitter<ShoppingLocationPickerState> emit,
  ) async {
    if (_isClosing || isClosed) return;
    if (_firstUserLocation == null) return;

    try {
      // Aplicar modelo matemático para ordenar las copyshops
      List<CopyShopEntity> optimizedShops = _applyMathematicalModel(
        state.shops,
        _firstUserLocation!,
      );

      emit(
        state.copyWith(
          shops: optimizedShops,
          index: 0, // Resetear al índice 0 (mejor opción)
        ),
      );

      // Calcular ruta para la mejor opción
      if (optimizedShops.isNotEmpty) {
        _safeAdd(FetchRouteForIndex(0, origin: _firstUserLocation));
      }
    } catch (e) {
      print('Error aplicando modelo matemático: $e');
      // En caso de error, mantener el orden original
      _safeAdd(FetchRouteForIndex(state.index, origin: _firstUserLocation));
    }
  }

  // -----------------------
  // NUEVO EVENTO: Todos los datos listos (MODIFICADO)
  // -----------------------
  Future<void> _onAllDataReady(
    AllDataReady event,
    Emitter<ShoppingLocationPickerState> emit,
  ) async {
    if (_isClosing || isClosed) return;

    // Primero aplicar el modelo matemático antes de marcar como success
    if (_firstUserLocation != null && state.shops.isNotEmpty) {
      _safeAdd(ApplyMathematicalModel());
    }

    emit(
      state.copyWith(status: ShoppingLocationPickerStatus.success, error: null),
    );
  }

  // -----------------------
  // LOAD SHOPS (MODIFICADO para usar datos reales)
  // -----------------------
  Future<void> _onLoadShopsData(
    LoadShopsData event,
    Emitter<ShoppingLocationPickerState> emit,
  ) async {
    if (_isClosing || isClosed) return;

    emit(state.copyWith(status: ShoppingLocationPickerStatus.loading));

    try {
      // Obtener datos reales de Firestore
      final List<CopyShopEntity> loadedShops = await userRepository
          .getCopyShopsWithAorders();
      print("LOADED COPYSHOP INFORMATION HERE: $loadedShops");

      if (_isClosing || isClosed) return;

      _shopsLoaded = true;

      // Si no hay papelerías, ir directamente a empty
      if (loadedShops.isEmpty) {
        emit(
          state.copyWith(
            shops: loadedShops,
            status: ShoppingLocationPickerStatus.empty,
          ),
        );
        return;
      }

      emit(state.copyWith(shops: loadedShops));

      // Verificar si ya podemos pasar a success
      _checkIfAllDataReady(emit);

      // Si no teníamos la ubicación inicial, intentamos obtenerla
      if (!_hasInitialLocation) {
        _safeAdd(GetCurrentLocation());
      } else if (_locationReady) {
        // Si ya teníamos ubicación, verificar de nuevo
        _checkIfAllDataReady(emit);
      }
    } catch (e) {
      if (_isClosing || isClosed) return;
      emit(
        state.copyWith(
          status: ShoppingLocationPickerStatus.failure,
          error: 'Error al cargar las papelerías: ${e.toString()}',
        ),
      );
    }
  }

  // -----------------------
  // GET CURRENT LOCATION (MODIFICADO para triggerear modelo matemático)
  // -----------------------
  Future<void> _onGetCurrentLocation(
    GetCurrentLocation event,
    Emitter<ShoppingLocationPickerState> emit,
  ) async {
    if (_isClosing || isClosed) return;

    emit(state.copyWith(isGettingLocation: true, error: null));

    try {
      final permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final position = await locationRepository.getCurrentLocation();
        if (_isClosing || isClosed) return;

        if (position != null) {
          final currentLatLng = LatLng(position.latitude, position.longitude);
          _firstUserLocation ??= currentLatLng;
          _safeAdd(SetCurrentLocation(currentLatLng));

          if (!_hasInitialLocation) {
            await _startLocationTracking();
            _hasInitialLocation = true;
          }

          _locationReady = true;
          _checkIfAllDataReady(emit);
        } else {
          _safeAdd(SetErrorState('No se pudo obtener la ubicación actual.'));
        }
      } else if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (_isClosing || isClosed) return;

        final newPermission = await Geolocator.requestPermission();

        if (newPermission == LocationPermission.whileInUse ||
            newPermission == LocationPermission.always) {
          final position = await locationRepository.getCurrentLocation();
          if (_isClosing || isClosed) return;

          if (position != null) {
            final currentLatLng = LatLng(position.latitude, position.longitude);
            _firstUserLocation ??= currentLatLng;
            _safeAdd(SetCurrentLocation(currentLatLng));

            if (!_hasInitialLocation) {
              await _startLocationTracking();
              _hasInitialLocation = true;
            }

            _locationReady = true;
            _checkIfAllDataReady(emit);
          }
        } else {
          if (_isClosing || isClosed) return;
          emit(
            state.copyWith(
              isGettingLocation: false,
              status: ShoppingLocationPickerStatus.permissionDenied,
            ),
          );
          return;
        }
      }
    } catch (e) {
      _safeAdd(SetErrorState('Error obteniendo ubicación: ${e.toString()}'));
    } finally {
      if (!_isClosing && !isClosed) {
        emit(state.copyWith(isGettingLocation: false));
      }
    }
  }

  // -----------------------
  // SET CURRENT LOCATION (MODIFICADO)
  // -----------------------
  Future<void> _onSetCurrentLocation(
    SetCurrentLocation event,
    Emitter<ShoppingLocationPickerState> emit,
  ) async {
    if (_isClosing || isClosed) return;

    if (!_hasInitialLocation || state.currentLocation == null) {
      emit(state.copyWith(currentLocation: event.currentLocation));
    } else if (_locationsAreDifferent(
      state.currentLocation!,
      event.currentLocation,
    )) {
      emit(state.copyWith(currentLocation: event.currentLocation));
    }

    // Marcar ubicación como lista y verificar
    _locationReady = true;
    _checkIfAllDataReady(emit);

    // Si ya tenemos shops cargados, re-aplicar el modelo matemático
    if (_shopsLoaded && state.shops.isNotEmpty) {
      _safeAdd(ApplyMathematicalModel());
    }
  }

  // -----------------------
  // RETRY (MODIFICADO)
  // -----------------------
  Future<void> _onRetryLoading(
    RetryLoading event,
    Emitter<ShoppingLocationPickerState> emit,
  ) async {
    if (_isClosing || isClosed) return;

    // Resetear flags
    _shopsLoaded = false;
    _locationReady = false;
    _hasInitialLocation = false;
    _firstUserLocation = null;

    _safeAdd(LoadShopsData());
  }

  // -----------------------
  // REQUEST PERMISSION (MODIFICADO)
  // -----------------------
  Future<void> _onRequestLocationPermission(
    RequestLocationPermission event,
    Emitter<ShoppingLocationPickerState> emit,
  ) async {
    if (_isClosing || isClosed) return;

    try {
      _safeAdd(GetCurrentLocation());
    } catch (e) {
      if (_isClosing || isClosed) return;
      emit(
        state.copyWith(
          status: ShoppingLocationPickerStatus.failure,
          error: 'Error solicitando permisos: ${e.toString()}',
        ),
      );
    }
  }

  // -----------------------
  // MAP CREATED (MODIFICADO)
  // -----------------------
  Future<void> _onMapCreated(
    MapCreated event,
    Emitter<ShoppingLocationPickerState> emit,
  ) async {
    if (_isClosing || isClosed) return;

    _controllerCompleter = Completer<GoogleMapController>()
      ..complete(event.controller);

    try {
      final controller = await _controllerCompleter!.future;
      if (_isClosing || isClosed) return;

      await controller.moveCamera(
        CameraUpdate.newLatLngZoom(initCoordinates, initZoom),
      );
    } catch (e) {
      print('Error posicionando cámara inicial: $e');
    }

    // Iniciar carga de datos
    _safeAdd(LoadShopsData());
  }

  // -----------------------
  // USE CURRENT LOCATION AS ORIGIN (MODIFICADO)
  // -----------------------
  Future<void> _onUseCurrentLocationAsOrigin(
    UseCurrentLocationAsOrigin event,
    Emitter<ShoppingLocationPickerState> emit,
  ) async {
    if (_isClosing || isClosed) return;
    if (state.status != ShoppingLocationPickerStatus.success) return;

    if (_firstUserLocation != null) {
      _safeAdd(FetchRouteForIndex(event.index, origin: _firstUserLocation));
    } else if (state.currentLocation != null) {
      _safeAdd(FetchRouteForIndex(event.index, origin: state.currentLocation));
    }
  }

  // -----------------------
  // NEXT/PREVIOUS/SELECT LOCATION (MODIFICADOS)
  // -----------------------
  Future<void> _onNextLocation(
    NextLocation event,
    Emitter<ShoppingLocationPickerState> emit,
  ) async {
    if (_isClosing || isClosed) return;
    if (state.shops.isEmpty) return;
    if (state.status != ShoppingLocationPickerStatus.success) return;

    final next = (state.index + 1).clamp(0, state.shops.length - 1);
    if (next == state.index) return;

    emit(state.copyWith(isFetchingRoute: true, error: null));
    await Future.delayed(const Duration(milliseconds: 50));
    if (_isClosing || isClosed) return;
    emit(state.copyWith(index: next, isFetchingRoute: true, error: null));

    if (_firstUserLocation != null) {
      _safeAdd(FetchRouteForIndex(next, origin: _firstUserLocation));
    } else if (state.currentLocation != null) {
      _safeAdd(FetchRouteForIndex(next, origin: state.currentLocation));
    } else {
      _safeAdd(FetchRouteForIndex(next));
    }
  }

  Future<void> _onPreviousLocation(
    PreviousLocation event,
    Emitter<ShoppingLocationPickerState> emit,
  ) async {
    if (_isClosing || isClosed) return;
    if (state.shops.isEmpty) return;
    if (state.status != ShoppingLocationPickerStatus.success) return;

    final prev = (state.index - 1).clamp(0, state.shops.length - 1);
    if (prev == state.index) return;

    emit(state.copyWith(isFetchingRoute: true, error: null));
    await Future.delayed(const Duration(milliseconds: 50));
    if (_isClosing || isClosed) return;
    emit(state.copyWith(index: prev, isFetchingRoute: true, error: null));

    if (_firstUserLocation != null) {
      _safeAdd(FetchRouteForIndex(prev, origin: _firstUserLocation));
    } else if (state.currentLocation != null) {
      _safeAdd(FetchRouteForIndex(prev, origin: state.currentLocation));
    } else {
      _safeAdd(FetchRouteForIndex(prev));
    }
  }

  Future<void> _onSelectLocationIndex(
    SelectLocationIndex event,
    Emitter<ShoppingLocationPickerState> emit,
  ) async {
    if (_isClosing || isClosed) return;
    if (event.index < 0 || event.index >= state.shops.length) return;
    if (event.index == state.index) return;
    if (state.status != ShoppingLocationPickerStatus.success) return;

    emit(state.copyWith(isFetchingRoute: true, error: null));
    await Future.delayed(const Duration(milliseconds: 50));
    if (_isClosing || isClosed) return;
    emit(
      state.copyWith(index: event.index, isFetchingRoute: true, error: null),
    );

    if (_firstUserLocation != null) {
      _safeAdd(FetchRouteForIndex(event.index, origin: _firstUserLocation));
    } else if (state.currentLocation != null) {
      _safeAdd(FetchRouteForIndex(event.index, origin: state.currentLocation));
    } else {
      _safeAdd(FetchRouteForIndex(event.index));
    }
  }

  // -----------------------
  // MÉTODOS DE RUTAS (CON VERIFICACIÓN DE ESTADO SUCCESS)
  // -----------------------
  Future<void> _onFetchRouteForIndex(
    FetchRouteForIndex event,
    Emitter<ShoppingLocationPickerState> emit,
  ) async {
    if (_isClosing || isClosed) return;
    if (state.status != ShoppingLocationPickerStatus.success) return;

    emit(state.copyWith(isFetchingRoute: true));
    await _fetchRouteForIndex(event.index, origin: event.origin);
  }

  Future<void> _fetchRouteForIndex(int index, {LatLng? origin}) async {
    if (_isClosing || isClosed) return;
    if (state.status != ShoppingLocationPickerStatus.success) return;

    if (state.shops.isEmpty || index < 0 || index >= state.shops.length) {
      _safeAdd(ClearPolylines());
      return;
    }

    final dest = state.shops[index];
    final usedOrigin =
        origin ??
        _firstUserLocation ??
        state.currentLocation ??
        initCoordinates;

    if (dest.latDouble == 0.0 || dest.longDouble == 0.0) {
      _safeAdd(ClearPolylines());
      return;
    }

    try {
      _safeAdd(ClearPolylines());

      final request = RoutesApiRequest(
        origin: PointLatLng(usedOrigin.latitude, usedOrigin.longitude),
        destination: PointLatLng(dest.latDouble, dest.longDouble),
        travelMode: TravelMode.walking, // walking aquí
        routingPreference: RoutingPreference.unspecified, // <- importante
        polylineQuality: PolylineQuality.overview,
        units: Units.metric,
      );

      final response = await _polylinePoints
          .getRouteBetweenCoordinatesV2(request: request)
          .timeout(const Duration(seconds: 15));

      final Set<Polyline> newPolylines = {};
      List<LatLng> routePoints = [];

      if (response.routes.isNotEmpty) {
        final route = response.routes.first;
        routePoints =
            route.polylinePoints
                ?.map((p) => LatLng(p.latitude, p.longitude))
                .toList() ??
            [];

        if (routePoints.isNotEmpty) {
          newPolylines.add(
            Polyline(
              polylineId: PolylineId('route_$index'),
              points: routePoints,
              color: polylineColor,
              width: 6,
              startCap: Cap.roundCap,
              endCap: Cap.roundCap,
            ),
          );

          final distanceKm = route.distanceKm;
          final durationMinutes = route.durationMinutes;

          if (distanceKm != null && durationMinutes != null) {
            final distanceMeters = distanceKm * 1000;
            final durationInt = durationMinutes.round();

            _safeAdd(
              UpdateShopDistanceInfo(index, distanceMeters, durationInt),
            );
          }

          final destination = LatLng(dest.latDouble, dest.longDouble);
          _safeAdd(AdjustCameraToRoute(usedOrigin, destination, routePoints));
        }
      }

      if (newPolylines.isNotEmpty) {
        _safeAdd(SetPolylines(newPolylines));
      } else {
        _safeAdd(ClearPolylines());
      }
    } catch (e) {
      print('Error fetching route V2: $e');
      _safeAdd(ClearPolylines());

      if (e is TimeoutException) {
        _safeAdd(
          SetErrorState('Tiempo de espera agotado. Verifica tu conexión.'),
        );
      } else {
        _safeAdd(SetErrorState('Error al calcular la ruta: ${e.toString()}'));
      }
    } finally {
      _safeAdd(SetFetchingRouteState(false));
    }
  }

  // -----------------------
  // MÉTODOS DE SEGUIMIENTO DE UBICACIÓN
  // -----------------------
  Future<void> _startLocationTracking() async {
    try {
      await _locationSubscription?.cancel();
    } catch (e) {
      print('Error cancelando suscripción previa en startLocationTracking: $e');
    }
    _locationSubscription = null;

    if (_isClosing || isClosed) return;

    _locationSubscription = locationRepository.getLocationStream().listen(
      (position) {
        if (_isClosing || isClosed) return;

        final newLocation = LatLng(position.latitude, position.longitude);
        _firstUserLocation ??= newLocation;

        if (_shouldUpdateLocation(newLocation)) {
          _safeAdd(SetCurrentLocation(newLocation));
        }

        _hasInitialLocation = true;
      },
      onError: (error) {
        print('Error en seguimiento de ubicación: $error');
      },
    );
  }

  bool _shouldUpdateLocation(LatLng newLocation) {
    if (_firstUserLocation == null) return true;
    final distance = Geolocator.distanceBetween(
      _firstUserLocation!.latitude,
      _firstUserLocation!.longitude,
      newLocation.latitude,
      newLocation.longitude,
    );
    return distance > 10;
  }

  bool _locationsAreDifferent(LatLng loc1, LatLng loc2) {
    return loc1.latitude != loc2.latitude || loc1.longitude != loc2.longitude;
  }

  // -----------------------
  // MÉTODOS DE CÁMARA Y RUTAS (EXISTENTES)
  // -----------------------
  Future<void> _adjustCameraToRoute(
    LatLng origin,
    LatLng destination,
    List<LatLng> routePoints,
  ) async {
    if (_controllerCompleter == null) return;
    if (_isClosing || isClosed) return;

    try {
      final controller = await _controllerCompleter!.future;
      if (_isClosing || isClosed) return;

      final LatLngBounds bounds = _calculateRouteBounds(
        origin,
        destination,
        routePoints,
      );

      if (_hasInitialLocation && !_isClosing && !isClosed) {
        await controller.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, _cameraPadding.toDouble()),
        );
      }
    } catch (e) {
      print('Error ajustando cámara a la ruta: $e');
      if (_hasInitialLocation && !_isClosing && !isClosed) {
        await _centerOnMidpoint(origin, destination);
      }
    }
  }

  LatLngBounds _calculateRouteBounds(
    LatLng origin,
    LatLng destination,
    List<LatLng> routePoints,
  ) {
    double minLat = origin.latitude;
    double maxLat = origin.latitude;
    double minLng = origin.longitude;
    double maxLng = origin.longitude;

    minLat = math.min(minLat, destination.latitude);
    maxLat = math.max(maxLat, destination.latitude);
    minLng = math.min(minLng, destination.longitude);
    maxLng = math.max(maxLng, destination.longitude);

    for (final point in routePoints) {
      minLat = math.min(minLat, point.latitude);
      maxLat = math.max(maxLat, point.latitude);
      minLng = math.min(minLng, point.longitude);
      maxLng = math.max(maxLng, point.longitude);
    }

    final latOffsetSouth = (maxLat - minLat) * 0.08;
    final latOffsetNorth = (maxLat - minLat) * -0.75;
    final lngOffset = (maxLng - minLng) * 0.1;

    return LatLngBounds(
      southwest: LatLng(minLat - latOffsetSouth, minLng - lngOffset),
      northeast: LatLng(maxLat + latOffsetNorth, maxLng + lngOffset),
    );
  }

  Future<void> _centerOnMidpoint(LatLng origin, LatLng destination) async {
    if (_controllerCompleter == null) return;
    if (_isClosing || isClosed) return;

    try {
      final controller = await _controllerCompleter!.future;
      if (_isClosing || isClosed) return;

      final midpoint = LatLng(
        (origin.latitude + destination.latitude) / 2,
        (origin.longitude + destination.longitude) / 2,
      );

      final distance = await Geolocator.distanceBetween(
        origin.latitude,
        origin.longitude,
        destination.latitude,
        destination.longitude,
      );

      double zoomLevel = _calculateOptimalZoom(distance);

      if (!_isClosing && !isClosed) {
        await controller.animateCamera(
          CameraUpdate.newLatLngZoom(midpoint, zoomLevel),
        );
      }
    } catch (e) {
      print('Error en centerOnMidpoint: $e');
    }
  }

  double _calculateOptimalZoom(double distance) {
    if (distance > 5000) return 12.0;
    if (distance > 2000) return 13.0;
    if (distance > 1000) return 14.0;
    if (distance > 500) return 15.0;
    return 16.0;
  }

  Future<void> _onCenterMapOnUser(
    CenterMapOnUser event,
    Emitter<ShoppingLocationPickerState> emit,
  ) async {
    if (_controllerCompleter == null || _firstUserLocation == null) return;
    if (_isClosing || isClosed) return;

    try {
      final controller = await _controllerCompleter!.future;
      if (_isClosing || isClosed) return;

      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(_firstUserLocation!, _mapZoom),
      );
    } catch (e) {
      print('Error centrando mapa en usuario: $e');
    }
  }

  Future<void> _onAdjustCameraToRoute(
    AdjustCameraToRoute event,
    Emitter<ShoppingLocationPickerState> emit,
  ) async {
    if (_isClosing || isClosed) return;
    await _adjustCameraToRoute(
      event.origin,
      event.destination,
      event.routePoints,
    );
  }

  // -----------------------
  // MÉTODOS RESTANTES (SIN CAMBIOS)
  // -----------------------
  Future<void> _onSetPolylines(
    SetPolylines event,
    Emitter<ShoppingLocationPickerState> emit,
  ) async {
    if (_isClosing || isClosed) return;
    emit(state.copyWith(polylines: event.polylines));
  }

  Future<void> _onClearPolylines(
    ClearPolylines event,
    Emitter<ShoppingLocationPickerState> emit,
  ) async {
    if (_isClosing || isClosed) return;
    emit(state.copyWith(polylines: {}));
  }

  Future<void> _onUpdateShopDistanceInfo(
    UpdateShopDistanceInfo event,
    Emitter<ShoppingLocationPickerState> emit,
  ) async {
    if (_isClosing || isClosed) return;

    final updatedShops = List<CopyShopEntity>.from(state.shops);
    if (event.index < updatedShops.length) {
      updatedShops[event.index] = updatedShops[event.index].copyWith(
        distance: event.distance,
        duration: event.duration,
      );
    }
    emit(state.copyWith(shops: updatedShops));
  }

  Future<void> _onSetLoadingState(
    SetLoadingState event,
    Emitter<ShoppingLocationPickerState> emit,
  ) async {
    if (_isClosing || isClosed) return;
    emit(state.copyWith(loading: event.isLoading));
  }

  Future<void> _onSetFetchingRouteState(
    SetFetchingRouteState event,
    Emitter<ShoppingLocationPickerState> emit,
  ) async {
    if (_isClosing || isClosed) return;
    emit(state.copyWith(isFetchingRoute: event.isFetching));
  }

  Future<void> _onSetErrorState(
    SetErrorState event,
    Emitter<ShoppingLocationPickerState> emit,
  ) async {
    if (_isClosing || isClosed) return;

    emit(state.copyWith(error: event.error, isFetchingRoute: false));

    if (event.error.isNotEmpty) {
      await Future.delayed(const Duration(seconds: 3));
      if (!_isClosing && !isClosed) {
        emit(state.copyWith(error: null));
      }
    }
  }
}
