import 'package:printfast_rebuild/domain/repositories/admin_repository.dart';
import 'package:printfast_rebuild/domain/services/admin_service.dart';

import '../../domain/entities/entities.dart';

class AdminRepositoryImpl extends AdminRepository {
  final AdminService adminService;

  AdminRepositoryImpl({required this.adminService});

  @override
  Future<CopyShopEntity> getCopyShopInfo(String adminLocationByEmail) async {
    try {
      return await adminService.getCopyShopInfo(adminLocationByEmail);
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  Stream<List<AorderEntity>> getAordersStream(String copyShopEmail) {
    try {
      return adminService.getAordersStream(copyShopEmail);
    } catch (e) {
      return Stream.error(e);
    }
  }

  @override
  Future<List<HorderEntity>> getCopyShopHOrders(String copyShopEmail) async {
    try {
      return await adminService.getCopyShopHOrders(copyShopEmail);
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  Future<List<NotificationEntity>> getCopyShopNotifications(
    String copyShopEmail,
  ) async {
    try {
      return await adminService.getCopyShopNotifications(copyShopEmail);
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  Stream<int> unseenCopyShopNotificationsCount(String copyShopEmail) {
    try {
      return adminService.unseenCopyShopNotificationsCount(copyShopEmail);
    } catch (e) {
      return Stream.error(e);
    }
  }

  @override
  Future<void> markAllCopyShopNotificationsAsSeen(String copyShopEmail) async {
    try {
      return await adminService.markAllCopyShopNotificationsAsSeen(
        copyShopEmail,
      );
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  Stream<bool> getCopyShopReceptionAvailabilityValue(String copyShopEmail) {
    try {
      return adminService.getCopyShopReceptionAvailabilityValue(copyShopEmail);
    } catch (e) {
      return Stream.error(e);
    }
  }

  @override
  Future<void> updateCopyShopReceptionAvailabilityValue(
    String copyShopEmail,
    bool copyShopReceptionAvailabilityValue,
  ) async {
    try {
      return await adminService.updateCopyShopReceptionAvailabilityValue(
        copyShopEmail,
        copyShopReceptionAvailabilityValue,
      );
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  Future<CardPaymentMethodEntity?> getUserCard(
    String userRegistration,
    String token,
  ) async {
    try {
      return await adminService.getUserCard(userRegistration, token);
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  Future<void> acceptPendingOrder(
    String userRegistration,
    String copyShopEmail,
     String orderCode,
  ) async {
    try {
      return await adminService.acceptPendingOrder( userRegistration, copyShopEmail, orderCode );
    } catch (e) {
      return Future.error(e);
    }
  }
  
  @override
  Future<void> rejectPendingOrder(String userRegistration, String copyShopEmail, String orderCode, String fileUrl) async {
    try {
      return await adminService.rejectPendingOrder( userRegistration, copyShopEmail, orderCode, fileUrl );
    } catch (e) {
      return Future.error(e);
    }
  }
  
  @override
  Future<void> markOrderAsPrinting(String userRegistration, String copyShopEmail, String orderCode) async {
 try {
      return await adminService.markOrderAsPrinting( userRegistration, copyShopEmail, orderCode);
    } catch (e) {
      return Future.error(e);
    }
  }
}
