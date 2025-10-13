import 'package:get_it/get_it.dart';
import 'package:printfast_rebuild/di/service_locators/auth_service_locator.dart';
import 'package:printfast_rebuild/di/service_locators/copyshop_service_locator.dart';
import 'package:printfast_rebuild/di/service_locators/location_service_locator.dart';
import 'package:printfast_rebuild/di/service_locators/storage_service_locator.dart';
import 'package:printfast_rebuild/di/service_locators/user_service_locator.dart';

final GetIt getIt = GetIt.instance;

void setupServiceLocator() {
  locationServiceLocator();
  storageServiceLocator();
  userServiceLocator();
  copyShopServiceLocator();
  authServiceLocator();
}
