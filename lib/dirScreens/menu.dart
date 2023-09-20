
import 'package:flutter/material.dart';
import '../screens.dart';

class myMenu extends StatelessWidget {
  myMenu(
      {super.key, required this.chIndexShopping, required this.chIndexHistory});
  VoidCallback chIndexShopping;
  VoidCallback chIndexHistory;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        child: Column(
          children: [
            const briefGreeting(),
            containerMenuOptions(
                chIndexShopping: chIndexShopping,
                chIndexHistory: chIndexHistory),
            titlesContainer(title: "Novedades", icono: Icons.star_rounded, sizee: 18, padd: 5),
            // titlesContainerMenu("Novedades"),
            const myNews(),
            titlesContainer(
                title: "Orden activa", icono: Icons.arrow_drop_down, sizee: 25, padd: 0,),
            // titlesContainerMenu("Orden Activa"),
            sectionContainerMyActiveOrders()
          ],
        ),
      ),
    );
  }
}

class myAppBarMenu extends StatelessWidget {
  const myAppBarMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        // padding: const EdgeInsets.only(top: 33),
        // margin: const EdgeInsets.only(top: 33), //HABILITAR SOLO PARA EL CELULAR
        // color: Colors.red,
        width: MediaQuery.of(context).size.width * 0.9,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  "PrintFast",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: Image.asset(
                      'assets/images/printfast_logo.png',
                    ),
                  ),
                ),
              ],
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
  containerMenuOptions(
      {super.key, required this.chIndexShopping, required this.chIndexHistory});
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
      height: 150,
      child: const Center(
        child: Text(
          "Noticias",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class sectionContainerMyActiveOrders extends StatelessWidget {
  sectionContainerMyActiveOrders({super.key});

  @override
  Widget build(BuildContext context) {
    List<Widget> orderActiveSectionContainer = [
      Expanded(
          child: Center(
        child: Container(
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.hide_source,
                color: Colors.grey,
                size: 50,
              ),
              Text(
                "Ninguna orden",
                style: TextStyle(color: Colors.grey, fontSize: 18),
              ),
            ],
          ),
        ),
      )),
      Expanded(
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10)),
          width: MediaQuery.of(context).size.width,
        ),
      ),
    ];

    return Expanded(
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.only(bottom: 30),
        width: MediaQuery.of(context).size.width * 0.83,
        child: Container(
          child: orderActiveSectionContainer[0],
        ),
      ),
    );
  }
}

class titlesContainer extends StatelessWidget {
  titlesContainer(
      {super.key,
      required this.title,
      required this.icono,
      required this.sizee,
      required this.padd});
  String title;
  IconData icono;
  double? sizee;
  double padd;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 20),
      width: MediaQuery.of(context).size.width * 0.83,
      // color: Colors.amber,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.inverseSurface),
          ),
          Padding(
            padding: EdgeInsets.only(left: padd),
            child: Icon(
              icono,
              size: sizee,
            ),
          )
        ],
      ),
    );
  }
}
