import 'package:flutter/material.dart';
import 'package:print_fast/dirScreens/screenload.dart';
import 'package:print_fast/dirScreens/login.dart';
import 'package:print_fast/dirScreens/register.dart';
import 'package:print_fast/firestore_service.dart';
import 'dirScreens/location.dart';
import 'dirScreens/menu.dart';
import 'dirScreens/history.dart';
import 'dirScreens/shopping.dart';
import 'dirScreens/settings.dart';
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

  String name = "";
  String matricula = "";
  String email = "";
  String telefono = "";

  void changeindex(int newIndex) {
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
        await updateDB(productosSeleccionados);
        changeindexloadtoLocation();
      }
    } else if (permissionCheck == LocationPermission.always ||
        permissionCheck == LocationPermission.unableToDetermine ||
        permissionCheck == LocationPermission.whileInUse) {
      changeindex(7);
      print(productosSeleccionados);
      await updateDB(productosSeleccionados);
      changeindexloadtoLocation();
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
    Function(Map) getProductosSeleccionados = (products) {
      productosSeleccionados = products;
      locationpermission();
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

    List<Widget> screensAppbar = [
      const myAppBarLogin(),
      myAppBarRegister(chIndexRegisterToLogin: () => changeindex(0)),
      const myAppBarMenu(),
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
    ];

    List<Widget> screensBody = [
      myLogin(
          chIndexMenu: () => changeIndexLogin(),
          chIndexRegister: () => changeindex(1),
          functionInfoUser: getUserData),
      myRegister(chIndexLogin: () => changeindex(0)),
      myMenu(
        chIndexShopping: () => changeindex(3),
        chIndexHistory: () => changeindex(4),
        name: name,
      ),
      myShopping(chIndexButtonLocation: getProductosSeleccionados),
      myHistory(),
      mySettings(chIndexMenu: () => changeIndexLogout(), name: name, telefono: telefono, email: email, matricula: matricula),
      myLocation(
          userLat: userLat,
          userLong: userLong,
          productosSeleccionados: productosSeleccionados),
      const myScreenLoad(),
    ];

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

    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          flexibleSpace: SafeArea(child: screensAppbar[_indexscreen]),
        ),
        body: screensBody[_indexscreen],
        bottomNavigationBar: typesbottombar[_indexTypeNavigationBar]);
  }
}
