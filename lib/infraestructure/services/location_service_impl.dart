// lib/data/services/location_service_impl.dart
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:printfast_rebuild/domain/services/location_service.dart';

class LocationServiceImpl implements LocationService {
  const LocationServiceImpl();

  @override
  Future<Position?> getCurrentLocation({Duration timeout = const Duration(seconds: 10)}) async {
    try {
      // Pedir permiso si es necesario
      final status = await Permission.locationWhenInUse.status;
      if (status != PermissionStatus.granted) {
        final requestResult = await Permission.locationWhenInUse.request();
        if (requestResult != PermissionStatus.granted) return null;
      }

      // Verificar si el servicio está activado
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      // Configuración cross-platform (Android/iOS/web)
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 10,
      );

      // Wrap en timeout para controlar la espera (timeLimit deprecado)
      final pos = await Geolocator
          .getCurrentPosition(locationSettings: locationSettings)
          .timeout(timeout);

      return pos;
    } on TimeoutException {
      // Timeout explícito
      return null;
    } catch (e) {
      // Captura general: puedes loguear
      print('LocationServiceImpl.getCurrentLocation error: $e');
      return null;
    }
  }

  @override
  Future<PermissionStatus> requestPermission() async {
    return await Permission.locationWhenInUse.request();
  }

  @override
  Future<PermissionStatus> checkPermissionStatus() async {
    return await Permission.locationWhenInUse.status;
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  @override
  Stream<Position> getLocationStream({LocationSettings? locationSettings}) {
    final settings = locationSettings ??
        const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 10,
        );
    return Geolocator.getPositionStream(locationSettings: settings);
  }
}
