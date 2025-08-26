import 'package:printfast_rebuild/domain/entities/entities.dart';

abstract class AuthService {
  Future<void> register(UserEntity userEntity);
  Future<UserEntity> signInAndGetUser({required String registration,required String password,});
  Future<void> signOut();
  Future<void> deleteCurrentAuthUser();
}
