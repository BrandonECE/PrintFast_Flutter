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

part 'live_tracking_event.dart';
part 'live_tracking_state.dart';

class LiveTrackingBloc extends Bloc<LiveTrackingEvent, LiveTrackingState> {
  final LocationRepository locationRepository;
  final UserRepository userRepository;
  final AorderEntity activeOrder;
  final Color polylineColor;

  LiveTrackingBloc({
    required this.polylineColor,
    required this.locationRepository,
    required this.userRepository,
    required this.activeOrder,
  }) : super(LiveTrackingInitial()) {
    on<LiveTrackingMapCreated>(_onMapCreated);
    on<LiveTrackingLoadData>(_onLoadData);
    on<LiveTrackingUpdateUserLocation>(_onUpdateUserLocation);
    on<LiveTrackingFetchRoute>(_onFetchRoute);
    on<LiveTrackingSetPolylines>(_onSetPolylines);
    on<LiveTrackingSetErrorState>(_onSetErrorState);
    on<LiveTrackingRetry>(_onRetry);
    on<LiveTrackingRequestPermission>(_onRequestPermission);
    on<LiveTrackingCenterOnUser>(_onCenterOnUser);
    on<LiveTrackingCancelOrder>(_onCancelOrder);
  }

  static const String _googleDirectionsApiKey = ApiKeys.firebaseApiKey;
  static const LatLng initCoordinates = LatLng(
    25.721534676539743,
    -100.31223736703396,
  );
  static const double initZoom = 15.333834648132324;
  static const int translationAnimationDurationInMilliseconds = 195;
  static const double _mapZoom = 17.5;
  static const int _cameraPadding = 34;

  Completer<GoogleMapController>? _controllerCompleter;
  final PolylinePoints _polylinePoints = PolylinePoints(
    apiKey: _googleDirectionsApiKey,
  );

  StreamSubscription<Position>? _locationSubscription;
  bool _isClosing = false;
  LatLng? _lastUserLocation;
  Timer? _routeUpdateTimer;
  bool _hasAdjustedCamera = false; // NUEVO: para controlar si ya se ajustó la cámara

  // Getter para la ubicación de la copyshop desde activeOrder
  LatLng get _copyShopLocation {
    return LatLng(
      double.parse(activeOrder.placeLat),
      double.parse(activeOrder.placeLong),
    );
  }

  String get _copyShopName => activeOrder.copyShopName;

  void _safeAdd(LiveTrackingEvent event) {
    if (!_isClosing && !isClosed) {
      add(event);
    }
  }

  @override
  Future<void> close() async {
    _isClosing = true;
    try {
      await _locationSubscription?.cancel();
      _routeUpdateTimer?.cancel();
    } catch (e) {
      print('Error cancelando subscriptions en close: $e');
    }
    _locationSubscription = null;
    _routeUpdateTimer = null;
    _controllerCompleter = null;
    return super.close();
  }

  Future<void> _onMapCreated(
    LiveTrackingMapCreated event,
    Emitter<LiveTrackingState> emit,
  ) async {
    if (_isClosing || isClosed) return;

    _controllerCompleter = Completer<GoogleMapController>()
      ..complete(event.controller);

    try {
      final controller = await _controllerCompleter!.future;
      if (_isClosing || isClosed) return;

      // Mover cámara a posición inicial específica
      await controller.moveCamera(
        CameraUpdate.newLatLngZoom(initCoordinates, initZoom),
      );
    } catch (e) {
      print('Error posicionando cámara inicial: $e');
    }

    // Iniciar carga de datos
    _safeAdd(LiveTrackingLoadData());
  }

  Future<void> _onLoadData(
    LiveTrackingLoadData event,
    Emitter<LiveTrackingState> emit,
  ) async {
    if (_isClosing || isClosed) return;

    emit(state.copyWith(
      status: LiveTrackingStatus.loading, 
      isGettingLocation: true,
      isFetchingRoute: true,
    ));

    try {
      // Iniciar seguimiento de ubicación
      await _startLocationTracking();
      
    } catch (e) {
      if (_isClosing || isClosed) return;
      emit(
        state.copyWith(
          status: LiveTrackingStatus.failure,
          error: 'Error al cargar el seguimiento: ${e.toString()}',
          isGettingLocation: false,
          isFetchingRoute: false,
        ),
      );
    }
  }

  Future<void> _startLocationTracking() async {
    try {
      final permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        final newPermission = await Geolocator.requestPermission();
        
        if (newPermission == LocationPermission.denied ||
            newPermission == LocationPermission.deniedForever) {
          throw Exception('Permisos de ubicación denegados');
        }
      }

      // Obtener ubicación actual primero
      final currentPosition = await locationRepository.getCurrentLocation();
      if (currentPosition != null) {
        final currentLatLng = LatLng(
          currentPosition.latitude, 
          currentPosition.longitude
        );
        _safeAdd(LiveTrackingUpdateUserLocation(currentLatLng));
      }

      // Iniciar stream de ubicación
      await _locationSubscription?.cancel();
      _locationSubscription = locationRepository.getLocationStream().listen(
        (position) {
          if (_isClosing || isClosed) return;

          final newLocation = LatLng(position.latitude, position.longitude);
          
          // Solo actualizar si la ubicación cambió significativamente
          if (_shouldUpdateLocation(newLocation)) {
            _safeAdd(LiveTrackingUpdateUserLocation(newLocation));
          }
        },
        onError: (error) {
          print('Error en seguimiento de ubicación: $error');
          _safeAdd(LiveTrackingSetErrorState('Error en el GPS: $error'));
        },
      );

    } catch (e) {
      if (e.toString().contains('denied')) {
        _safeAdd(LiveTrackingSetErrorState('Permisos de ubicación denegados'));
      } else {
        rethrow;
      }
    }
  }

  bool _shouldUpdateLocation(LatLng newLocation) {
    if (_lastUserLocation == null) return true;
    
    final distance = Geolocator.distanceBetween(
      _lastUserLocation!.latitude,
      _lastUserLocation!.longitude,
      newLocation.latitude,
      newLocation.longitude,
    );
    
    return distance > 10; // Actualizar cada 10 metros
  }

  Future<void> _onUpdateUserLocation(
    LiveTrackingUpdateUserLocation event,
    Emitter<LiveTrackingState> emit,
  ) async {
    if (_isClosing || isClosed) return;

    _lastUserLocation = event.userLocation;
    
    emit(state.copyWith(
      userLocation: event.userLocation, 
      isGettingLocation: false,
      status: LiveTrackingStatus.success,
      isFetchingRoute: true, // Empezar fetching cuando hay nueva ubicación
    ));

    // Calcular ruta inicial cuando tenemos la primera ubicación
    _safeAdd(LiveTrackingFetchRoute());

    // Programar actualizaciones periódicas de la ruta
    _scheduleRouteUpdates();
  }

  void _scheduleRouteUpdates() {
    _routeUpdateTimer?.cancel();
    _routeUpdateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isClosing || isClosed) {
        timer.cancel();
        return;
      }
      _safeAdd(LiveTrackingFetchRoute());
    });
  }

  Future<void> _onFetchRoute(
    LiveTrackingFetchRoute event,
    Emitter<LiveTrackingState> emit,
  ) async {
    if (_isClosing || isClosed) return;
    if (state.userLocation == null) return;

    try {
      final origin = state.userLocation!;
      final destination = _copyShopLocation;

      final request = RoutesApiRequest(
        origin: PointLatLng(origin.latitude, origin.longitude),
        destination: PointLatLng(destination.latitude, destination.longitude),
        travelMode: TravelMode.walking,
        routingPreference: RoutingPreference.unspecified,
        polylineQuality: PolylineQuality.overview,
        units: Units.metric,
      );

      final response = await _polylinePoints
          .getRouteBetweenCoordinatesV2(request: request)
          .timeout(const Duration(seconds: 10));

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
              polylineId: const PolylineId('live_tracking_route'),
              points: routePoints,
              color: polylineColor,
              width: 6,
              startCap: Cap.roundCap,
              endCap: Cap.roundCap,
            ),
          );

          // Calcular distancia y tiempo restante
          final distanceKm = route.distanceKm ?? 0;
          final durationMinutes = route.durationMinutes ?? 0;

          final distanceMeters = (distanceKm * 1000).round();
          final remainingTime = durationMinutes.round();

          // CORREGIDO: Ajustar cámara para mostrar toda la ruta (solo la primera vez)
          if (!_hasAdjustedCamera) {
            await _adjustCameraToRoute(origin, destination, routePoints);
            _hasAdjustedCamera = true; // Marcar que ya se ajustó la cámara
          }

          // CORREGIDO: Agregar delay de 500ms antes de quitar el loading
          await Future.delayed(const Duration(milliseconds:  translationAnimationDurationInMilliseconds));

          emit(state.copyWith(
            polylines: newPolylines,
            remainingDistance: distanceMeters,
            remainingTime: remainingTime,
            isFetchingRoute: false, // Terminar fetching después del delay
          ));
        }
      } else {
        // CORREGIDO: También agregar delay en caso de no encontrar ruta
        await Future.delayed(const Duration(milliseconds:  translationAnimationDurationInMilliseconds));
        emit(state.copyWith(isFetchingRoute: false));
      }
    } catch (e) {
      print('Error calculando ruta en vivo: $e');
      // CORREGIDO: Agregar delay también en caso de error
      await Future.delayed(const Duration(milliseconds:  translationAnimationDurationInMilliseconds));
      emit(state.copyWith(isFetchingRoute: false));
    }
  }

  // CORREGIDO: Método mejorado para ajustar la cámara
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

      final bounds = _calculateRouteBounds(origin, destination, routePoints);
      
      // Usar newLatLngBounds con padding para mostrar toda la ruta
      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, _cameraPadding.toDouble()),
      );

      print('✅ Cámara ajustada para mostrar toda la ruta');
    } catch (e) {
      print('Error ajustando cámara: $e');
      // Si falla el bounds, centrar en el punto medio como fallback
      await _centerOnMidpoint(origin, destination);
    }
  }

  // FUNCIÓN ACTUALIZADA CON LOS OFFSETS ESPECÍFICOS
  LatLngBounds _calculateRouteBounds(
    LatLng origin,
    LatLng destination,
    List<LatLng> routePoints,
  ) {
    double minLat = origin.latitude;
    double maxLat = origin.latitude;
    double minLng = origin.longitude;
    double maxLng = origin.longitude;

    // Incluir origen y destino
    minLat = math.min(minLat, destination.latitude);
    maxLat = math.max(maxLat, destination.latitude);
    minLng = math.min(minLng, destination.longitude);
    maxLng = math.max(maxLng, destination.longitude);

    // Incluir todos los puntos de la ruta
    for (final point in routePoints) {
      minLat = math.min(minLat, point.latitude);
      maxLat = math.max(maxLat, point.latitude);
      minLng = math.min(minLng, point.longitude);
      maxLng = math.max(maxLng, point.longitude);
    }

    // OFFSETS ESPECÍFICOS PARA MÁS ESPACIO HACIA ARRIBA
    final latOffsetSouth = (maxLat - minLat) * 0.08;
    final latOffsetNorth = (maxLat - minLat) * -0.75; // Reducido para mejor visualización
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

      final distance = Geolocator.distanceBetween(
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
        print('📍 Cámara centrada en punto medio con zoom: $zoomLevel');
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
    if (distance > 200) return 16.0;
    return 17.0; // Zoom más cercano para distancias cortas
  }

  Future<void> _onSetPolylines(
    LiveTrackingSetPolylines event,
    Emitter<LiveTrackingState> emit,
  ) async {
    if (_isClosing || isClosed) return;
    emit(state.copyWith(polylines: event.polylines));
  }

  Future<void> _onSetErrorState(
    LiveTrackingSetErrorState event,
    Emitter<LiveTrackingState> emit,
  ) async {
    if (_isClosing || isClosed) return;

    if (event.error.contains('denied')) {
      emit(state.copyWith(
        status: LiveTrackingStatus.permissionDenied,
        error: event.error,
        isGettingLocation: false,
        isFetchingRoute: false,
      ));
    } else {
      emit(state.copyWith(
        status: LiveTrackingStatus.failure,
        error: event.error,
        isGettingLocation: false,
        isFetchingRoute: false,
      ));
    }
  }

  Future<void> _onRetry(
    LiveTrackingRetry event,
    Emitter<LiveTrackingState> emit,
  ) async {
    if (_isClosing || isClosed) return;
    
    // Resetear flag de cámara al reintentar
    _hasAdjustedCamera = false;
    
    _safeAdd(LiveTrackingLoadData());
  }

  Future<void> _onRequestPermission(
    LiveTrackingRequestPermission event,
    Emitter<LiveTrackingState> emit,
  ) async {
    if (_isClosing || isClosed) return;
    
    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        _safeAdd(LiveTrackingLoadData());
      } else {
        _safeAdd(LiveTrackingSetErrorState('Permisos de ubicación denegados'));
      }
    } catch (e) {
      _safeAdd(LiveTrackingSetErrorState('Error solicitando permisos: $e'));
    }
  }

  Future<void> _onCenterOnUser(
    LiveTrackingCenterOnUser event,
    Emitter<LiveTrackingState> emit,
  ) async {
    if (_controllerCompleter == null || state.userLocation == null) return;
    if (_isClosing || isClosed) return;

    try {
      final controller = await _controllerCompleter!.future;
      if (_isClosing || isClosed) return;

      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(state.userLocation!, _mapZoom),
      );
    } catch (e) {
      print('Error centrando en usuario: $e');
    }
  }

  Future<void> _onCancelOrder(
    LiveTrackingCancelOrder event,
    Emitter<LiveTrackingState> emit,
  ) async {
    if (_isClosing || isClosed) return;
    
    // Aquí iría la lógica para cancelar la orden
    // Por ahora solo emitimos un estado de loading y luego success
    emit(state.copyWith(isCanceling: true));
    
    try {
      // Simular cancelación
      await Future.delayed(const Duration(seconds: 2));
      
      if (_isClosing || isClosed) return;
      emit(state.copyWith(
        isCanceling: false,
        isCanceled: true,
      ));
    } catch (e) {
      if (_isClosing || isClosed) return;
      emit(state.copyWith(
        isCanceling: false,
        error: 'Error cancelando orden: $e',
      ));
    }
  }
}