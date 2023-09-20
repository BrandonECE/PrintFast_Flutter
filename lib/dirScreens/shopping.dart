import 'package:flutter/material.dart';
import 'history.dart';

class myShopping extends StatelessWidget {
  myShopping({super.key, required this.chIndexButtonLocation});
  VoidCallback chIndexButtonLocation;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        child: containerMyShopping(chIndexButtonLocation: chIndexButtonLocation),
      ),
    );
  }
}

class myAppBarShopping extends StatelessWidget {
  ///PRUEBA
  myAppBarShopping({super.key, required this.chindex});
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
                  child: Icon(
                    Icons.shopping_cart_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
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
  containerMyShopping({super.key, required this.chIndexButtonLocation});
  VoidCallback chIndexButtonLocation; 
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        titlesContainer("Impresion"),
        sectionContainerMyShoppingCopy(),
        titlesContainer("Materiales"),
        sectionContainerMyShoppingItems(),
        sectionContainerMyShoppingInfo(chIndexButtonLocation: chIndexButtonLocation),
      ],
    );
  }
}

class sectionContainerMyShoppingCopy extends StatelessWidget {
  sectionContainerMyShoppingCopy({super.key});

  @override
  Widget build(BuildContext context) {
    List<Widget> ordersSectionContainerMyHistory = [
      Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        width: MediaQuery.of(context).size.width,
        height: 85,
      ),
    ];

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.all(Radius.circular(20))),
      width: MediaQuery.of(context).size.width * 0.83,
      child: Column(
        children: ordersSectionContainerMyHistory,
      ),
    );
  }
}

class sectionContainerMyShoppingWidgetItem extends StatelessWidget {
  const sectionContainerMyShoppingWidgetItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10)),
          width: MediaQuery.of(context).size.width,
          height: 85,
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }
}

class sectionContainerMyShoppingItems extends StatelessWidget {
  sectionContainerMyShoppingItems({super.key});

  @override
  Widget build(BuildContext context) {
    const List<Widget> ordersSectionContainerMyShoppingItems = [
      sectionContainerMyShoppingWidgetItem(),
      sectionContainerMyShoppingWidgetItem(),
      sectionContainerMyShoppingWidgetItem(),
      sectionContainerMyShoppingWidgetItem(),
      sectionContainerMyShoppingWidgetItem(),
    ];

    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: const BorderRadius.all(Radius.circular(20))),
        width: MediaQuery.of(context).size.width * 0.83,
        child: ListView(
          shrinkWrap: true,
          children: ordersSectionContainerMyShoppingItems,
        ),
      ),
    );
  }
}

class sectionContainerMyShoppingInfoPrice extends StatelessWidget {
  const sectionContainerMyShoppingInfoPrice({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        "Total: \$0",
        style: TextStyle(
          color: Theme.of(context).colorScheme.inverseSurface,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class sectionContainerMyShoppingInfoButton extends StatelessWidget {
  sectionContainerMyShoppingInfoButton({super.key, required this.chIndexButtonLocation});
  VoidCallback chIndexButtonLocation; 
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: chIndexButtonLocation,
      // ignore: sort_child_properties_last
      child: const Text(
        "Comprar",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.greenAccent.shade400,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

class sectionContainerMyShoppingInfo extends StatelessWidget {
  sectionContainerMyShoppingInfo({super.key, required this.chIndexButtonLocation});
  VoidCallback chIndexButtonLocation; 
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      width: MediaQuery.of(context).size.width * 0.83,
      // color: Colors.amber,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          sectionContainerMyShoppingInfoPrice(),
          sectionContainerMyShoppingInfoButton(chIndexButtonLocation: chIndexButtonLocation)
        ],
      ),
    );
  }
}
