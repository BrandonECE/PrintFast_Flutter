import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:printfast_rebuild/config/constants/api_keys.dart';
import 'package:printfast_rebuild/config/routes/routes.dart';
import 'package:printfast_rebuild/di/service_locator.dart';
import 'package:printfast_rebuild/domain/entities/entities.dart';
import 'package:printfast_rebuild/domain/repositories/auth_repository.dart';
import 'package:printfast_rebuild/domain/repositories/copyshop_repository.dart';
import 'package:printfast_rebuild/domain/repositories/storage_repository.dart';
import 'package:printfast_rebuild/domain/repositories/user_repository.dart';
import 'package:printfast_rebuild/presentation/blocs/admin_blocs/admin_change_report_date_range_bloc/admin_change_report_date_range_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/admin_blocs/admin_home_bloc/admin_home_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/admin_blocs/admin_order_change_delivery_time_bloc/admin_order_change_delivery_time_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/admin_blocs/admin_role_selection_bloc/admin_role_selection_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/shared_blocs/cloud_storage_pdf_bloc.dart/cloud_storage_pdf_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/user_blocs/home_bloc/home_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/shared_blocs/login_bloc/login_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/shared_blocs/message_error_warning_bloc/message_error_warning_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/shared_blocs/register_bloc/register_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/user_blocs/shopping_blocs/shopping_bloc/shopping_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = ApiKeys.stripePublishApiKey;
  await Stripe.instance.applySettings();
  await Firebase.initializeApp();
  // await UserInitializer().addThreeExampleHorders(registration: '1974238');
  setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final Color themeColor = Colors.purple.shade400;
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => MessageErrorWarningBloc()),
        BlocProvider( create: (context) => CloudStoragePdfBloc( storageRepository: getIt<StorageRepository>(), ), ),
        BlocProvider( create: (context) => LoginBloc(authRepository: getIt<AuthRepository>()), ),
        BlocProvider( create: (context) => RegisterBloc(authRepository: getIt<AuthRepository>()), ),
        BlocProvider( create: (context) => AdminRoleSelectionBloc( copyshopRepository: getIt<CopyshopRepository>(), ), ),
        BlocProvider( create: (context) => HomeBloc(authRepository: getIt<AuthRepository>(), userRepository: getIt<UserRepository>(), )
        // ..add(HomeUpdateUserEntityEvent(userEntity: UserEntity.defaultValues))
         ),
        BlocProvider(create: (context) => AdminOrderChangeDeliveryTimeBloc()),
        BlocProvider(create: (context) => AdminChangeReportDateRangeBloc()),
        BlocProvider( create: (context) => AdminHomeBloc(authRepository: getIt<AuthRepository>()), ),
        BlocProvider( create: (context) => ShoppingBloc(userRepository: getIt<UserRepository>()), ),
      ],
      child: MaterialApp.router(
        title: 'Material App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.purpleAccent,
            primary: themeColor,
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

      final now = DateTime.now();

      for (final entry in copyshops.entries) {
        final String docId = entry.key;
        final Map<String, dynamic> values = entry.value;
        final String shopEmail = docId;

        final docRef = firestore.collection('copyshops').doc(docId);

        // Guardar documento principal
        batch.set(docRef, {
          'copyShopName': values['copyShopName'],
          'copyShopEmail': shopEmail,
          'lat': values['lat'],
          'long': values['long'],
          'queue': values['queue'],
          'pauseReception': values['pauseReception'],
        }, SetOptions(merge: true));

        // Helper que devuelve un Map para una orden
        Map<String, dynamic> orderMap({
          required String userRegistration,
          required String userName,
          required String orderCode,
          required Duration initOffset,
          required Duration estimatedOffset,
          required String format,
          required bool isColor,
          required int pages,
          required String pdfName,
          required double price,
          String? paymentMethodToken, // <-- Nuevo
          required String verificationCode,
        }) {
          return {
            'userRegistration': userRegistration,
            'userName': userName,
            'orderCode': orderCode,
            'hasItBeenCanceledByUser': false,
            'hasItBeenAccepted': true,
            'estimatedDeliveryTime': Timestamp.fromDate(
              now.add(estimatedOffset),
            ),
            'format': format,
            'initDate': Timestamp.fromDate(now.add(initOffset)),
            'isColor': isColor,
            'pages': pages,
            'pdfName': pdfName,
            'copyShopName': values['copyShopName'],
            'placeLat': values['lat'],
            'placeLong': values['long'],
            'price': price,
            'url': '',
            'paymentMethod': paymentMethodToken ?? 'cash', // <-- Cambio aquí
            'verificationCode': verificationCode,
            'copyShopEmail': shopEmail,
          };
        }

        // Crear mapa de órdenes
        final Map<String, dynamic> ordersMap = <String, dynamic>{};

        if (docId == '24.7@gmail.com') {
          ordersMap['101'] = orderMap(
            userRegistration: '1974238',
            userName: 'Brandon Cantu',
            orderCode: '101',
            initOffset: Duration(minutes: -50),
            estimatedOffset: Duration(minutes: 30),
            format: 'Carta',
            isColor: true,
            pages: 25,
            pdfName: 'tesis_final.pdf',
            price: 75.0,
            paymentMethodToken: null, // efectivo
            verificationCode: '34524',
          );
          ordersMap['102'] = orderMap(
            userRegistration: '1923456',
            userName: 'Lucía Pérez',
            orderCode: '102',
            initOffset: Duration(minutes: -20),
            estimatedOffset: Duration(minutes: 40),
            format: 'Oficio',
            isColor: false,
            pages: 8,
            pdfName: 'resumen.pdf',
            price: 12.0,
            paymentMethodToken: 'pm_1Pv5abcxyz', // tarjeta
            verificationCode: '87231',
          );
        } else if (docId == 'bibl.rectoria@gmail.com') {
          ordersMap['201'] = orderMap(
            userRegistration: '1934563',
            userName: 'María López',
            orderCode: '201',
            initOffset: Duration(minutes: -30),
            estimatedOffset: Duration(minutes: 55),
            format: 'Oficio',
            isColor: false,
            pages: 10,
            pdfName: 'informe_cap2.pdf',
            price: 30.0,
            paymentMethodToken: 'pm_2Abcdefgh', // tarjeta
            verificationCode: '67843',
          );
          ordersMap['202'] = orderMap(
            userRegistration: '1939999',
            userName: 'Jorge Ruiz',
            orderCode: '202',
            initOffset: Duration(minutes: -10),
            estimatedOffset: Duration(minutes: 25),
            format: 'Carta',
            isColor: true,
            pages: 18,
            pdfName: 'articulo.pdf',
            price: 54.0,
            paymentMethodToken: null, // efectivo
            verificationCode: '55219',
          );
          ordersMap['203'] = orderMap(
            userRegistration: '1940001',
            userName: 'Eva Morales',
            orderCode: '203',
            initOffset: Duration(minutes: -5),
            estimatedOffset: Duration(minutes: 20),
            format: 'Carta',
            isColor: false,
            pages: 2,
            pdfName: 'nota.pdf',
            price: 4.0,
            paymentMethodToken: null, // efectivo
            verificationCode: '99012',
          );
        } else if (docId == 'facdyc@gmail.com') {
          ordersMap['301'] = orderMap(
            userRegistration: '1978899',
            userName: 'Luis Martínez',
            orderCode: '301',
            initOffset: Duration(hours: -2),
            estimatedOffset: Duration(hours: 1, minutes: 10),
            format: 'Carta',
            isColor: true,
            pages: 40,
            pdfName: 'proyecto_final.pdf',
            price: 120.0,
            paymentMethodToken: 'pm_3Xyzabcd', // tarjeta
            verificationCode: '12467',
          );
          ordersMap['302'] = orderMap(
            userRegistration: '1925000',
            userName: 'Marcos Díaz',
            orderCode: '302',
            initOffset: Duration(minutes: -25),
            estimatedOffset: Duration(minutes: 35),
            format: 'Oficio',
            isColor: false,
            pages: 15,
            pdfName: 'ensayo.pdf',
            price: 45.0,
            paymentMethodToken: null, // efectivo
            verificationCode: '33445',
          );
          ordersMap['303'] = orderMap(
            userRegistration: '1925001',
            userName: 'Paola Rivera',
            orderCode: '303',
            initOffset: Duration(minutes: -15),
            estimatedOffset: Duration(minutes: 50),
            format: 'Carta',
            isColor: true,
            pages: 5,
            pdfName: 'practica.pdf',
            price: 20.0,
            paymentMethodToken: 'pm_4Asdfghj', // tarjeta
            verificationCode: '66778',
          );
          ordersMap['304'] = orderMap(
            userRegistration: '1925002',
            userName: 'Diego Torres',
            orderCode: '304',
            initOffset: Duration(minutes: -5),
            estimatedOffset: Duration(minutes: 15),
            format: 'Oficio',
            isColor: false,
            pages: 3,
            pdfName: 'nota_actividad.pdf',
            price: 6.0,
            paymentMethodToken: null, // efectivo
            verificationCode: '22190',
          );
        } else if (docId == 'farq@gmail.com') {
          ordersMap['401'] = orderMap(
            userRegistration: '1945567',
            userName: 'UserTest',
            orderCode: '401',
            initOffset: Duration(hours: -1, minutes: -10),
            estimatedOffset: Duration(minutes: 40),
            format: 'Carta',
            isColor: true,
            pages: 25,
            pdfName: 'ModeloMatematicoCom.pdf',
            price: 75.0,
            paymentMethodToken: 'pm_5Qwerty', // tarjeta
            verificationCode: '34599',
          );
          ordersMap['402'] = orderMap(
            userRegistration: '1950002',
            userName: 'Fernanda Gil',
            orderCode: '402',
            initOffset: Duration(minutes: -45),
            estimatedOffset: Duration(minutes: 35),
            format: 'Oficio',
            isColor: false,
            pages: 20,
            pdfName: 'proyecto_cap2.pdf',
            price: 60.0,
            paymentMethodToken: null, // efectivo
            verificationCode: '77823',
          );
        } else if (docId == 'fime@gmail.com') {
          ordersMap['501'] = orderMap(
            userRegistration: '1924459',
            userName: 'Ana Gómez',
            orderCode: '501',
            initOffset: Duration(minutes: -15),
            estimatedOffset: Duration(hours: 3),
            format: 'Carta',
            isColor: true,
            pages: 12,
            pdfName: 'resumen_cap1.pdf',
            price: 24.0,
            paymentMethodToken: 'pm_6Poiuy', // tarjeta
            verificationCode: '12467',
          );
          ordersMap['502'] = orderMap(
            userRegistration: '5632456',
            userName: 'Carlos Rivera',
            orderCode: '502',
            initOffset: Duration(hours: -1, minutes: -5),
            estimatedOffset: Duration(hours: 2, minutes: 20),
            format: 'Oficio',
            isColor: false,
            pages: 6,
            pdfName: 'documento_ensayo.pdf',
            price: 18.0,
            paymentMethodToken: null, // efectivo
            verificationCode: '44901',
          );
          ordersMap['503'] = orderMap(
            userRegistration: '2344455',
            userName: 'Sofía Hernández',
            orderCode: '503',
            initOffset: Duration(minutes: -5),
            estimatedOffset: Duration(minutes: 90),
            format: 'Carta',
            isColor: false,
            pages: 3,
            pdfName: 'nota_actividad.pdf',
            price: 6.0,
            paymentMethodToken: null, // efectivo
            verificationCode: '99033',
          );
        } else if (docId == 'fime.x.farq@gmail.com') {
          ordersMap['601'] = orderMap(
            userRegistration: '1954345',
            userName: 'Alejandro Pérez',
            orderCode: '601',
            initOffset: Duration(hours: -2),
            estimatedOffset: Duration(minutes: 30),
            format: 'Carta',
            isColor: false,
            pages: 10,
            pdfName: 'tarea1.pdf',
            price: 20.0,
            paymentMethodToken: 'pm_7Zxcvb', // tarjeta
            verificationCode: '50122',
          );
          ordersMap['602'] = orderMap(
            userRegistration: '1906456',
            userName: 'Beatriz Flores',
            orderCode: '602',
            initOffset: Duration(hours: -3),
            estimatedOffset: Duration(hours: 1),
            format: 'Oficio',
            isColor: true,
            pages: 25,
            pdfName: 'proyecto_capitulo.pdf',
            price: 75.0,
            paymentMethodToken: 'pm_8Lkjhg', // tarjeta
            verificationCode: '45211',
          );
          ordersMap['603'] = orderMap(
            userRegistration: '1906546',
            userName: 'Carlos Mendoza',
            orderCode: '603',
            initOffset: Duration(hours: -1, minutes: -30),
            estimatedOffset: Duration(hours: 2),
            format: 'Carta',
            isColor: false,
            pages: 4,
            pdfName: 'resumen_articulo.pdf',
            price: 8.0,
            paymentMethodToken: 'pm_9Asdfg', // tarjeta
            verificationCode: '00399',
          );
          ordersMap['604'] = orderMap(
            userRegistration: '1945654',
            userName: 'Diana Rodríguez',
            orderCode: '604',
            initOffset: Duration(minutes: -10),
            estimatedOffset: Duration(hours: 2),
            format: 'Oficio',
            isColor: true,
            pages: 60,
            pdfName: 'tesis_entregable.pdf',
            price: 180.0,
            paymentMethodToken: 'pm_0Qwert', // tarjeta
            verificationCode: '00412',
          );
        }

        // Guardar el mapa de órdenes
        final aordersRef = docRef.collection('aorders').doc('information');
        batch.set(aordersRef, {'items': ordersMap}, SetOptions(merge: true));

        // Subcolecciones vacías
        final hordersRef = docRef.collection('horders').doc('information');
        batch.set(hordersRef, {
          'items': <Map<String, dynamic>>[],
        }, SetOptions(merge: true));

        final notificationsRef = docRef
            .collection('notifications')
            .doc('information');
        batch.set(notificationsRef, {
          'items': <Map<String, dynamic>>[],
        }, SetOptions(merge: true));
      }

      // Commit batch
      await batch.commit();

      print(
        '✅ (batch) copyshops y sub-colecciones creadas/actualizadas correctamente (orders con paymentMethod).',
      );
    } catch (e) {
      return Future.error(
        'Error creando copyshops y sub-colecciones (batch): $e',
      );
    }
  }

  Future<void> addThreeExampleHorders({required String registration}) async {
    try {
      final docRef = _firestore
          .collection('users')
          .doc(registration)
          .collection('horders')
          .doc('information');

      // Leer items actuales si existen
      final snap = await docRef.get();
      final existing = snap.data()?['items'];

      final List<Map<String, dynamic>> items = <Map<String, dynamic>>[];
      if (existing != null && existing is List) {
        for (final e in existing) {
          if (e is Map<String, dynamic>) {
            items.add(Map<String, dynamic>.from(e));
          } else if (e is Map) {
            items.add(Map<String, dynamic>.from(e as Map));
          }
        }
      }

      final now = DateTime.now();

      // Tus 3 ejemplos (tal como los pediste)
      final Map<String, dynamic> h1 = {
        'finalDate': Timestamp.fromDate(now.add(const Duration(minutes: 35))),
        'format': "A4",
        'initDate': Timestamp.fromDate(now),
        'isColor': true,
        'name': "Trabajo Escolar",
        'pages': 12,
        'pdfName': "trabajo_escolar.pdf",
        'place': "CopyShop Central",
        'price': 42.50,
        'url':
            "gs://printfastofficial2025.firebasestorage.app/1974238/printFastTest.pdf",
        'paymentMethod': "pm_1Example",
        'copyShopName': "FIME",
        'orderCode': "F345",
        'hasItBeenCanceled': false,
      };

      final Map<String, dynamic> h2 = {
        'finalDate': Timestamp.fromDate(now.subtract(const Duration(hours: 1))),
        'format': "Carta",
        'initDate': Timestamp.fromDate(now.subtract(const Duration(days: 1))),
        'isColor': false,
        'name': "Anexo",
        'pages': 4,
        'pdfName': "anexo.pdf",
        'place': "CopyShop Norte",
        'price': 15.00,
        'url': "",
        'paymentMethod': "cash",
        'copyShopName': "FARQ",
        'orderCode': "G7IH",
        'hasItBeenCanceled': true,
      };

      final Map<String, dynamic> h3 = {
        'finalDate': Timestamp.fromDate(now.subtract(const Duration(days: 2))),
        'format': "A3",
        'initDate': Timestamp.fromDate(now.subtract(const Duration(days: 3))),
        'isColor': true,
        'name': "Poster Evento",
        'pages': 2,
        'pdfName': "poster.pdf",
        'place': "CopyShop Sur",
        'price': 120.00,
        'url':
            "gs://printfastofficial2025.firebasestorage.app/1974238/ModeloMatematicoCom.pdf",
        'paymentMethod': "pm_2Example",
        'copyShopName': "24/7",
        'orderCode': "G764",
        'hasItBeenCanceled': false,
      };

      // Añadir al final de la lista existente
      items.addAll([h1, h2, h3]);

      // Guardar (merge para no borrar otros campos del documento)
      await docRef.set({'items': items}, SetOptions(merge: true));
    } catch (e) {
      return Future.error('Error añadiendo horders de ejemplo: $e');
    }
  }
}
