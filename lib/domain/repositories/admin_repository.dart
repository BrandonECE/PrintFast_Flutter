import 'package:printfast_rebuild/domain/entities/entities.dart';

abstract class AdminRepository {
  Future<CopyShopEntity> getCopyShopInfo(String adminLocationByEmail);
  Stream<List<AorderEntity>> getAordersStream(String copyShopEmail);
  Future<List<HorderEntity>> getCopyShopHOrders(String copyShopEmail);
  Future<List<NotificationEntity>> getCopyShopNotifications(
    String copyShopEmail,
  );
  Stream<int> unseenCopyShopNotificationsCount(String copyShopEmail);
  Stream<bool> getCopyShopReceptionAvailabilityValue(String copyShopEmail);
  Future<void> markAllCopyShopNotificationsAsSeen(String copyShopEmail);
  Future<void> updateCopyShopReceptionAvailabilityValue( String copyShopEmail, bool copyShopReceptionAvailabilityValue, );
  Future<CardPaymentMethodEntity?> getUserCard( String userRegistration, String token, );
  Future<void> acceptPendingOrder( String userRegistration, String copyShopEmail, String orderCode, );
  Future<void> rejectPendingOrder(String userRegistration, String copyShopEmail, String orderCode, String fileUrl, );
  Future<void> markOrderAsPrinting( String userRegistration, String copyShopEmail, String orderCode, );
  Future<void> updateEstimatedDeliveryTime( String userRegistration, String copyShopEmail, String orderCode, DateTime newDeliveryTime,{ bool updateHasTheEstimatedDeliveryTimeChanged = false,} );
  Future<void> archiveAcceptedOrderCanceledByUser(AorderEntity aorder);
  Future<bool> verifyOrderByVerificationCode(String registration, String copyShopEmail, String verificationCode, );
  Future<void> completeAndArchiveOrder( AorderEntity aorder, String userRegistration, String copyShopEmail, { bool deleteStorage = true, });
}
