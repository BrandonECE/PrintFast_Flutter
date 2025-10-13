import 'package:printfast_rebuild/di/service_locator.dart';
import 'package:printfast_rebuild/domain/repositories/copyshop_repository.dart';
import 'package:printfast_rebuild/domain/services/copyshop_service.dart';
import 'package:printfast_rebuild/infraestructure/repositories/copyshop_repository_impl.dart';
import 'package:printfast_rebuild/infraestructure/services/copyshop_service_impl.dart';

void copyShopServiceLocator() {
  getIt.registerLazySingleton<CopyshopService>(() => CopyshopServiceImpl());
  getIt.registerLazySingleton<CopyshopRepository>(
    () => CopyshopRepositoryImpl(copyshopServices: getIt<CopyshopService>()),
  );
}
