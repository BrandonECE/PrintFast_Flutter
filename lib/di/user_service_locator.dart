

import 'package:printfast_rebuild/di/service.locator.dart';
import 'package:printfast_rebuild/domain/repositories/auth_repository.dart';
import 'package:printfast_rebuild/domain/repositories/user_repository.dart';
import 'package:printfast_rebuild/domain/services/auth_service.dart';
import 'package:printfast_rebuild/domain/services/user_service.dart';
import 'package:printfast_rebuild/infraestructure/repositories/auth_repository_impl.dart';
import 'package:printfast_rebuild/infraestructure/repositories/user_repository_impl.dart';
import 'package:printfast_rebuild/infraestructure/services/auth_service_impl.dart';
import 'package:printfast_rebuild/infraestructure/services/user_service_impl.dart';

void userServiceLocator(){
  getIt.registerLazySingleton<UserService>(() => UserServiceImpl());
  getIt.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(userService: getIt<UserService>()));
  getIt.registerLazySingleton<AuthService>(() => AuthServiceImpl(userRepository: getIt<UserRepository>()));
    getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(authService: getIt<AuthService>()));
}