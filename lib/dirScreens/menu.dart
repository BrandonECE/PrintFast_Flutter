import 'package:flutter/material.dart';
import 'dart:async';
import 'package:print_fast/sharedviewmodel.dart';
import 'package:print_fast/dirScreens/orderActiveInfo.dart';
import 'package:print_fast/firestore_service.dart';

// import '../screens.dart';

// ignore: must_be_immutable
class myMenu extends StatefulWidget {
  myMenu(
      {super.key,
      required this.sharedChangeNotifier,
      required this.chIndexShopping,
      required this.chIndexHistory,
      required this.name,
      required this.matricula,
      required this.chIndexOrderActive,
      required this.getProductosSeleccionadosDB,
      required this.getSumaTotalDB});
  VoidCallback chIndexOrderActive;
  Function(double) getSumaTotalDB;
  SharedChangeNotifier sharedChangeNotifier;
  String matricula;
  VoidCallback chIndexShopping;
  VoidCallback chIndexHistory;
  Function(Map) getProductosSeleccionadosDB;
  String name;
  @override
  State<myMenu> createState() => _myMenuState();
}

class _myMenuState extends State<myMenu> {
  Map infoUserOrderActive = {};
  bool once = false;
  bool orderActive = false;
  myOrderActiveInfo orderActiveInfo =
      myOrderActiveInfo("Cargando...", "0", "0", {});

  @override
  Widget build(BuildContext context) {
    bool changeInitTime = widget.sharedChangeNotifier.sharedTimeInit.value;
    // print("VIEWMODEL: ${widget.sharedChangeNotifier.sharedTime.value}");

    void _actualizarOrderActiva() {
      once = false;
      orderActive = false;
      setState(() {});
    }

    void verifyOrderActive() async {
      infoUserOrderActive = await getDBUserOrderA(widget.matricula);
      if (infoUserOrderActive.isEmpty) {
        orderActive = false;
        print("NO HAY");
      } else {
        String? place;
        String? price;
        String? time;
        Map? productos;
        orderActive = true;
        infoUserOrderActive.forEach((key, value) {
          if (key == "Place") place = value;
          if (key == "Price") price = value;
          if (key == "Time") time = value;
          if (key == "Compras") productos = value;
        });
        orderActiveInfo = myOrderActiveInfo(place!, price!, time!, productos!);
        print("SI HAY");
        if (changeInitTime == false) {
           widget.sharedChangeNotifier.updateMatricula(widget.matricula);
          widget.sharedChangeNotifier.updateTime(int.parse(time!));
          widget.sharedChangeNotifier.updateTimeInit(true);
          widget.sharedChangeNotifier.initTimerPeriodic();
        }
      }
      print(infoUserOrderActive);
      setState(() {});
    }

    if (once == false) {
      verifyOrderActive();
      once = true;
    }

    //  print("VIEWMODEL: ${widget.sharedChangeNotifier.sharedTime.value}");

    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        alignment: Alignment.center,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 20),
              width: MediaQuery.of(context).size.width * 0.95,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  // borderRadius: BorderRadius.only(
                  //     topLeft: Radius.circular(20), topRight: Radius.circular(20)),

                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: Column(
                children: [
                  briefGreeting(name: widget.name),
                  containerMenuOptions(
                      chIndexShopping: widget.chIndexShopping,
                      chIndexHistory: widget.chIndexHistory),
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.width * 0.03,
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: Colors.white,
                ),
                width: MediaQuery.of(context).size.width * 0.95,
                alignment: Alignment.center,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        child: Column(
                          children: [
                            titlesContainer(
                                title: "Novedades",
                                icono: Icons.star_rounded,
                                sizee: 18,
                                padd: 5),
                            const myNews(),
                          ],
                        ),
                      ),
                      Container(
                        child: Column(
                          children: [
                            titlesContainer(
                              title: "Orden activa",
                              icono: Icons.arrow_drop_down,
                              sizee: 25,
                              padd: 0,
                            ),
                            sectionContainerMyActiveOrders(
                              sharedChangeNotifier: widget.sharedChangeNotifier,
                              matricula: widget.matricula,
                              getSumaTotalDB: widget.getSumaTotalDB,
                              orderActiveInfo: orderActiveInfo,
                              orderActive: orderActive,
                              actualizarOrderA: () => _actualizarOrderActiva(),
                              chIndexOrderActive: widget.chIndexOrderActive,
                              getProductosSeleccionadosDB:
                                  widget.getProductosSeleccionadosDB,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
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

// ignore: must_be_immutable
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

// ignore: must_be_immutable
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

// ignore: must_be_immutable
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
    return Container(
      margin: const EdgeInsets.only(top: 15),
      child: Material(
        child: Ink(
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(20)),
          width: MediaQuery.of(context).size.width * 0.4,
          height: 100,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () async {
              await Future.delayed(const Duration(milliseconds: 250));
              ChIndex.call();
            },
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
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class briefGreeting extends StatelessWidget {
  briefGreeting({super.key, required this.name});
  String name;
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
                      child: Row(
                        children: [
                          const Text(
                            "¡Hola, ",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            name,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            "!",
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                    Container(
                        margin: const EdgeInsets.only(top: 2.5),
                        child: const Text(
                          "Es un gusto poderte atender",
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
      height: MediaQuery.of(context).size.height * 0.17,
      clipBehavior: Clip.antiAlias,
      child: Stack(children: [
        Container(
          width: MediaQuery.of(context).size.width,
          child: SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.fill,
              child: Image.asset("assets/images/printfast_news.png"),
            ),
          ),
        ),
        Positioned(
          top: 10,
          left: 20,
          child: Row(
            children: [
              const Text(
                "PrintFast",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
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
        ),
        Positioned(
          bottom: 60,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(5))),
            margin: const EdgeInsets.only(left: 20),
            child: Text(
              "¡NUEVO PRODUCTO!",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(5))),
            margin: const EdgeInsets.only(left: 20),
            child: Text(
              "COMPRALO YA!",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12),
            ),
          ),
        ),
        const Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(right: 40),
              child: Icon(
                Icons.star_border_outlined,
                color: Colors.white,
                size: 70,
              ),
            ))
      ]),
    );
  }
}

// ignore: must_be_immutable
class sectionContainerMyActiveOrders extends StatefulWidget {
  sectionContainerMyActiveOrders(
      {super.key,
      required this.sharedChangeNotifier,
      required this.matricula,
      required this.orderActive,
      required this.actualizarOrderA,
      required this.orderActiveInfo,
      required this.chIndexOrderActive,
      required this.getProductosSeleccionadosDB,
      required this.getSumaTotalDB});
  Function(double) getSumaTotalDB;
  String matricula;
  SharedChangeNotifier sharedChangeNotifier;
  Function(Map) getProductosSeleccionadosDB;
  VoidCallback chIndexOrderActive;
  VoidCallback actualizarOrderA;
  myOrderActiveInfo orderActiveInfo;
  bool orderActive;

  @override
  State<sectionContainerMyActiveOrders> createState() =>
      _sectionContainerMyActiveOrdersState();
}

class _sectionContainerMyActiveOrdersState
    extends State<sectionContainerMyActiveOrders> {
  // late Timer _timer;

  int __indexSectionOrderActive = 0;
  // int countChange = 0;

  @override
  Widget build(BuildContext context) {
    // if (widget.sharedChangeNotifier.sharedTime.value != countChange) {
    //   countChange = widget.sharedChangeNotifier.sharedTime.value;
    //   setState(() {});
    // }

    double time = widget.sharedChangeNotifier.sharedTime.value.toDouble();
    String timeString = "---";

    if (time < 1 && time > 0) {
      timeString = "${time.toInt()} seg";
    } else if (time < 60) {
      timeString = "${time.toInt()} min";
    } else {
      timeString = "${(time / 60).toStringAsFixed(1)} h";
    }

    if (widget.orderActive == false) {
      __indexSectionOrderActive = 0;
      print("SIN ANUNCIO DE ORDENA");
    } else {
      __indexSectionOrderActive = 1;
      print("CON ANUNCIO DE ORDENA");
      // _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      //   ++count;
      //   print(count);
      //   // setState(() {

      //   // });
      // });
    }

    List<Widget> orderActiveSectionContainer = [
      Center(
        child: Container(
          child: Icon(
            Icons.hide_source,
            color: Colors.grey.shade300,
            size: 70,
          ),
        ),
      ),
      Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: 1),
            color: Colors.white,
            borderRadius: BorderRadius.circular(10)),
        width: MediaQuery.of(context).size.width,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          // color: Colors.amber,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(5),
                  //  color: Colors.blue,
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inverseSurface,
                                  size: 18,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.24,
                                    child: Text(
                                      widget.orderActiveInfo.place,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .inverseSurface,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: Text(
                                        timeString,
                                        style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: Icon(
                                        Icons.access_time_rounded,
                                        color: Colors.grey.shade600,
                                        size: 18,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: Text(
                                        "${widget.orderActiveInfo.price} Mxn",
                                        style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                      ),
                                    ),
                                    Icon(
                                      Icons.attach_money_rounded,
                                      color: Colors.grey.shade600,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                await widget.getProductosSeleccionadosDB
                                    .call(widget.orderActiveInfo.productos);
                                await widget.getSumaTotalDB.call(
                                    double.parse(widget.orderActiveInfo.price));
                                widget.chIndexOrderActive.call();
                              },
                              // ignore: sort_child_properties_last
                              child: const Text(
                                "Ver detalles",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                widget.actualizarOrderA.call();
                                await updateDB({}, widget.matricula);
                                widget.sharedChangeNotifier.OrderCancel();
                              },
                              // ignore: sort_child_properties_last
                              child: const Text(
                                "Cancelar",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.only(left: 33, right: 33),
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height * 0.2,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, width: 2),
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.only(bottom: 30),
      width: MediaQuery.of(context).size.width * 0.83,
      child: Container(
        child: orderActiveSectionContainer[__indexSectionOrderActive],
      ),
    );
  }
}

// ignore: must_be_immutable
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
