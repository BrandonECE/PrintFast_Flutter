import 'package:printfast_rebuild/di/service_locator.dart';
import 'package:printfast_rebuild/domain/repositories/auth_repository.dart';
import 'package:printfast_rebuild/domain/repositories/user_repository.dart';
import 'package:printfast_rebuild/domain/services/auth_service.dart';
import 'package:printfast_rebuild/infraestructure/repositories/auth_repository_impl.dart';
import 'package:printfast_rebuild/infraestructure/services/auth_service_impl.dart';

void authServiceLocator(){
  getIt.registerLazySingleton<AuthService>(() => AuthServiceImpl(userRepository: getIt<UserRepository>()));
    getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(authService: getIt<AuthService>()));
}