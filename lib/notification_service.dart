import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings("icon_notification");


  const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: null,
      linux: null,
      macOS: null);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

Future<void> showNotification(int id, String msj) async {
  AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails("ID", "Notification_PrintFast", importance: Importance.max, priority: Priority.high, color: Colors.purple.shade400, colorized: false,styleInformation: BigTextStyleInformation(''),);
  NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails);
  await flutterLocalNotificationsPlugin.show(
      id, "ORDEN ACTIVA", msj, notificationDetails);
}

