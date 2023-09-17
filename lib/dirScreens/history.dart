import 'package:flutter/material.dart';

class myHistory extends StatelessWidget {
  myHistory({super.key, required this.chIndex});
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
          child: const containerMyHistory(),
        ),
      ),
      bottomNavigationBar: myBottonNavigationBar(),
    );
  }
}

class myBottonNavigationBar extends StatelessWidget {
  const myBottonNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
        currentIndex: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        selectedItemColor: Colors.white,
        unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
        items: const [BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Menu"
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: "Opciones"
            ),
            ]);
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
                  "Historial",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.history,
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

class containerMyHistory extends StatelessWidget {
  const containerMyHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        titlesContainerMenu("Ordenes"),
        sectionContainerMyHistory(),
      ],
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
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.inverseSurface),
          ),
          const Icon(Icons.arrow_drop_down, size: 25,)
        ],
      ),
    );
  }
}

class sectionContainerMyHistory extends StatelessWidget {
  sectionContainerMyHistory({super.key});


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
        const SizedBox(
          height: 20,
        ),
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
        margin: const EdgeInsets.only(bottom: 25),
        decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(20),
            ),
        width: MediaQuery.of(context).size.width * 0.83,
        child: Column(
          children: ordersSectionContainerMyHistory,
        ),
      ),
    );
  }
}

