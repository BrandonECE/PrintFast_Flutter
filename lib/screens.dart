import 'package:flutter/material.dart';
import 'package:print_fast/dirScreens/login.dart';
import 'package:print_fast/dirScreens/register.dart';
import 'dirScreens/menu.dart';
import 'dirScreens/history.dart';
import 'dirScreens/shopping.dart';
import 'dirScreens/settings.dart';

class myScreens extends StatefulWidget {
  myScreens({super.key});
  @override
  State<myScreens> createState() => _myScreensState();
}

class _myScreensState extends State<myScreens> {
  int _indexscreen = 2;
  int _indexscreeNavigationBar = 0;
  int _indexAntes = 2;


  void changeindex(int newIndex) {
    setState(() {
      _indexscreen = newIndex;
      _indexAntes = newIndex;
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
      myAppBarSettings(() {})
    ];

    List<Widget> screensBody = [
      const myLogin(),
      const myRegister(),
      myMenu(
        chIndexShopping: () => changeindex(3),
        chIndexHistory: () => changeindex(4),
      ),
      myShopping(),
      myHistory(),
      mySettings()
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        flexibleSpace: screensAppbar[_indexscreen],
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
