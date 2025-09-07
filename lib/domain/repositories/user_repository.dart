import 'package:printfast_rebuild/domain/entities/entities.dart';

abstract class UserRepository {
  Future<UserEntity> getUserInfo(String registration);
  Future<void> setNewUser(UserEntity userEntity);
  Future<bool> registrationExists(String registration);
  Future<List<HorderEntity>> getHOrders(String registration);
  Future<List<NotificationEntity>> getNotifications(String registration);
  Stream<int> unseenNotificationsCount(String registration);
  Stream<AorderEntity?> getAorderStream(String registration);
}
