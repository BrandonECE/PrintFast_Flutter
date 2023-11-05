import 'package:flutter/material.dart';
import 'package:print_fast/dirScreens/orderActive.dart';
import 'package:print_fast/dirScreens/orderHistoryInfo.dart';

// ignore: must_be_immutable
class myHistoryOrder extends StatelessWidget {
  myHistoryOrder({super.key, required this.orderHistoryInfoScreen});
  
  myOrderHistoryInfo orderHistoryInfoScreen;
    List<Widget> productos = [
        // itemProductImpresion(
        //   howMany: "2",
        //   product: "Impresiones",
        // ),
        // itemProductNormal(
        //   howMany: "2",
        //   product: "Cartulinas",
        // ),
      ];
  @override
  Widget build(BuildContext context) {
    orderHistoryInfoScreen.productos.forEach((key, value) {
      if (key == "Impresiones" && int.parse(value) != 0) {
        productos.insert(
            0,
            itemProductImpresion(
              product: key,
              howMany: value,
            ));
      } else {
        if (int.parse(value) != 0) {
          productos.add(itemProductNormal(howMany: value, product: key));
        }
      }
    });

    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width * 0.95,
            // ignore: sort_child_properties_last
            child: Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        "ORDENADO",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).colorScheme.inverseSurface),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_drop_down,
                      size: 25,
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Row(
                    children: [
                      Container(
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month),
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(
                                orderHistoryInfoScreen.dateInit,
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inverseSurface,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 10),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time_outlined),
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(
                                orderHistoryInfoScreen.dateTimeInit,
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inverseSurface,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10, top: 10),
                      child: Text(
                        "FINALIZADO",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).colorScheme.inverseSurface),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_drop_down,
                      size: 25,
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Row(
                    children: [
                      Container(
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month),
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(
                                orderHistoryInfoScreen.dateFinal,
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inverseSurface,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 10),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time_outlined),
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(
                                orderHistoryInfoScreen.dateTimeFinal,
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inverseSurface,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            //  padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(20))),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.width * 0.03,
          ),
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.95,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(20))
                  // borderRadius: BorderRadius.only(
                  //     topLeft: Radius.circular(20), topRight: Radius.circular(20))

                  ),
              child: Column(
                children: [
                  titlesContainer("PRODUCTOS"),
                  Expanded(
                      child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20))),
                    width: MediaQuery.of(context).size.width * 0.83,
                    child: ListView(children: productos),
                  )),
                  Container(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.78,
                      margin: const EdgeInsets.only(bottom: 30, top: 10),
                      child: Text(
                        "Total: ${orderHistoryInfoScreen.price} \$",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inverseSurface,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class myAppBarHistoryOrder extends StatelessWidget {
  ///PRUEBA

  myAppBarHistoryOrder({super.key, required this.chindex});
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
