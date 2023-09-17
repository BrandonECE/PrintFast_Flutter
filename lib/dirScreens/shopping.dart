
import 'package:flutter/material.dart';
import 'history.dart';

class myShopping extends StatelessWidget {
  myShopping({super.key, required this.chIndex});
  VoidCallback chIndex;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        flexibleSpace: myAppBar(chIndex),
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          child: const containerMyShopping(),
        ),
      ),
    );
  }
}


class myAppBar extends StatelessWidget {
  ///PRUEBA

  myAppBar(this.chindex);
  VoidCallback chindex;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        // margin: const EdgeInsets.only(top: 33), //HABILITAR SOLO PARA EL CELULAR
        // padding: const EdgeInsets.only(top: 33),
        // color: Colors.red,
        width: MediaQuery.of(context).size.width * 0.9,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
           const Row(
              children: [
                Text(
                  "Comprar",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.shopping_cart_rounded, color: Colors.white, size: 22,),
                )
              ],
            ),
            IconButton(
              onPressed: chindex,
              icon: const Icon(
                Icons.close_sharp,
                color: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class containerMyShopping extends StatelessWidget {

  const containerMyShopping({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        titlesContainerMenu("Items"),
        sectionContainerMyShopping()
      ],
    );
  }
}


class sectionContainerMyShopping extends StatelessWidget {
  sectionContainerMyShopping({super.key});


  @override
  Widget build(BuildContext context) {

    List<Widget> ordersSectionContainerMyHistory = [

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10)
          ),
          width: MediaQuery.of(context).size.width,
          height: 85,
        
        ),

      ];


    return Expanded(
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        width: MediaQuery.of(context).size.width * 0.83,
        child: Column(
          children: ordersSectionContainerMyHistory,
        ),
      ),
    );
  }
}
