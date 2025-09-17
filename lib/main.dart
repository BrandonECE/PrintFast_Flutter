import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printfast_rebuild/config/routes/routes.dart';
import 'package:printfast_rebuild/di/service_locator.dart';
import 'package:printfast_rebuild/domain/entities/entities.dart';
import 'package:printfast_rebuild/domain/repositories/auth_repository.dart';
import 'package:printfast_rebuild/domain/repositories/copyshop_repository.dart';
import 'package:printfast_rebuild/domain/repositories/storage_repository.dart';
import 'package:printfast_rebuild/presentation/blocs/admin_blocs/admin_change_report_date_range_bloc/admin_change_report_date_range_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/admin_blocs/admin_home_bloc/admin_home_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/admin_blocs/admin_order_change_delivery_time_bloc/admin_order_change_delivery_time_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/admin_blocs/admin_role_selection_bloc/admin_role_selection_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/shared_blocs/cloud_storage_pdf_bloc.dart/cloud_storage_pdf_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/user_blocs/home_bloc/home_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/shared_blocs/login_bloc/login_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/shared_blocs/message_error_warning_bloc/message_error_warning_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/shared_blocs/register_bloc/register_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/user_blocs/shopping_bloc/shopping_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await UserInitializer().createCopyshopsWithSubcollectionsBatch();
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
        BlocProvider(create: (context) => CloudStoragePdfBloc( storageRepository: getIt<StorageRepository>(), ), ),
        BlocProvider(create: (context) => LoginBloc(authRepository: getIt<AuthRepository>()), ),
        BlocProvider(create: (context) => RegisterBloc(authRepository: getIt<AuthRepository>()), ),
        BlocProvider(create: (context) => AdminRoleSelectionBloc(copyshopRepository: getIt<CopyshopRepository>()), ),
        BlocProvider(create: (context) => HomeBloc(authRepository: getIt<AuthRepository>()), ),
        BlocProvider(create: (context) => AdminOrderChangeDeliveryTimeBloc()),
        BlocProvider(create: (context) => AdminChangeReportDateRangeBloc()),
        BlocProvider(create: (context) => AdminHomeBloc(authRepository: getIt<AuthRepository>())),
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
      final userDocRef = _firestore
          .collection('users')
          .doc(userEntity.registration);

      // 1) Documento principal del usuario
      await userDocRef.set({
        'email': userEntity.email,
        'name': userEntity.name,
        'phone': userEntity.phone,
        'registration': userEntity.registration,
        'isAdmin': userEntity.isAdmin,
      }, SetOptions(merge: true));

      // 2) notifications -> information { items: [] }
      final notificationsRef = userDocRef
          .collection('notifications')
          .doc('information');
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
        'specifications': <String, dynamic>{
          'pdfName': 'exampleActiveOrder.pdf',
          'hasItBeenAccepted': false,
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
          'userRegistration': userEntity.registration,
          'userName': userEntity.name,
          'orderCode': "345",
          'hasItBeenCanceledByUser': false,
        }, // mapa vacío
      }, SetOptions(merge: true));

      return;
    } catch (e) {
      // Usamos Future.error como pediste
      return Future.error("Error creando el usuario: $e");
    }
  }

  Future<void> createCopyshopsWithSubcollectionsBatch() async {
  try {
    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();

    final Map<String, Map<String, dynamic>> copyshops = {
      '24.7@gmail.com': {
        'copyShopName': '24/7',
        'lat': '25.724302',
        'long': '-100.308550',
        'queue': 0,
        'pauseReception': false,
      },
      'bibl.rectoria@gmail.com': {
        'copyShopName': 'BIBL. RECTORIA',
        'lat': '25.724547',
        'long': '-100.310398',
        'queue': 0,
        'pauseReception': false,
      },
      'facdyc@gmail.com': {
        'copyShopName': 'FACDYC',
        'lat': '25.726362',
        'long': '-100.310358',
        'queue': 0,
        'pauseReception': false,
      },
      'farq@gmail.com': {
        'copyShopName': 'FARQ',
        'lat': '25.725545',
        'long': '-100.31195',
        'queue': 0,
        'pauseReception': false,
      },
      'fime@gmail.com': {
        'copyShopName': 'FIME',
        'lat': '25.725541',
        'long': '-100.313390',
        'queue': 0,
        'pauseReception': false,
      },
      'fime.x.farq@gmail.com': {
        'copyShopName': 'FIME | x | FARQ',
        'lat': '25.725208',
        'long': '-100.312523',
        'queue': 0,
        'pauseReception': false,
      },
    };

    for (final entry in copyshops.entries) {
      final String docId = entry.key;
      final Map<String, dynamic> values = entry.value;

      final docRef = firestore.collection('copyshops').doc(docId);
      batch.set(docRef, {
        'copyShopName': values['copyShopName'],
        'lat': values['lat'],
        'long': values['long'],
        'queue': values['queue'],
        'pauseReception': values['pauseReception'],
      }, SetOptions(merge: true));

      final aordersRef = docRef.collection('aorders').doc('information');
      batch.set(aordersRef, {
        'items': <Map<String, dynamic>>[],
      }, SetOptions(merge: true));

      final hordersRef = docRef.collection('horders').doc('information');
      batch.set(hordersRef, {
        'items': <Map<String, dynamic>>[],
      }, SetOptions(merge: true));

      final notificationsRef = docRef.collection('notifications').doc('information');
      batch.set(notificationsRef, {
        'items': <Map<String, dynamic>>[],
      }, SetOptions(merge: true));
    }

    // commit batch
    await batch.commit();

    print('✅ (batch) copyshops y sub-colecciones creadas/actualizadas correctamente.');
  } catch (e) {
    return Future.error('Error creando copyshops y sub-colecciones (batch): $e');
  }
}

}
