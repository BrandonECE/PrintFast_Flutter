import 'package:flutter/material.dart';
import '../screens.dart';

class myMenu extends StatefulWidget {
  myMenu({super.key, required this.chIndexShopping, required this.chIndexHistory});
  VoidCallback chIndexShopping;
  VoidCallback chIndexHistory;
  @override
  State<myMenu> createState() => _myMenuState();
}

class _myMenuState extends State<myMenu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        flexibleSpace: const myAppBar(),
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          child: Column(
            children: [
              const briefGreeting(),
              containerMenuOptions(chIndexShopping: widget.chIndexShopping, chIndexHistory: widget.chIndexHistory),
              titlesContainerMenu("Novedades"),
              const myNews(),
              titlesContainerMenu("Ordenes activas"),
            ],
          ),
        ),
      ),
    );
  }
}

class myAppBar extends StatelessWidget {
  const myAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        // padding: const EdgeInsets.only(top: 33),
        // margin: EdgeInsets.only(top: 32),
        // color: Colors.red,
        width: MediaQuery.of(context).size.width * 0.9,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "PrintFast",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
            IconButton(
              onPressed: () {
                print("NOTI");
              },
              icon: const Icon(
                Icons.notifications,
                color: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class titlesContainerMenu extends StatelessWidget {
  titlesContainerMenu(this.title);
  String title;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 20),
      width: MediaQuery.of(context).size.width * 0.83,
      // color: Colors.amber,
      child: Text(
        title,
        style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.inverseSurface),
      ),
    );
  }
}

class containerMenuOptions extends StatelessWidget {
  containerMenuOptions({super.key, required this.chIndexShopping, required this.chIndexHistory});
  VoidCallback chIndexShopping;
  VoidCallback chIndexHistory;
  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width * 0.83,
        // color: Colors.amber,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            menuOptions(
                icon: Icons.shopping_cart_rounded,
                index: 3,
                nameOption: "Comprar",
                ChIndex: chIndexShopping),
            menuOptions(
                icon: Icons.history,
                index: 4,
                nameOption: "Historial",
                ChIndex: chIndexHistory),
          ],
        ));
  }
}

class menuOptions extends StatelessWidget {
  menuOptions(
      {required this.icon,
      required this.index,
      required this.nameOption,
      required this.ChIndex});
  VoidCallback ChIndex;
  IconData icon;
  int index;
  String nameOption;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ChIndex,
      child: Container(
        margin: EdgeInsets.only(top: 15),
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(20)),
        width: MediaQuery.of(context).size.width * 0.4,
        height: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Icon(
                icon,
                color: Colors.white,
                size: 35,
              ),
            ),
            Container(
                margin: const EdgeInsets.only(top: 6),
                child: Text(
                  nameOption,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ))
          ],
        ),
      ),
    );
  }
}

class briefGreeting extends StatelessWidget {
  const briefGreeting({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.83,
      margin: const EdgeInsets.only(top: 15),
      // padding: const EdgeInsets.only(left: 12, right: 12),
      // color: const Color.fromARGB(255, 129, 115, 73),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.waving_hand_rounded,
                color: Colors.amber,
              ),
              Container(
                margin: const EdgeInsets.only(left: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: const Row(
                        children: [
                          Text(
                            "¡Hola, ",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            "Brandon",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "!",
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                    Container(
                        margin: const EdgeInsets.only(top: 2.5),
                        child: const Text(
                          "Es un gusto tenerte con nostros",
                          style: TextStyle(fontSize: 14),
                        ))
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class myNews extends StatelessWidget {
  const myNews({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.83,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      height: 200,
      child: const Center(
        child: Text(
          "Noticias",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
