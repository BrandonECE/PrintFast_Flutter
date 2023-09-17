import 'package:flutter/material.dart';

class mySettings extends StatelessWidget {
  mySettings({super.key, required this.chIndex});
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
      )),


      bottomNavigationBar: Container(
        height: 61,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [

            Stack(
              alignment: Alignment.center,
              children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: IconButton(onPressed: chIndex, icon: Icon(Icons.home, color: Theme.of(context).colorScheme.onSurfaceVariant,)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Text('Inicio', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),),
                  ),
              ],
            ),

            Stack(
              alignment: Alignment.center,
              children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: IconButton(onPressed: (){}, icon: const Icon(Icons.settings, color: Colors.white,)),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 30),
                    child: Text('Opciones', style: TextStyle(color: Colors.white),),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
    ;
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
                  "Opciones",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: 22,
                  ),
                )
              ],
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.help_outline,
                color: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class myBottonNavigationBar extends StatelessWidget {
  myBottonNavigationBar({super.key, required this.ChIndex});
  VoidCallback ChIndex;
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
        currentIndex: 1,
        onTap: (int ind){ChIndex;},
        
        backgroundColor: Theme.of(context).colorScheme.primary,
        selectedItemColor: Colors.white,
        unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Menu"),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: "Opciones"),
        ]);
  }
}


