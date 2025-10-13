

import 'package:printfast_rebuild/di/service_locator.dart';
import 'package:printfast_rebuild/domain/repositories/storage_repository.dart';
import 'package:printfast_rebuild/domain/repositories/user_repository.dart';
import 'package:printfast_rebuild/domain/services/user_service.dart';
import 'package:printfast_rebuild/infraestructure/repositories/user_repository_impl.dart';
import 'package:printfast_rebuild/infraestructure/services/user_service_impl.dart';

void userServiceLocator(){
  getIt.registerLazySingleton<UserService>(() => UserServiceImpl(storageRepository: getIt<StorageRepository>()));
  getIt.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(userService: getIt<UserService>()));
}