import 'package:flutter/material.dart';
import 'package:print_fast/dirScreens/login.dart';
import 'package:print_fast/dirScreens/register.dart';
import 'dirScreens/menu.dart';
import 'dirScreens/history.dart';
import 'dirScreens/shopping.dart';

class myScreens extends StatefulWidget {
  myScreens({super.key});
  @override
  State<myScreens> createState() => _myScreensState();
}

class _myScreensState extends State<myScreens> {
  int _indexscreen = 2;
  void changeindex(int newIndex) {
    setState(() {
      _indexscreen = newIndex;
      print("Cambiando a index ${_indexscreen}");
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> screens = [
      const myLogin(),
      const myRegister(),
      myMenu(chIndexShopping: () => changeindex(3), chIndexHistory: () => changeindex(4),),
      myShopping(chIndex: () => changeindex(2)),
      myHistory(
        chIndex: () => changeindex(2),
      ),
    ];

    return screens[_indexscreen];
  }
}
