// lib/domain/repositories/i_location_repository.dart
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class LocationRepository {
  Future<Position?> getCurrentLocation({Duration timeout = const Duration(seconds: 10)});
  Future<PermissionStatus> requestPermission();
  Future<PermissionStatus> checkPermissionStatus();
  Future<bool> isLocationServiceEnabled();
  Stream<Position> getLocationStream({LocationSettings? locationSettings});
}
