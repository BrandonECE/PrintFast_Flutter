import 'package:flutter/material.dart';
import 'package:print_fast/notification_service.dart';
import 'screens.dart';

///Importaciones de FireBase (Base de datos)
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();//Se inicialize todo antes de correr la App
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,//Firebase / base de datos
  );
  await initNotifications();//Notificaciones Locales
  runApp(const MyApp());//La App
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PrintFast',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.purpleAccent, primary: Colors.purple.shade400),
        useMaterial3: true,
      ),
      home: const myScreens(),
    );
  }
}
