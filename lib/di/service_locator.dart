import 'package:get_it/get_it.dart';
import 'package:printfast_rebuild/di/auth_service_locator.dart';
import 'package:printfast_rebuild/di/copyshop_service_locator.dart';
import 'package:printfast_rebuild/di/storage_service_locator.dart';
import 'package:printfast_rebuild/di/user_service_locator.dart';

final GetIt getIt = GetIt.instance;

void setupServiceLocator() {
  userServiceLocator();
  copyShopServiceLocator();
  authServiceLocator();
  storageServiceLocator();
}
