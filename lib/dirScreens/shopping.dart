import 'dart:io';
import 'dart:typed_data';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import 'package:pdf_render/pdf_render_widgets.dart';
import 'package:print_fast/dirScreens/shoppingitemproduct.dart';
import 'history.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf_render/pdf_render.dart';
// import 'package:pdf/pdf.dart' as pdfLib;

// ignore: must_be_immutable
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
        child:
            containerMyShopping(chIndexButtonLocation: chIndexButtonLocation),
      ),
    );
  }
}

// ignore: must_be_immutable
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

// ignore: must_be_immutable
class containerMyShopping extends StatefulWidget {
  containerMyShopping({super.key, required this.chIndexButtonLocation});
  VoidCallback chIndexButtonLocation;

  @override
  State<containerMyShopping> createState() => _containerMyShoppingState();
}

class _containerMyShoppingState extends State<containerMyShopping> {
  List<myItemProduct> MyShoppingItems = [
    myItemProduct("Cartulina", 18, 0),
    myItemProduct("Folders", 12, 0),
    myItemProduct("Hojas", 1, 0),
    myItemProduct("Plumas", 15, 0),
  ];
  Map productosSeleccionados = {};

  FilePickerResult? result;
  double sumaTotalImpresion = 0;
  int sectionCopyWidgetsIndex = 0;
  int countPagesDocumentCopy = 0;

  @override
  Widget build(BuildContext context) {
    if (result != null) {
      productosSeleccionados.addAll({"Impresion": "1"});
    } else
      {productosSeleccionados.addAll({"Impresion": "0"});}

    for (var items in MyShoppingItems) {
      productosSeleccionados[items.name] = items.howMany.toString();
    }

    double sumaTotal = 0;
    for (var product in MyShoppingItems) {
      sumaTotal += (product.howMany * product.price);
    }
    sumaTotal = sumaTotal + sumaTotalImpresion;

    void getTotal() {
      setState(() {});
    }

    void getFile() async {
      result = await FilePicker.platform.pickFiles();
      if (result != null) {
        if (result!.files.first.extension == "PDF" ||
            result!.files.first.extension == "pdf") {
          print("Subiendo");
          final file = await result!.files.first;
          final File filePath = await File(file.path!);
          final List<int> bytes = await filePath.readAsBytes();
          PdfDocument pdfdoc =
              await PdfDocument.openData(Uint8List.fromList(bytes));
          print('El PDF tiene ${pdfdoc.pageCount} páginas.');
          sumaTotalImpresion += pdfdoc.pageCount * 2;
          countPagesDocumentCopy = pdfdoc.pageCount;
          print(sumaTotalImpresion);
          sectionCopyWidgetsIndex = 1;
          getTotal();
        } else {
          print("NO Subiendo");
        }
      }
    }

    void removeFile() async {
      result = null;
      sumaTotalImpresion = 0;
      sectionCopyWidgetsIndex = 0;
      getTotal();
    }

    void setResta(int index) {
      if (MyShoppingItems[index].howMany > 0) {
        MyShoppingItems[index].howMany -= 1;
      }
      getTotal();
    }

    void setSuma(int index) {
      MyShoppingItems[index].howMany += 1;
      getTotal();
    }

    List<Widget> sectionCopyWidgets = [
      sectionContainerMyShoppingCopy(
        callGetFile: () => getFile(),
      ),
      sectionContainerMyShoppingCopyCheck(
        callRemoveFile: () => removeFile(),
        countPagesDocumentCopy: countPagesDocumentCopy,
      ),
    ];

    return Column(
      children: <Widget>[
        titlesContainer("Impresion"),
        sectionCopyWidgets[sectionCopyWidgetsIndex],
        titlesContainer("Materiales"),
        Expanded(
          child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: const BorderRadius.all(Radius.circular(20))),
              width: MediaQuery.of(context).size.width * 0.83,
              child: ListView.builder(
                itemCount: MyShoppingItems.length,
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    width: MediaQuery.of(context).size.width,
                    height: 85,
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
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
                                      "${MyShoppingItems[index].name}",
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .inverseSurface,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                    Text(
                                      "${MyShoppingItems[index].price} \$",
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .inverseSurface,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )),
                          Container(
                            child: Row(children: [
                              ElevatedButton(
                                onPressed: () {
                                  setResta(index);
                                },
                                style: ButtonStyle(
                                  fixedSize: MaterialStateProperty.all<Size>(
                                    const Size(20, 20),
                                  ),
                                  backgroundColor: MaterialStateProperty.all<
                                          Color>(
                                      Theme.of(context).colorScheme.primary),
                                  shape:
                                      MaterialStateProperty.all<OutlinedBorder>(
                                          const CircleBorder()),
                                ),
                                child: const Text(
                                  "-",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                alignment: Alignment.center,
                                height: 40,
                                width: 35,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(5)),
                                ),
                                child: Text(
                                  "${MyShoppingItems[index].howMany}",
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .inverseSurface,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  // print(MyShoppingItems[index].howMany);
                                  setSuma(index);
                                },
                                style: ButtonStyle(
                                  fixedSize: MaterialStateProperty.all<Size>(
                                    const Size(20, 20),
                                  ),
                                  backgroundColor: MaterialStateProperty.all<
                                          Color>(
                                      Theme.of(context).colorScheme.primary),
                                  shape:
                                      MaterialStateProperty.all<OutlinedBorder>(
                                          CircleBorder()),
                                ),
                                child: const Text(
                                  "+",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ]),
                          )
                        ]),
                  );
                },
              )),
        ),
        sectionContainerMyShoppingInfo(
            chIndexButtonLocation: widget.chIndexButtonLocation,
            sumaTotal: sumaTotal),
      ],
    );
  }
}

// ignore: must_be_immutable
class sectionContainerMyShoppingCopy extends StatelessWidget {
  sectionContainerMyShoppingCopy({super.key, required this.callGetFile});
  VoidCallback callGetFile;
  @override
  Widget build(BuildContext context) {
    List<Widget> ordersSectionContainerMyHistory = [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        width: MediaQuery.of(context).size.width,
        height: 85,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(
              child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: Row(
                        children: [
                          Text(
                            "Impresion",
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .inverseSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                          Text(
                            " (PDF)",
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .inverseSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "2 \$/pg",
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
            child: ElevatedButton(
                onPressed: callGetFile,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  primary: Theme.of(context)
                      .colorScheme
                      .primary, // Hace el botón transparente
                  elevation: 0, // Quita la sombra del botón
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        15), // Define el radio de los bordes
                  ),
                ),
                child: Icon(
                  Icons.drive_folder_upload_rounded,
                  color: Colors.white,
                )),
          )
        ]),
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

// ignore: must_be_immutable
class sectionContainerMyShoppingCopyCheck extends StatelessWidget {
  sectionContainerMyShoppingCopyCheck(
      {super.key,
      required this.callRemoveFile,
      required this.countPagesDocumentCopy});
  int countPagesDocumentCopy;
  VoidCallback callRemoveFile;
  @override
  Widget build(BuildContext context) {
    List<Widget> ordersSectionContainerMyHistory = [
      Container(
        padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        width: MediaQuery.of(context).size.width,
        height: 85,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(
              child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: Row(
                        children: [
                          Text(
                            "Impresion",
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .inverseSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                          Row(
                            children: [
                              Text(
                                " (PDF)",
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .inverseSurface,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 9),
                              ),
                              Icon(
                                Icons.check,
                                size: 15,
                                color: Theme.of(context)
                                    .colorScheme
                                    .inverseSurface,
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "2 \$/pg",
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
          Expanded(
            child: Container(
              // color: Colors.amber,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 1),
                    child: Text(
                      "Pg: ${countPagesDocumentCopy}",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.inverseSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ),
                  ElevatedButton(
                      onPressed: callRemoveFile,
                      style: ElevatedButton.styleFrom(
                        primary: Colors.redAccent, // Hace el botón transparente
                        elevation: 0, // Quita la sombra del botón
                        shape: const CircleBorder(),
                      ),
                      child: const Icon(
                        Icons.clear_outlined,
                        color: Colors.white,
                      )),
                ],
              ),
            ),
          )
        ]),
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

// ignore: must_be_immutable
class sectionContainerMyShoppingInfoPrice extends StatelessWidget {
  sectionContainerMyShoppingInfoPrice({super.key, required this.sumaTotal});
  double sumaTotal;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        "Total: $sumaTotal \$",
        style: TextStyle(
          color: Theme.of(context).colorScheme.inverseSurface,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class sectionContainerMyShoppingInfoButton extends StatelessWidget {
  sectionContainerMyShoppingInfoButton(
      {super.key, required this.chIndexButtonLocation});
  VoidCallback chIndexButtonLocation;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: chIndexButtonLocation,
      // ignore: sort_child_properties_last
      child: const Text(
        "Localizar",
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

// ignore: camel_case_types
class sectionContainerMyShoppingInfoButtonDisabled extends StatelessWidget {
  const sectionContainerMyShoppingInfoButtonDisabled({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      // ignore: sort_child_properties_last
      child: const Text(
        "Localizar",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.greenAccent.shade100,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class sectionContainerMyShoppingInfo extends StatelessWidget {
  sectionContainerMyShoppingInfo(
      {super.key,
      required this.chIndexButtonLocation,
      required this.sumaTotal});
  VoidCallback chIndexButtonLocation;
  int ButtonWidgetIndex = 0;
  double sumaTotal;

  @override
  Widget build(BuildContext context) {
    if (sumaTotal != 0) {
      ButtonWidgetIndex = 1;
    }

    List<Widget> buttons = [
      const sectionContainerMyShoppingInfoButtonDisabled(),
      sectionContainerMyShoppingInfoButton(
          chIndexButtonLocation: chIndexButtonLocation)
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      width: MediaQuery.of(context).size.width * 0.83,
      // color: Colors.amber,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          sectionContainerMyShoppingInfoPrice(sumaTotal: sumaTotal),
          buttons[ButtonWidgetIndex],
        ],
      ),
    );
  }
}

// ignore: camel_case_types
class sectionContainerMyShoppingItemsBuilder extends StatelessWidget {
  sectionContainerMyShoppingItemsBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    List<myItemProduct> MyShoppingItems = [
      myItemProduct("Cartulina", 18, 0),
      myItemProduct("Folders", 12, 0),
      myItemProduct("Hojas", 2, 0),
      myItemProduct("Plumas", 15, 0),
    ];

    // ignore: unused_local_variable
    double suma = 0;
    for (var product in MyShoppingItems) {
      suma = product.howMany * product.price;
    }

    return Expanded(
      child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: const BorderRadius.all(Radius.circular(20))),
          width: MediaQuery.of(context).size.width * 0.83,
          child: ListView.builder(
            itemCount: MyShoppingItems.length,
            itemBuilder: (context, index) {
              return sectionContainerMyShoppingWidgetItem(
                name: MyShoppingItems[index].name,
                price: MyShoppingItems[index].price,
                howMany: MyShoppingItems[index].howMany,
              );
            },
          )),
    );
  }
}

// ignore: must_be_immutable
class sectionContainerMyShoppingWidgetItem extends StatelessWidget {
  sectionContainerMyShoppingWidgetItem(
      {super.key,
      required this.name,
      required this.price,
      required this.howMany});
  String name;
  int howMany;
  double price;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10)),
      width: MediaQuery.of(context).size.width,
      height: 85,
      margin: EdgeInsets.only(bottom: 20),
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
                    "$name",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.inverseSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                  Text(
                    "$price \$",
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
        Container(
          child: Row(children: [
            ElevatedButton(
              onPressed: () {
                print("Restar");
              },
              style: ButtonStyle(
                fixedSize: MaterialStateProperty.all<Size>(
                  Size(20, 20),
                ),
                backgroundColor: MaterialStateProperty.all<Color>(
                    Theme.of(context).colorScheme.primary),
                shape:
                    MaterialStateProperty.all<OutlinedBorder>(CircleBorder()),
              ),
              child: const Text(
                "-",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              alignment: Alignment.center,
              height: 40,
              width: 35,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              child: Text(
                "$howMany",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.inverseSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                print("Sumar");
              },
              style: ButtonStyle(
                fixedSize: MaterialStateProperty.all<Size>(
                  Size(20, 20),
                ),
                backgroundColor: MaterialStateProperty.all<Color>(
                    Theme.of(context).colorScheme.primary),
                shape:
                    MaterialStateProperty.all<OutlinedBorder>(CircleBorder()),
              ),
              child: Text(
                "+",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ]),
        )
      ]),
    );
  }
}
