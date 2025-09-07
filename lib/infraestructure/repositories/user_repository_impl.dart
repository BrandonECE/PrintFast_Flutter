import 'package:printfast_rebuild/domain/entities/aorder_entity.dart';
import 'package:printfast_rebuild/domain/entities/horder_entity.dart';
import 'package:printfast_rebuild/domain/entities/notification_entity.dart';
import 'package:printfast_rebuild/domain/entities/user_entity.dart';
import 'package:printfast_rebuild/domain/repositories/user_repository.dart';
import 'package:printfast_rebuild/domain/services/user_service.dart';

class UserRepositoryImpl extends UserRepository {
  UserService userService;
  UserRepositoryImpl({required this.userService});

  @override
  Future<UserEntity> getUserInfo(String registration) async {
    try {
      return await userService.getUserInfo(registration);
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  Future<void> setNewUser(UserEntity userEntity) async {
    try {
      return await userService.setNewUser(userEntity);
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  Future<bool> registrationExists(String registration) async {
    try {
      return await userService.registrationExists(registration);
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  Future<List<HorderEntity>> getHOrders(String registration) async {
    try {
      return await userService.getHOrders(registration);
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  Future<List<NotificationEntity>> getNotifications(String registration) async {
    try {
      return await userService.getNotifications(registration);
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  Stream<int> unseenNotificationsCount(String registration) {
    try {
      return userService.unseenNotificationsCount(registration);
    } catch (e) {
      return Stream.value(0); // devolvemos un stream con un valor por defecto
    }
  }

  @override
  Stream<AorderEntity?> getAorderStream(String registration) {
    try {
      return userService.getAorderStream(registration);
    } catch (e) {
      return Stream.error(e); // devolvemos un stream con un valor por defecto
    }
  }
}
