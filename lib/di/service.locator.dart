import 'package:get_it/get_it.dart';
import 'package:printfast_rebuild/di/user_service_locator.dart';

final GetIt getIt = GetIt.instance;

void setupServiceLocator() {
  userServiceLocator();
}