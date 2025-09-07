import 'package:printfast_rebuild/di/service.locator.dart';
import 'package:printfast_rebuild/domain/repositories/storage_repository.dart';
import 'package:printfast_rebuild/domain/services/storage_service.dart';
import 'package:printfast_rebuild/infraestructure/repositories/storage_repository_impl.dart';
import 'package:printfast_rebuild/infraestructure/services/storage_service_impl.dart';

void storageServiceLocator(){
  getIt.registerLazySingleton<StorageService>(() => StorageServiceImpl());
  getIt.registerLazySingleton<StorageRepository>(() => StorageRepositoryImpl(storageService: getIt<StorageService>()));
}