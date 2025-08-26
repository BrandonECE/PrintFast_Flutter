import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printfast_rebuild/config/routes/routes.dart';
import 'package:printfast_rebuild/di/service.locator.dart';
import 'package:printfast_rebuild/domain/entities/entities.dart';
import 'package:printfast_rebuild/domain/repositories/auth_repository.dart';
import 'package:printfast_rebuild/presentation/blocs/home_bloc/home_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/login_bloc/login_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/message_error_warning_bloc/message_error_warning_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/register_bloc/register_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/shopping_bloc/shopping_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // await UserInitializer().setNewUser(UserEntity(email: "email@gmail.com", name: "Max", phone: "23423423", registration: "1842345"));
  setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => MessageErrorWarningBloc()),
        BlocProvider(create: (context) => LoginBloc(authRepository: getIt<AuthRepository>())),
        BlocProvider(create: (context) => RegisterBloc(authRepository: getIt<AuthRepository>())),
        BlocProvider(create: (context) => HomeBloc(authRepository: getIt<AuthRepository>())),
        BlocProvider(create: (context) => ShoppingBloc()),
      ],
      child: MaterialApp.router(
        title: 'Material App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.purpleAccent,
            primary: Colors.purple.shade400,
          ),
        ),
        routerConfig: Routes().routes,
      ),
    );
  }
}

class UserInitializer {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initUser({
    required String registration,
    required String email,
    required String password,
    required String phone,
    required String name,
  }) async {
    final userDoc = _firestore.collection('users').doc(registration);

    // 1) Documento principal del usuario
    await userDoc.set({
      'email': email,
      'password': password,
      'phone': phone,
      'registration': registration,
      'name': name,
    }, SetOptions(merge: true));

    // 2) notifications -> documento "information" con campo items: [map,...]
    final notificationsRef = userDoc
        .collection('notifications')
        .doc('information');
    final Map<String, dynamic> firstNotification = {
      'dateTime': Timestamp.now(),
      'message': 'Bienvenido a la app!',
      'seen': false,
      'subject': 'Welcome',
    };
    await notificationsRef.set({
      'items': [firstNotification], // lista de mapas, primer elemento
    }, SetOptions(merge: true));

    // 3) horders -> documento "information" con campo items: [map,...]
    final hordersRef = userDoc.collection('horders').doc('information');
    final Map<String, dynamic> firstHorder = {
      'pdfName': 'example.pdf',
      'pages': 3,
      'format': 'Carta',
      'isColor': true,
      'price': 25,
      'place': 'FIME',
      'initDate': Timestamp.now(),
      'finalDate': Timestamp.now(),
      'name': name,
      'url': '',
    };
    await hordersRef.set({
      'items': [firstHorder], // lista de mapas, primer elemento
    }, SetOptions(merge: true));

    // 4) aorder -> dejamos como documento "information" con un único mapa (orden activa)
    final aorderRef = userDoc.collection('aorder').doc('information');
    await aorderRef.set({
      'pdfName': 'exampleActiveOrder.pdf',
      'pages': 5,
      'format': 'Oficio',
      'isColor': false,
      'price': 25,
      'place': 'FACDYC',
      'placeLat': '25.725208',
      'placeLong': '-100.312523',
      'initDate': Timestamp.now(),
      'estimatedDeliveryTime': Timestamp.now(),
      'url': '',
      'email': email,
    }, SetOptions(merge: true));

    print(
      '✅ Usuario inicializado: notifications.items[0] y horders.items[0] creados.',
    );
  }

  Future<void> createCopyshopsLocationsExact() async {
    final firestore = FirebaseFirestore.instance;
    final docRef = firestore.collection('copyshops').doc('locations');

    final Map<String, dynamic> data = {
      '24/7': {'lat': '25.724302', 'long': '-100.308550', 'queue': '4'},
      'BIBL. RECTORIA': {
        'lat': '25.724547',
        'long': '-100.310398',
        'queue': '3',
      },
      'FACDYC': {'lat': '25.726362', 'long': '-100.310358', 'queue': '2'},
      'FARQ': {'lat': '25.725545', 'long': '-100.31195', 'queue': '1'},
      'FIME': {'lat': '25.725541', 'long': '-100.313390', 'queue': '3'},
      'FIME | x | FARQ': {
        'lat': '25.725208',
        'long': '-100.312523',
        'queue': '2',
      },
    };
      await docRef.set(data, SetOptions(merge: true));

  }


    Future<void> setNewUser(UserEntity userEntity) async {
    try {
      final userDocRef = _firestore.collection('users').doc(userEntity.registration);

      // 1) Documento principal del usuario
      await userDocRef.set({
        'email': userEntity.email,
        'name': userEntity.name,
        'phone': userEntity.phone,
        'registration': userEntity.registration,
      }, SetOptions(merge: true));

      // 2) notifications -> information { items: [] }
      final notificationsRef = userDocRef.collection('notifications').doc('information');
      await notificationsRef.set({
        'items': <Map<String, dynamic>>[], // lista vacía de mapas
      }, SetOptions(merge: true));

      // 3) horders -> information { items: [] }
      final hordersRef = userDocRef.collection('horders').doc('information');
      await hordersRef.set({
        'items': <Map<String, dynamic>>[], // lista vacía de mapas
      }, SetOptions(merge: true));

      // 4) aorder -> information { specifications: {} }
      final aorderRef = userDocRef.collection('aorder').doc('information');
      await aorderRef.set({
        'specifications': <String, dynamic>{}, // mapa vacío
      }, SetOptions(merge: true));

      return;
    } catch (e) {
      // Usamos Future.error como pediste
      return Future.error("Error creando el usuario: $e");
    }
  }

}
