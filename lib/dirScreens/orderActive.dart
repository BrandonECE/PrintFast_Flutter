import 'package:flutter/material.dart';

// ignore: camel_case_types, must_be_immutable
class myOrderActiveScreenInfo extends StatelessWidget {
  myOrderActiveScreenInfo(
      {super.key,
      required this.productosSeleccionadosDB,
      required this.sumaTotalDB,
      required this.initDateOrderA,
      required this.initTimeOrderA,
      required this.chIndexLocationDirections});
  double sumaTotalDB;
  VoidCallback chIndexLocationDirections;
  String initDateOrderA;
  String initTimeOrderA;
  Map productosSeleccionadosDB;
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
    productosSeleccionadosDB.forEach((key, value) {
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
                      padding: const EdgeInsets.only(bottom: 5),
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
                                initDateOrderA,
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
                                initTimeOrderA,
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
                    width: MediaQuery.of(context).size.width * 0.8,
                    margin: const EdgeInsets.only(bottom: 20, top: 5),
                    child: ElevatedButton(
                      onPressed: () {
                        chIndexLocationDirections.call();
                      },
                      // ignore: sort_child_properties_last
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.directions),
                          Padding(
                            padding: EdgeInsets.only(left: 5),
                            child: Text(
                              "Ver dirección",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.78,
                      margin: const EdgeInsets.only(bottom: 30, top: 10),
                      child: Text(
                        "Total: $sumaTotalDB \$",
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
class myAppBarmyOrderActiveScreenInfo extends StatelessWidget {
  ///PRUEBA

  myAppBarmyOrderActiveScreenInfo({super.key, required this.chindex});
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
                  "Orden Activa",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.shopping_basket,
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

// ignore: camel_case_types, must_be_immutable
class itemProductNormal extends StatelessWidget {
  itemProductNormal({super.key, required this.howMany, required this.product});
  String product;
  String howMany;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10)),
      width: MediaQuery.of(context).size.width,
      height: 85,
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(
            child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "PRODUCTO:",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.inverseSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                  Text(
                    product,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.inverseSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                ],
              ),
            ),
          ],
        )),
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Row(
            children: [
              Text(
                "Cant.",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.inverseSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              const SizedBox(
                width: 10,
              ),
              Container(
                alignment: Alignment.center,
                height: 40,
                width: 35,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                ),
                child: Text(
                  howMany,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.inverseSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

// ignore: must_be_immutable
class itemProductImpresion extends StatelessWidget {
  itemProductImpresion(
      {super.key, required this.howMany, required this.product});
  String product;
  String howMany;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10)),
      width: MediaQuery.of(context).size.width,
      height: 85,
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(
            child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "PRODUCTO:",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.inverseSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                  Text(
                    product,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.inverseSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                ],
              ),
            ),
          ],
        )),
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Row(
            children: [
              Text(
                "Pg.",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.inverseSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              const SizedBox(
                width: 10,
              ),
              Container(
                alignment: Alignment.center,
                height: 40,
                width: 35,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                ),
                child: Text(
                  howMany,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.inverseSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
