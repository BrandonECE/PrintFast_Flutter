// lib/domain/services/i_location_service.dart
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class LocationService {
  /// Devuelve la ubicación actual (o null si no disponible).
  /// Se puede especificar un [timeout] que envuelva la petición.
  Future<Position?> getCurrentLocation({Duration timeout = const Duration(seconds: 10)});

  /// Solicita permiso de ubicación (pide al usuario).
  Future<PermissionStatus> requestPermission();

  /// Revisa si el permiso de ubicación ya está concedido.
  Future<PermissionStatus> checkPermissionStatus();

  /// Indica si el servicio de ubicación del dispositivo está activado.
  Future<bool> isLocationServiceEnabled();

  /// Stream continuo de la ubicación del dispositivo.
  /// Puedes pasar [locationSettings] para ajustar precisión / distanceFilter, etc.
  Stream<Position> getLocationStream({LocationSettings? locationSettings});
}
