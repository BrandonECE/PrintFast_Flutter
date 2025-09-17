import 'package:printfast_rebuild/di/service_locator.dart';
import 'package:printfast_rebuild/domain/repositories/copyshop_repository.dart';
import 'package:printfast_rebuild/domain/services/copyshop_services.dart';
import 'package:printfast_rebuild/infraestructure/repositories/copyshop_repository_impl.dart';
import 'package:printfast_rebuild/infraestructure/services/copyshop_services_impl.dart';

void copyShopServiceLocator(){
  getIt.registerLazySingleton<CopyshopServices>(() => CopyshopServicesImpl());
  getIt.registerLazySingleton<CopyshopRepository>(() => CopyshopRepositoryImpl(copyshopServices: getIt<CopyshopServices>()));
}