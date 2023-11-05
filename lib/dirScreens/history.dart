import 'package:flutter/material.dart';
import 'package:print_fast/dirScreens/orderHistoryInfo.dart';
import 'package:print_fast/sharedviewmodel.dart';

// ignore: must_be_immutable
class myHistory extends StatelessWidget {
  myHistory(
      {super.key,
      required this.sharedChangeNotifier,
      // required this.orderHistoryInfo,
      required this.getOrderHistoryScreen,
      required this.chIndexOrderHistory});
  VoidCallback chIndexOrderHistory;
  Function(myOrderHistoryInfo) getOrderHistoryScreen;
  SharedChangeNotifier sharedChangeNotifier;
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
        child: containerMyHistory(
            // orderHistoryInfo: orderHistoryInfo,
            sharedChangeNotifier: sharedChangeNotifier,
            getOrderHistoryScreen: getOrderHistoryScreen,
            chIndexOrderHistory: chIndexOrderHistory),
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

// ignore: must_be_immutable
class containerMyHistory extends StatelessWidget {
  containerMyHistory(
      {super.key,
      // required this.orderHistoryInfo,
      required this.getOrderHistoryScreen,
      required this.chIndexOrderHistory,required this.sharedChangeNotifier});
  SharedChangeNotifier sharedChangeNotifier;
  VoidCallback chIndexOrderHistory;
  Function(myOrderHistoryInfo) getOrderHistoryScreen;
  // List<myOrderHistoryInfo> orderHistoryInfo;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        titlesContainer("Ordenes"),
        sectionContainerMyHistory(
          sharedChangeNotifier: sharedChangeNotifier,
            // orderHistoryInfo: orderHistoryInfo,
            getOrderHistoryScreen: getOrderHistoryScreen,
            chIndexOrderHistory: chIndexOrderHistory),
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

// // ignore: must_be_immutable
// class sectionContainerMyHistoryOrder extends StatelessWidget {
//   sectionContainerMyHistoryOrder({super.key, required this.fecha});
//   String fecha;
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Container(
//           alignment: Alignment.center,
//           padding: const EdgeInsets.all(10),
//           decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey.shade600),
//               color: Theme.of(context).colorScheme.primary,
//               borderRadius: BorderRadius.circular(10)),
//           width: MediaQuery.of(context).size.width,
//           child: Text(
//             fecha,
//             style: const TextStyle(
//                 color: Colors.white, fontWeight: FontWeight.bold),
//           ),
//         ),
//         const SizedBox(
//           height: 10,
//         ),
//         Container(
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey.shade400),
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(10)),
//           width: MediaQuery.of(context).size.width,
//           height: 85,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   Text(
//                     "24/7",
//                     style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Theme.of(context).colorScheme.inverseSurface),
//                   ),
//                   const SizedBox(
//                     width: 4,
//                   ),
//                   Icon(
//                     Icons.location_on_rounded,
//                     color: Theme.of(context).colorScheme.inverseSurface,
//                     size: 18,
//                   )
//                 ],
//               ),
//               Text(
//                 "300\$",
//                 style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: Theme.of(context).colorScheme.inverseSurface),
//               ),
//               ElevatedButton(
//                   onPressed: () {},
//                   style: ElevatedButton.styleFrom(
//                       onPrimary: Colors.white,
//                       primary: Theme.of(context).colorScheme.primary,
//                       shape: const RoundedRectangleBorder(
//                           borderRadius: BorderRadius.all(Radius.circular(15)))),
//                   child: const Icon(Icons.remove_red_eye))
//             ],
//           ),
//         ),
//         const SizedBox(
//           height: 20,
//         ),
//       ],
//     );
//   }
// }

// ignore: must_be_immutable
class sectionContainerMyHistory extends StatelessWidget {
  sectionContainerMyHistory(
      {super.key,
      // required this.orderHistoryInfo,
      required this.getOrderHistoryScreen,
      required this.chIndexOrderHistory,required this.sharedChangeNotifier});
  SharedChangeNotifier sharedChangeNotifier;
  VoidCallback chIndexOrderHistory;
  Function(myOrderHistoryInfo) getOrderHistoryScreen;
  // List<myOrderHistoryInfo> orderHistoryInfo;

  @override
  Widget build(BuildContext context) {

    Widget content = const Center(
              child: CircularProgressIndicator(
                strokeWidth: 5,
              ),
            );


    if (sharedChangeNotifier.sharedorderHistoryInfo.value.length != 0 && sharedChangeNotifier.sharedIsThereOrderHistoryInfo.value == true ) {
      content = ListView.builder(
        itemCount: sharedChangeNotifier.sharedorderHistoryInfo.value.length,
        itemBuilder: (context, index) {
          return Column(
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
                  sharedChangeNotifier.sharedorderHistoryInfo.value[index].dateTimeComplete,
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
                height: 85,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          sharedChangeNotifier.sharedorderHistoryInfo.value[index].place,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).colorScheme.inverseSurface),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Icon(
                          Icons.location_on_rounded,
                          color: Theme.of(context).colorScheme.inverseSurface,
                          size: 18,
                        )
                      ],
                    ),
                    Text(
                      "${sharedChangeNotifier.sharedorderHistoryInfo.value[index].price}\$",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.inverseSurface),
                    ),
                    ElevatedButton(
                        onPressed: () {
                          getOrderHistoryScreen.call(sharedChangeNotifier.sharedorderHistoryInfo.value[index]);
                          chIndexOrderHistory.call();
                        },
                        style: ElevatedButton.styleFrom(
                            onPrimary: Colors.white,
                            primary: Theme.of(context).colorScheme.primary,
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)))),
                        child: const Icon(Icons.remove_red_eye))
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          );
        },
      );
    }
    else if(sharedChangeNotifier.sharedorderHistoryInfo.value.length == 0 && sharedChangeNotifier.sharedIsThereOrderHistoryInfo.value == true){
      content = Icon(
      Icons.hide_source,
      color: Colors.grey.shade300,
      size: 100,
    );
    
    }

    return Expanded(
        child: Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 25),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 2),
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20)),
            width: MediaQuery.of(context).size.width * 0.83,
            child: content ));
  }
}
