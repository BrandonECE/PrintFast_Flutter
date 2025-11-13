import 'package:flutter/material.dart';

class NavigatorKey {
  NavigatorKey._();
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
}
