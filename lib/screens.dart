import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:print_fast/dirScreens/isolates.dart';
import 'package:print_fast/dirScreens/locationDirection.dart';
import 'package:print_fast/dirScreens/orderActive.dart';
import 'package:print_fast/dirScreens/orderHistoryInfo.dart';
import 'package:print_fast/dirScreens/orderNotificationInfo.dart';
import 'package:print_fast/dirScreens/placelocation.dart';
import 'package:print_fast/dirScreens/screenload.dart';
import 'package:print_fast/dirScreens/login.dart';
import 'package:print_fast/dirScreens/register.dart';
import 'package:print_fast/firestore_service.dart';
import 'package:print_fast/sharedviewmodel.dart';
import 'package:print_fast/dirScreens/orderhistory.dart';
import 'package:provider/provider.dart';
// import 'package:print_fast/firestore_service.dart';
import 'dirScreens/location.dart';
import 'dirScreens/menu.dart';
import 'dirScreens/history.dart';
import 'dirScreens/shopping.dart';
import 'dirScreens/settings.dart';
import 'dirScreens/notificactionscreen.dart';
import 'package:geolocator/geolocator.dart';

class myScreens extends StatefulWidget {
  const myScreens({super.key});
  @override
  State<myScreens> createState() => _myScreensState();
}

class _myScreensState extends State<myScreens> {
  int _indexscreen = 0;
  int _indexAntes = 0;
  int _indexscreeNavigationBar = 0;
  int _indexTypeNavigationBar = 0;
  late double userLat = 0;
  late double userLong = 0;
  Map productosSeleccionados = {};
  Map productosSeleccionadosDB = {};
  double sumaTotal = 0;
  double sumaTotalDB = 0;
  myPlaceLocationInfo orderActive = myPlaceLocationInfo('---', 0, 0, 0, 0, 0);
  String name = "";
  String matricula = "";
  String email = "";
  String telefono = "";
  String initDateOrderA = "";
  String initTimeOrderA = "";
  String placeLat = "0";
  String placeLong = "0";
  String namePlace = "Cargando...";
  // List<myOrderHistoryInfo> orderHistoryInfo = [];
  myOrderHistoryInfo orderHistoryInfoScreen = myOrderHistoryInfo(
      "---", "---", "---", {}, "---", "---", "---", "---", "---");
  Map notis = {};

  void changeindex(int newIndex) async {
    try {
      setState(() {
        if (_indexAntes != 5) {
          ///El index 5 es el de los settings, mientras el index no sea ese (5) el NavigationBarBottom tendra que estar con el icono home como el presionado
          _indexscreeNavigationBar = 0;
        }

        _indexscreen = newIndex;

        ///Esto tiene como funcionalidad cambiar a la pantalla en la que se esta
        _indexAntes = newIndex;

        ///Esto tiene como funcionalidad volver a la pantalla en la que se estaba antes de cambiar a setting en el NavigationBarBottom

        print("Cambiando a index ${_indexscreen}");
      });
    } catch (e) {
      print("ERROR AL CAMBIAR DE INDEX");
    }
  }

  void changeindexNavigationBar(int newIndex) {
    setState(() {
      if (newIndex == 0) {
        _indexscreeNavigationBar = 0;
        _indexscreen = _indexAntes;
      } else {
        _indexscreeNavigationBar = 1;
        _indexscreen = 5;
      }
    });
  }

  Future<Position> determinatePosition() async {
    return await Geolocator.getCurrentPosition();
  }

  void changeindexloadtoLocation() async {
    Position position;
    position = await determinatePosition();
    userLat = await position.latitude;
    userLong = await position.longitude;
    print(position.latitude);
    print(position.longitude);
    changeindex(6);
  }

  void locationpermission() async {
    LocationPermission permissionCheck;
    permissionCheck = await Geolocator.checkPermission();
    if (permissionCheck == LocationPermission.denied) {
      LocationPermission permission;
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.always ||
          permission == LocationPermission.unableToDetermine ||
          permission == LocationPermission.whileInUse) {
        changeindex(7);
        print(productosSeleccionados);
        changeindexloadtoLocation();
      }
    } else if (permissionCheck == LocationPermission.always ||
        permissionCheck == LocationPermission.unableToDetermine ||
        permissionCheck == LocationPermission.whileInUse) {
      changeindex(7);
      print(productosSeleccionados);
      changeindexloadtoLocation();
    }
  }

  void changeindexloadtoLocationDirections() async {
    Position position;
    position = await determinatePosition();
    userLat = await position.latitude;
    userLong = await position.longitude;
    print(position.latitude);
    print(position.longitude);
    changeindex(11);
  }

  void locationpermissionDirections() async {
    LocationPermission permissionCheck;
    permissionCheck = await Geolocator.checkPermission();
    if (permissionCheck == LocationPermission.denied) {
      LocationPermission permission;
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.always ||
          permission == LocationPermission.unableToDetermine ||
          permission == LocationPermission.whileInUse) {
        changeindex(7);
        changeindexloadtoLocationDirections();
      }
    } else if (permissionCheck == LocationPermission.always ||
        permissionCheck == LocationPermission.unableToDetermine ||
        permissionCheck == LocationPermission.whileInUse) {
      changeindex(7);
      changeindexloadtoLocationDirections();
    }
  }

  void changeindexloadtoShopping() async {
    changeindex(8);
    await Future.delayed(const Duration(seconds: 2));
    changeindex(3);
  }

  void changeIndexLogin() {
    _indexscreeNavigationBar = 0;
    _indexscreen = 2;
    _indexAntes = 2;
    setState(() {});
  }

  void changeIndexLogout() {
    _indexscreen = 0;
    _indexAntes = 0;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // ignore: prefer_function_declarations_over_variables

    // ignore: prefer_function_declarations_over_variables
    Function(myPlaceLocationInfo) getPlaceOrderActive = (placeLocationInfo) {
      orderActive = placeLocationInfo;
    };

    Function(double) getSumaTotal = (sumaT) {
      print("!!!!!!!!!!!!!!!!!!!!!!!!!");
      print(sumaT);
      sumaTotal = sumaT;
      print("!!!!!!!!!!!!!!!!!!!!!!!!!");
    };

    // ignore: prefer_function_declarations_over_variables
    Function(Map) getProductosSeleccionados = (products) {
      productosSeleccionados = products;
      locationpermission();
    };

    // ignore: prefer_function_declarations_over_variables, unused_local_variable
    Function(Map) getProductosSeleccionadosDB = (products) {
      productosSeleccionadosDB = products;
    };

    Function(String, String) getPlaceCoordenadas = (Lat, Long) {
      placeLat = Lat;
      placeLong = Long;
    };

    // ignore: unused_local_variable, prefer_function_declarations_over_variables
    Function(double) getSumaTotalDB = (sumaT) {
      sumaTotalDB = sumaT;
    };

    Function(String) getInitDate = (String date) {
      initDateOrderA = date;
    };

    Function(String) getInitTime = (String time) {
      initTimeOrderA = time;
    };

    Function(String) getNamePlace = (String nameplace) {
      namePlace = nameplace;
    };

    Function(myOrderHistoryInfo) getOrderHistoryScreen =
        (myOrderHistoryInfo orderHistory) {
      orderHistoryInfoScreen = orderHistory;
    };

    // ignore: prefer_function_declarations_over_variables
    Function(Map) getUserData = (infoUser) {
      infoUser.forEach((info, value) {
        if (info == "Nombre") {
          name = value;
        }
        if (info == "Telefono") {
          telefono = value;
        }
        if (info == "Matricula") {
          matricula = value;
        }
        if (info == "E-mail") {
          email = value;
        }
      });
    };

    if (_indexscreen > 1 && _indexAntes > 1) {
      _indexTypeNavigationBar = 1;
    } else {
      _indexTypeNavigationBar = 0;
    }

    List<Widget> typesbottombar = [
      Container(
        height: 60,
        alignment: Alignment.center,
        child: const Text(
          "Universidad Autónoma de Nuevo León",
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
      BottomNavigationBar(
          currentIndex: _indexscreeNavigationBar,
          onTap: (int index) {
            changeindexNavigationBar(index);
          },
          backgroundColor: Theme.of(context).colorScheme.primary,
          selectedItemColor: Colors.white,
          unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Menu"),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: "Opciones"),
          ]),
    ];

    return ChangeNotifierProvider<SharedChangeNotifier>(
        create: (context) => SharedChangeNotifier(),
        builder: (context, child) {
          final sharedChangeNotifier = context.watch<SharedChangeNotifier>();

          sharedChangeNotifier.updateScreenIndex(_indexscreen);

          void changeIndexHistory() async {
            sharedChangeNotifier.sharedorderHistoryInfo.value.clear();
            sharedChangeNotifier.updateIsThereOrderHistoryInfo(false);
            Map historyOrders = await getDBUserOrdersH(matricula);
            final recivePort = ReceivePort();
            final isolate = await Isolate.spawn(
                isolateOrdersHistoryOrdenar,
                IsolateOrdersHistoryOrdenar(
                    historyOrders, recivePort.sendPort));

            recivePort.listen((message) {
              sharedChangeNotifier
                  .updateorderHistoryInfo(message as List<myOrderHistoryInfo>);
              isolate.kill(priority: Isolate.immediate);
            });
            // orderHistoryInfo = orderHistoryInfo.reversed.toList();
            changeindex(4);
          }

          void changeIndexNotification() async {
            sharedChangeNotifier.sharedNotificationInfo.value.clear();
            sharedChangeNotifier.updateIsThereNotificationInfo(false);
            Map notificaciones = await getDBUserNotis(matricula);
            final recivePort = ReceivePort();
            final isolate = await Isolate.spawn(isolateNotificationInfo,
                IsolateNotificationInfo(notificaciones, recivePort.sendPort));

            recivePort.listen((message) {
              sharedChangeNotifier.updateNotificationInfo(
                  message as List<myOrderNotificationInfo>);
              isolate.kill(priority: Isolate.immediate);
            });
            // orderHistoryInfo = orderHistoryInfo.reversed.toList();
            changeindex(10);
          }

          // ignore: unused_local_variable, prefer_function_declarations_over_variables
          Function(int) deleteNotification = (int index) async {
            changeindex(10);
            sharedChangeNotifier.sharedNotificationInfo.value.clear();
            sharedChangeNotifier.updateIsThereNotificationInfo(false);
            Map notificaciones = await getDBUserNotis(matricula);
            final recivePort = ReceivePort();
            final isolate = await Isolate.spawn(
                isolateDeleteNotification,
                IsolateDeleteNotification(
                    notificaciones, recivePort.sendPort, index));
            recivePort.listen((message) async {
              try {
                await updateNotisDeletedOne(message as Map, matricula);
                changeIndexNotification();
              } catch (e) {
                print(e);
                print("EXCEPCION A LA HORAN DE BORRAR UNA NOTIFICACION");
              }
              isolate.kill(priority: Isolate.immediate);
            });
            // orderHistoryInfo = orderHistoryInfo.reversed.toList();
          };

          List<Widget> screensAppbar = [
            const myAppBarLogin(),
            myAppBarRegister(chIndexRegisterToLogin: () => changeindex(0)),
            myAppBarMenu(
              sharedChangeNotifier: sharedChangeNotifier,
              matricula: matricula,
              chIndexNotification: () => changeIndexNotification(),
            ),
            myAppBarShopping(chindex: () => changeindex(2)),
            myAppBarHistory(
              chindex: () => changeindex(2),
            ),
            myAppBarSettings(() {}),
            myAppBarLocation(
              chindex: () => changeindex(2),
            ),
            myAppBarScreenLoad(
              chindex: () => changeindex(2),
              icon: Icons.location_on_rounded,
            ),
            myAppBarmyOrderActiveScreenInfo(
              chindex: () => changeindex(2),
            ),
            myAppBarHistoryOrder(chindex: () => changeindex(4)),
            myAppBarNotificationScreens(chindex: () => changeindex(2)),
            myAppBarLocationDirections(chindex: () => changeindex(8))
          ];

          List<Widget> screensBody = [
            myLogin(
                chIndexMenu: () => changeIndexLogin(),
                chIndexRegister: () => changeindex(1),
                functionInfoUser: getUserData),
            myRegister(chIndexLogin: () => changeindex(0)),
            myMenu(
                getNamePlace: getNamePlace,
                getPlaceCoordenadas: getPlaceCoordenadas,
                getInitDate: getInitDate,
                getInitTime: getInitTime,
                sharedChangeNotifier: sharedChangeNotifier,
                getProductosSeleccionadosDB: getProductosSeleccionadosDB,
                getSumaTotalDB: getSumaTotalDB,
                chIndexShopping: () => changeindex(3),
                chIndexHistory: () => changeIndexHistory(),
                chIndexOrderActive: () => changeindex(8),
                name: name,
                matricula: matricula),
            myShopping(
                chIndexButtonLocation: getProductosSeleccionados,
                getSumaTotal: getSumaTotal),
            myHistory(
                // orderHistoryInfo: orderHistoryInfo,
                sharedChangeNotifier: sharedChangeNotifier,
                getOrderHistoryScreen: getOrderHistoryScreen,
                chIndexOrderHistory: () => changeindex(9)),
            mySettings(
                chIndexMenu: () => changeIndexLogout(),
                name: name,
                telefono: telefono,
                email: email,
                matricula: matricula),
            myLocation(
                matricula: matricula,
                chIndexMenu: () => changeindex(2),
                userLat: userLat,
                userLong: userLong,
                productosSeleccionados: productosSeleccionados,
                placeOrderActive: getPlaceOrderActive,
                sumaTotal: sumaTotal),
            const myScreenLoad(),
            myOrderActiveScreenInfo(
                chIndexLocationDirections: () => locationpermissionDirections(),
                initDateOrderA: initDateOrderA,
                initTimeOrderA: initTimeOrderA,
                productosSeleccionadosDB: productosSeleccionadosDB,
                sumaTotalDB: sumaTotalDB),
            myHistoryOrder(orderHistoryInfoScreen: orderHistoryInfoScreen),
            NotificationScreens(
              matricula: matricula,
              sharedChangeNotifier: sharedChangeNotifier,
              deleteNotification: deleteNotification,
            ),
            myLocationDirections(
              sharedChangeNotifier: sharedChangeNotifier,
              namePlace: namePlace,
              userLong: userLong,
              userLat: userLat,
              placeLat: placeLat,
              placeLong: placeLong,
            )
          ];

          return Scaffold(
              backgroundColor: Theme.of(context).colorScheme.primary,
              appBar: AppBar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                flexibleSpace: SafeArea(child: screensAppbar[_indexscreen]),
              ),
              body: screensBody[_indexscreen],
              bottomNavigationBar: typesbottombar[_indexTypeNavigationBar]);
        });
  }
}
