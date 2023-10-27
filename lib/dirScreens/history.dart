import 'package:flutter/material.dart';

class myHistory extends StatelessWidget {
  myHistory({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(20))
            // borderRadius: BorderRadius.only(
            //     topLeft: Radius.circular(20), topRight: Radius.circular(20))
                ),
        child: const containerMyHistory(),
      ),
    );
  }
}

// ignore: must_be_immutable
class myAppBarHistory extends StatelessWidget {
  ///PRUEBA

  myAppBarHistory({super.key, required this.chindex});
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
        titlesContainer("Ordenes"),
        sectionContainerMyHistory(),
      ],
    );
  }
}

// ignore: must_be_immutable
class titlesContainer extends StatelessWidget {
  titlesContainer(this.title);
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
          const Icon(
            Icons.arrow_drop_down,
            size: 25,
          )
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class sectionContainerMyHistoryOrder extends StatelessWidget {
  sectionContainerMyHistoryOrder({super.key, required this.fecha});
  String fecha;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              border: Border.all(color:Colors.grey.shade600),
              color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(10)),
          width: MediaQuery.of(context).size.width,
          child: Text(
            fecha,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),

              color: Colors.white, borderRadius: BorderRadius.circular(10)),
          width: MediaQuery.of(context).size.width,
          height: 85,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text("24/7", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.inverseSurface),),
                  const SizedBox(
                    width: 4,
                  ),
                  Icon(Icons.location_on_rounded, color: Theme.of(context).colorScheme.inverseSurface, size: 18,)
                ],
              ),
              
              Text("300\$", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.inverseSurface),),
              ElevatedButton(onPressed: (){}, 
              style: ElevatedButton.styleFrom(
                onPrimary: Colors.white,
                primary: Theme.of(context).colorScheme.primary,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15))
                )
              ),
              child: const Icon(Icons.remove_red_eye))
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }
}

class sectionContainerMyHistory extends StatelessWidget {
  sectionContainerMyHistory({super.key});

  @override
  Widget build(BuildContext context) {
    List<Widget> ordersSectionContainerMyHistory = [
      sectionContainerMyHistoryOrder(fecha: "26 de Abril del 2023"),
      sectionContainerMyHistoryOrder(fecha: "14 de Febrero del 2023"),
      sectionContainerMyHistoryOrder(fecha: "05 de Diciembre del 2022"),
      sectionContainerMyHistoryOrder(fecha: "23 de Novimebre del 2022"),
      sectionContainerMyHistoryOrder(fecha: "10 de Octubre del 2022"),
    ];

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(bottom: 25),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(20),
        ),
        width: MediaQuery.of(context).size.width * 0.83,
        child: ListView(
          shrinkWrap: true,
          children: ordersSectionContainerMyHistory,
        ),
      ),
    );
  }
}
