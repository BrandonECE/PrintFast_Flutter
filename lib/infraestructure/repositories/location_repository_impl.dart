// lib/data/repositories/location_repository_impl.dart
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:printfast_rebuild/domain/repositories/location_repository.dart';
import 'package:printfast_rebuild/domain/services/location_service.dart';


class LocationRepositoryImpl implements LocationRepository {
  final LocationService _locationService;

  LocationRepositoryImpl({required LocationService locationService}) : _locationService = locationService;

  @override
  Future<Position?> getCurrentLocation({Duration timeout = const Duration(seconds: 10)}) {
    return _locationService.getCurrentLocation(timeout: timeout);
  }

  @override
  Future<PermissionStatus> requestPermission() {
    return _locationService.requestPermission();
  }

  @override
  Future<PermissionStatus> checkPermissionStatus() {
    return _locationService.checkPermissionStatus();
  }

  @override
  Future<bool> isLocationServiceEnabled() {
    return _locationService.isLocationServiceEnabled();
  }

  @override
  Stream<Position> getLocationStream({LocationSettings? locationSettings}) {
    return _locationService.getLocationStream(locationSettings: locationSettings);
  }
}
