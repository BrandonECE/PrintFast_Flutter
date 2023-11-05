import 'dart:isolate';

import 'package:print_fast/dirScreens/orderHistoryInfo.dart';
import 'package:print_fast/dirScreens/orderNotificationInfo.dart';

class IsolateNotifsParametros {
  Map notis;
  SendPort sendPort;
  IsolateNotifsParametros(this.sendPort, this.notis);
}

void isolateNotifs(IsolateNotifsParametros parametros) async {
  int countNotis = 0;
  await Future.delayed(
    const Duration(seconds: 1),
    () {
      parametros.notis.forEach((nNoti, valueNoti) {
        valueNoti.forEach((parametro, valueP) {
          if (parametro == "vista") {
            if (valueP == false) {
              ++countNotis;
            }
          }
        });
      });
    },
  );

  parametros.sendPort.send(countNotis);
}

///

class IsolateOrdersHistoryOrdenar {
  Map historyOrders;
  SendPort sendPort;
  IsolateOrdersHistoryOrdenar(this.historyOrders, this.sendPort);
}

void isolateOrdersHistoryOrdenar(IsolateOrdersHistoryOrdenar parametros) async {
  int count = 1;

  List<myOrderHistoryInfo> orderHistoryInfo = [];
  int countBucle = parametros.historyOrders.length;
  if (parametros.historyOrders.isNotEmpty) {
    while (countBucle != 0) {
      if (countBucle != 0) {
        parametros.historyOrders.forEach((nOrderH, valueOrderH) {
          if (int.parse(nOrderH) == count) {
            String place = "";
            String price = "";
            String time = "";
            String dateInit = "";
            String dateTimeInit = "";
            String dateFinal = "";
            String dateTimeFinal = "";
            String dateTimeComplete = "";
            Map productos = {};

            valueOrderH.forEach((paramOrderH, paramInfoOrderH) {
              if (paramOrderH == "Place") place = paramInfoOrderH;
              if (paramOrderH == "Price") price = paramInfoOrderH;
              if (paramOrderH == "Time") time = paramInfoOrderH;
              if (paramOrderH == "Compras") productos = paramInfoOrderH;
              if (paramOrderH == "initDate") dateInit = paramInfoOrderH;
              if (paramOrderH == "initDateTime") dateTimeInit = paramInfoOrderH;
              if (paramOrderH == "finalDate") dateFinal = paramInfoOrderH;
              if (paramOrderH == "finalDateTime")
                dateTimeFinal = paramInfoOrderH;
              if (paramOrderH == "initDateComplete")
                dateTimeComplete = paramInfoOrderH;
            });
            orderHistoryInfo.add(myOrderHistoryInfo(
                place,
                price,
                time,
                productos,
                dateInit,
                dateTimeInit,
                dateFinal,
                dateTimeFinal,
                dateTimeComplete));

            ++count;
          }
        });
      }
      --countBucle;
    }
    orderHistoryInfo = orderHistoryInfo.reversed.toList();
  }

  parametros.sendPort.send(orderHistoryInfo);
}

///

class IsolateNotificationInfo {
  Map noti;
  SendPort sendPort;
  IsolateNotificationInfo(this.noti, this.sendPort);
}

void isolateNotificationInfo(IsolateNotificationInfo parametros) async {
  int count = 1;

  List<myOrderNotificationInfo> notisInfo = [];
  int countBucle = parametros.noti.length;
  if (parametros.noti.isNotEmpty) {
    while (countBucle != 0) {
      if (countBucle != 0) {
        parametros.noti.forEach((nNoti, valueNoti) {
          if (int.parse(nNoti) == count) {
            String asunto = "";
            String msj = "";
            String date = "";
            String time = "";
            // ignore: unused_local_variable
            bool vista = false;

            valueNoti.forEach((paraNoti, paramInfoNoti) {
              if (paraNoti == "asunto") asunto = paramInfoNoti;
              if (paraNoti == "date") date = paramInfoNoti;
              if (paraNoti == "msj") msj = paramInfoNoti;
              if (paraNoti == "time") time = paramInfoNoti;
              if (paraNoti == "vista") vista = paramInfoNoti;
            });
            notisInfo
                .add(myOrderNotificationInfo(asunto, msj, date, time, vista));

            ++count;
          }
        });
      }
      --countBucle;
    }
    notisInfo = notisInfo.reversed.toList();
  }

  parametros.sendPort.send(notisInfo);
}

///

class IsolateDeleteNotification {
  int index;
  Map noti;
  SendPort sendPort;
  IsolateDeleteNotification(this.noti, this.sendPort, this.index);
}

void isolateDeleteNotification(IsolateDeleteNotification parametros) async {
  int count = 1;
  List<myOrderNotificationInfo> notisInfo = [];
  int countBucle = parametros.noti.length;
  if (parametros.noti.isNotEmpty) {
    while (countBucle != 0) {
      if (countBucle != 0) {
        parametros.noti.forEach((nNoti, valueNoti) {
          if (int.parse(nNoti) == count) {
            String asunto = "";
            String msj = "";
            String date = "";
            String time = "";
            // ignore: unused_local_variable
            bool vista = false;

            valueNoti.forEach((paraNoti, paramInfoNoti) {
              if (paraNoti == "asunto") asunto = paramInfoNoti;
              if (paraNoti == "date") date = paramInfoNoti;
              if (paraNoti == "msj") msj = paramInfoNoti;
              if (paraNoti == "time") time = paramInfoNoti;
              if (paraNoti == "vista") vista = paramInfoNoti;
            });
            notisInfo
                .add(myOrderNotificationInfo(asunto, msj, date, time, vista));

            ++count;
          }
        });
      }
      --countBucle;
    }
    notisInfo = notisInfo.reversed.toList();
  }

  print("PASO1");

  notisInfo.removeAt(parametros.index);
  notisInfo = notisInfo.reversed.toList();

  print("PASO2");

  Map notisReordenadas = {};
  count = 1;
  notisInfo.forEach((element) {
    Map value = {
      "asunto": element.asunto,
      "date": element.date,
      "msj": element.msj,
      "time": element.time,
      "vista": element.vista
    };
    notisReordenadas["$count"] = value;
    ++count;
  });

  print("PASO3");

  parametros.sendPort.send(notisReordenadas);
}

///

class IsolateNotisVistas {
  List<myOrderNotificationInfo> listNotis;
  SendPort sendPort;
  IsolateNotisVistas(this.sendPort, this.listNotis);
}

void isolateNotisVistas(IsolateNotisVistas parametros) async {
  List<int> indexOfFireBase = [];
  int count = 1;
  List<myOrderNotificationInfo> listNotis =
      parametros.listNotis.reversed.toList();
  listNotis.forEach((element) {
    if (element.vista == false) {
      indexOfFireBase.add(count);
    }
    ++count;
  });

  parametros.sendPort.send(indexOfFireBase);
}



///
void isolateOrdenA(SendPort sendPort) async {
  await Future.delayed(const Duration(seconds: 2));
  sendPort.send("Listo");
}

void isolateChandeIndexOrden(SendPort sendPort) {
  sendPort.send("Listo");
}