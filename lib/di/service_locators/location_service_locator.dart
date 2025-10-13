import 'package:printfast_rebuild/di/service_locator.dart';
import 'package:printfast_rebuild/domain/repositories/location_repository.dart';
import 'package:printfast_rebuild/domain/services/location_service.dart';
import 'package:printfast_rebuild/infraestructure/repositories/location_repository_impl.dart';
import 'package:printfast_rebuild/infraestructure/services/location_service_impl.dart';

void locationServiceLocator(){
  getIt.registerLazySingleton<LocationService>(() => LocationServiceImpl());
  getIt.registerLazySingleton<LocationRepository>(() => LocationRepositoryImpl(locationService: getIt<LocationService>()));
}