import 'package:printfast_rebuild/domain/entities/all_entities/aorder_entity.dart';
import 'package:printfast_rebuild/domain/entities/all_entities/card_payment_method_entity.dart';
import 'package:printfast_rebuild/domain/entities/all_entities/copyshop_entity.dart';
import 'package:printfast_rebuild/domain/entities/all_entities/horder_entity.dart';
import 'package:printfast_rebuild/domain/entities/all_entities/notification_entity.dart';
import 'package:printfast_rebuild/domain/entities/all_entities/user_entity.dart';
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
      return  userService.unseenNotificationsCount(registration);
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

  @override
  Future<List<CopyShopEntity>> getCopyShopsWithAorders() async {
    try {
      return await userService.getCopyShopsWithAorders();
    } catch (e) {
      return Future.error(e);
    }
  }
  
  @override
  Future<String> generateUniqueOrderCode(String copyShopEmail, {int length = 4}) async {
    try {
      return await userService.generateUniqueOrderCode(copyShopEmail, length: length);
    } catch (e) {
      return Future.error(e);
    }
  }
  
  @override
  Future<void> placeAOrder(AorderEntity aorder, {bool uploadPdf = false}) async {
    try {
      return await userService.placeAOrder(aorder, uploadPdf: uploadPdf);
    } catch (e) {
      return Future.error(e);
    }
  }
  
  @override
  Future<void> refreshCopyshopQueue(String copyshopEmail) async {
    try {
      return await userService.refreshCopyshopQueue(copyshopEmail);
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  Future<bool> isCopyshopPaused(String copyshopEmail) async {
    try {
      return await userService.isCopyshopPaused(copyshopEmail);
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  Future<void> addCardPaymentMethod(String registration, CardPaymentMethodEntity card) async {
    try {
      return await userService.addCardPaymentMethod(registration, card);
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  Future<List<CardPaymentMethodEntity>> getCards(String registration) async {
    try {
      return await userService.getCards(registration);
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  Future<void> removeCards(String registration, List<String> tokens) async {
    try {
      return await userService.removeCards(registration, tokens);
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  Future<void> setDefaultCard(String registration, String token) async {
    try {
      return await userService.setDefaultCard(registration, token);
    } catch (e) {
      return Future.error(e);
    }
  }
  
  @override
  Future<void> markAllNotificationsAsSeen(String registration) async {
    try {
      return await userService.markAllNotificationsAsSeen(registration);
    } catch (e) {
      return Future.error(e);
    }
  }

}
