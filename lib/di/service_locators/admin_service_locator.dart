import 'package:printfast_rebuild/di/service_locator.dart';
import 'package:printfast_rebuild/domain/repositories/admin_repository.dart';
import 'package:printfast_rebuild/domain/repositories/storage_repository.dart';
import 'package:printfast_rebuild/domain/services/admin_service.dart';
import 'package:printfast_rebuild/infraestructure/repositories/admin_repository_impl.dart';
import 'package:printfast_rebuild/infraestructure/services/admin_service_impl.dart';

void copyShopServiceLocator() {
  getIt.registerLazySingleton<AdminService>(() => AdminServiceImpl(storageRepository: getIt<StorageRepository>()));
  getIt.registerLazySingleton<AdminRepository>(
    () => AdminRepositoryImpl(adminService: getIt<AdminService>()),
  );
}
