
import 'package:printfast_rebuild/domain/entities/all_entities/user_entity.dart';
import 'package:printfast_rebuild/domain/repositories/auth_repository.dart';
import 'package:printfast_rebuild/domain/services/auth_service.dart';

class AuthRepositoryImpl extends AuthRepository{
  AuthService authService;
  AuthRepositoryImpl({required this.authService});
  
  @override
  Future<void> deleteCurrentAuthUser() async {
    try {
        return await authService.deleteCurrentAuthUser();
      } catch (e) {
        return Future.error(e);
    }
  }

  @override
  Future<void> register(UserEntity userEntity) async  {
    try {
        return await authService.register(userEntity);
      } catch (e) {
        return Future.error(e);
    }
  }


  @override
  Future<UserEntity> signInAndGetUser({required String registration, required String password}) async  {
    try {
        return await authService.signInAndGetUser(registration: registration, password: password);
      } catch (e) {
        return Future.error(e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
        return await authService.signOut();
      } catch (e) {
        return Future.error(e);
    }
  }
}