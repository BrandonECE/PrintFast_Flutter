import 'package:printfast_rebuild/domain/entities/entities.dart';

abstract class UserRepository {
  Future<UserEntity> getUserInfo(String registration);
  Future<void> setNewUser(UserEntity userEntity);
  Future<bool> registrationExists(String registration);
  Future<List<HorderEntity>> getHOrders(String registration);
  Future<List<NotificationEntity>> getNotifications(String registration);
  Stream<int> unseenNotificationsCount(String registration);
  Stream<AorderEntity?> getAorderStream(String registration);
  Future<List<CopyShopEntity>> getCopyShopsWithAorders();
  Future<String> generateUniqueOrderCode(
    String copyShopEmail, {
    int length = 4,
  });
  Future<void> placeAOrder(AorderEntity aorder, {bool uploadPdf = false});
  Future<void> refreshCopyshopQueue(String copyshopEmail);
  Future<bool> isCopyshopPaused(String copyshopEmail);
  Future<void> addCardPaymentMethod(
    String registration,
    CardPaymentMethodEntity card,
  );
  Future<List<CardPaymentMethodEntity>> getCards(String registration);
  Future<void> removeCards(String registration, List<String> tokens);
  Future<void> setDefaultCard(String registration, String token);
  Future<void> markAllNotificationsAsSeen(String registration);
  Future<void> deleteUserOrder( String copyShopEmail, String registration, AorderEntity aorder, );
  Future<void> changeOrderPaymentMethod( String userRegistration, String copyShopEmail, String orderCode, String paymentMethod,);
  Future<double> getOutstandingCharges(String registration);
  Future<void> payOutstandingCharges(String registration);
}
