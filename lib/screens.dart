import 'package:flutter/material.dart';
import 'package:print_fast/dirScreens/screenload.dart';
import 'package:print_fast/dirScreens/login.dart';
import 'package:print_fast/dirScreens/register.dart';
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
  int _indexscreen = 3;
  int _indexscreeNavigationBar = 0;
  int _indexAntes = 3;
  late double userLat = 0;
  late double userLong = 0;

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

  void PrintLatLong() async {
    changeindex(7);
    Position position;
    position = await determinatePosition();
    userLat = await position.latitude;
    userLong = await position.longitude;
    print(position.latitude);
    print(position.longitude);
    changeindex(6);
  }

  void changeindexGeocalizacion() async {
    LocationPermission permissionCheck;
    permissionCheck = await Geolocator.checkPermission();
    if (permissionCheck == LocationPermission.denied) {
      LocationPermission permission;
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.always ||
          permission == LocationPermission.unableToDetermine ||
          permission == LocationPermission.whileInUse) {
        PrintLatLong();
      }
    } else if (permissionCheck == LocationPermission.always ||
        permissionCheck == LocationPermission.unableToDetermine ||
        permissionCheck == LocationPermission.whileInUse) {
      PrintLatLong();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> screensAppbar = [
      const myLogin(),
      const myRegister(),
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
      )
    ];

    List<Widget> screensBody = [
      const myLogin(),
      const myRegister(),
      myMenu(
        chIndexShopping: () => changeindex(3),
        chIndexHistory: () => changeindex(4),
      ),
      myShopping(chIndexButtonLocation: () => changeindexGeocalizacion()),
      myHistory(),
      mySettings(),
      myLocation(
        userLat: userLat,
        userLong: userLong,
      ),
      const myScreenLoad()
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        flexibleSpace: SafeArea(child: screensAppbar[_indexscreen]),
      ),
      body: screensBody[_indexscreen],
      bottomNavigationBar: BottomNavigationBar(
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
    );
  }
}
