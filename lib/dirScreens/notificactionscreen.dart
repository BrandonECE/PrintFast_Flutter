import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:print_fast/dirScreens/convertTime.dart';
import 'package:print_fast/dirScreens/isolates.dart';
import 'package:print_fast/firestore_service.dart';
// import 'package:print_fast/dirScreens/orderNotificationInfo.dart';
import 'package:print_fast/sharedviewmodel.dart';

// ignore: must_be_immutable
class NotificationScreens extends StatelessWidget {
  NotificationScreens(
      {super.key,
      required this.sharedChangeNotifier,
      required this.deleteNotification,
      required this.matricula});
  Function(int) deleteNotification;
  String matricula;
  SharedChangeNotifier sharedChangeNotifier;

  // bool verification = false;

  @override
  Widget build(BuildContext context) {
    //   if(verification == false){
    //     verification = true;

    //   }

    Widget content = const Center(
      child: CircularProgressIndicator(
        strokeWidth: 5,
      ),
    );

    if (sharedChangeNotifier.sharedNotificationInfo.value.length != 0 &&
        sharedChangeNotifier.sharedIsThereNotificationInfo.value == true) {
      content = ListView.builder(
        itemCount: sharedChangeNotifier.sharedNotificationInfo.value.length,
        itemBuilder: (context, index) {
          String fecha =
              "${sharedChangeNotifier.sharedNotificationInfo.value[index].date}, ${sharedChangeNotifier.sharedNotificationInfo.value[index].time}";

          if (sharedChangeNotifier.sharedNotificationInfo.value[index].date ==
              ConvertTime().getFecha()) {
            fecha =
                "Hoy, ${sharedChangeNotifier.sharedNotificationInfo.value[index].time}";
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade600),
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(10)),
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    fecha,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  width: MediaQuery.of(context).size.width,
                  height: 90,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(100))),
                          child: const Icon(
                            Icons.shopping_basket,
                            color: Colors.white,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.centerLeft,

                            // color: Colors.amber,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    sharedChangeNotifier.sharedNotificationInfo
                                        .value[index].asunto,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .inverseSurface),
                                  ),
                                  Text(
                                    sharedChangeNotifier.sharedNotificationInfo
                                        .value[index].msj,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .inverseSurface),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(100))),
                          child: IconButton(
                              iconSize: 14,
                              onPressed: () {
                                // deleteNotification(index);
                                deleteNotification.call(index);
                              },
                              icon: const Icon(
                                Icons.clear,
                                color: Colors.white,
                              )),
                        )
                      ]),
                ),
              ],
            ),
          );
        },
      );

      final recivePort = ReceivePort();
      // ignore: unused_local_variable
      final isolate1 = Isolate.spawn(
          isolateNotisVistas,
          IsolateNotisVistas(recivePort.sendPort,
              sharedChangeNotifier.sharedNotificationInfo.value));
      recivePort.listen((message) async {
        try {
          print(message);
          List<int> listaIndex = message as List<int>;
          if (listaIndex.isNotEmpty) {
            await updateNotiVista(listaIndex, matricula);
          }
        } catch (e) {
          print("ERROR AL NOTIFICAR LA VISTA EN LAS NOTIS");
        }
      });
    } else if (sharedChangeNotifier.sharedNotificationInfo.value.length == 0 &&
        sharedChangeNotifier.sharedIsThereNotificationInfo.value == true) {
      content = Icon(
        Icons.hide_source,
        color: Colors.grey.shade300,
        size: 100,
      );
    }

    return Center(
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
              titlesContainer("Todas"),
              Expanded(
                  child: Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(bottom: 25),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.grey.shade300, width: 2),
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20)),
                      width: MediaQuery.of(context).size.width * 0.83,
                      child: content)),
            ],
          )),
    );
  }
}

// ignore: must_be_immutable
class myAppBarNotificationScreens extends StatelessWidget {
  ///PRUEBA

  myAppBarNotificationScreens({super.key, required this.chindex});
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
                  "Notificaciones",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.notifications_sharp,
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
