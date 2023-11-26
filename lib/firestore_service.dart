import 'dart:async';
// ignore: unused_import
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;
// String nameColection = "ubicaciones";

Future<Map> getDB(String nameColection) async {
  Map? dbMap;
  CollectionReference collectionReferenceLocation =
      await db.collection(nameColection);
  QuerySnapshot queryLocation = await collectionReferenceLocation.get();

  queryLocation.docs.forEach((element) {
    dbMap = element.data() as Map;
  });

  return dbMap!;
}

Future<Map> getDBUser(String matricula) async {
  Map? dbMapUser;
  CollectionReference collectionReferenceLocation =
      await db.collection("usuarios");
  DocumentReference userRef = await collectionReferenceLocation.doc(matricula);
  DocumentSnapshot snapShotData = await userRef.get();
  dbMapUser = snapShotData.data() as Map<String, dynamic>;
  return dbMapUser;
}

Future<Map> getDBUserOrderA(String matricula) async {
  Map? dbMapUser;
  Map? dbMapUserOrderA;
  CollectionReference collectionReferenceLocation =
      await db.collection("usuarios");
  DocumentReference userRef = await collectionReferenceLocation.doc(matricula);
  DocumentSnapshot snapShotData = await userRef.get();
  dbMapUser = snapShotData.data() as Map<String, dynamic>;
  dbMapUser.forEach((key, value) {
    if ("AOrden" == key) {
      print(key);
      dbMapUserOrderA = value;
    }
  });
  return dbMapUserOrderA as Map;
}

Future<void> updateDB(Map infoOrder, String matricula) async {
  CollectionReference collectionReferenceLocation =
      await db.collection("usuarios");
  DocumentReference userRef = await collectionReferenceLocation.doc(matricula);
  await userRef.update({
    "AOrden": infoOrder,
  });
}

Future<void> updateDBHistory(Map infoOrder, String matricula) async {
  Map? dbMapUser;
  Map ordenesHistory = {};
  int count = 0;
  CollectionReference collectionReferenceLocation =
      await db.collection("usuarios");
  DocumentReference userRef = await collectionReferenceLocation.doc(matricula);
  DocumentSnapshot snapShotData = await userRef.get();
  dbMapUser = snapShotData.data() as Map<String, dynamic>;

  dbMapUser.forEach((key, value) {
    if ("HOrdenes" == key) {
      // print("KEY: $key -> ValueL $value");
      ordenesHistory = value;
      count = value.length;
    }
  });

  ordenesHistory["${++count}"] = infoOrder;

  await userRef.update({
    "HOrdenes": ordenesHistory,
  });
}

Future<Map> getDBUserOrdersH(String matricula) async {
  Map dbMapUser = {};
  Map dbMapUserOrderA = {};
  CollectionReference collectionReferenceLocation =
      await db.collection("usuarios");
  DocumentReference userRef = await collectionReferenceLocation.doc(matricula);
  DocumentSnapshot snapShotData = await userRef.get();
  dbMapUser = snapShotData.data() as Map<String, dynamic>;
  dbMapUser.forEach((key, value) {
    if ("HOrdenes" == key) {
      print(key);
      dbMapUserOrderA = value;
    }
  });
  return dbMapUserOrderA as Map;
}

Future<Map> getDBUserNotis(String matricula) async {
  Map dbMapUser = {};
  Map dbMapUserNotis = {};
  CollectionReference collectionReferenceLocation =
      await db.collection("usuarios");
  DocumentReference userRef = await collectionReferenceLocation.doc(matricula);
  DocumentSnapshot snapShotData = await userRef.get();
  dbMapUser = snapShotData.data() as Map<String, dynamic>;
  dbMapUser.forEach((key, value) {
    if ("Notificaciones" == key) {
      print(key);
      dbMapUserNotis = value;
    }
  });
  return dbMapUserNotis as Map;
}

Future<void> updateDBUserNotis(Map infoNoti, String matricula) async {
  Map? dbMapUser;
  Map notificaciones = {};
  int count = 0;
  CollectionReference collectionReferenceLocation =
      await db.collection("usuarios");
  DocumentReference userRef = await collectionReferenceLocation.doc(matricula);
  DocumentSnapshot snapShotData = await userRef.get();
  dbMapUser = snapShotData.data() as Map<String, dynamic>;

  dbMapUser.forEach((key, value) {
    if ("Notificaciones" == key) {
      // print("KEY: $key -> ValueL $value");
      notificaciones = value;
      count = value.length;
    }
  });

  notificaciones["${++count}"] = infoNoti;

  await userRef.update({
    "Notificaciones": notificaciones,
  });
}

Future<void> updateNotisDeletedOne(Map infoNoti, String matricula) async {
  // ignore: unused_local_variable
  Map? dbMapUser;

  CollectionReference collectionReferenceLocation =
      await db.collection("usuarios");
  DocumentReference userRef = await collectionReferenceLocation.doc(matricula);
  DocumentSnapshot snapShotData = await userRef.get();
  dbMapUser = snapShotData.data() as Map<String, dynamic>;

  await userRef.update({
    "Notificaciones": infoNoti,
  });
}

Future<void> updateNotiVista(List<int> listaIndex, String matricula) async {
  CollectionReference collectionReferenceLocation =
      await db.collection("usuarios");
  DocumentReference userRef = await collectionReferenceLocation.doc(matricula);

  listaIndex.forEach((element) async {

      await userRef.update({
          "Notificaciones.$element.vista": true,
        });

  });

}

Future<void> updateDBTime(String time, String matricula) async {
  CollectionReference collectionReferenceLocation =
      await db.collection("usuarios");
  DocumentReference userRef = await collectionReferenceLocation.doc(matricula);
  await userRef.update({
    "AOrden.Time": time,
  });
}

Future<void> registeDBUser(
  name,
  matricula,
  email,
  telefono,
  contrasena,
) async {
  Map<String, dynamic> dataUser = {};
  // Map<String, dynamic> compras = {"Compras": {}};
  Map<String, dynamic> noti = {"Notificaciones": {}};
  Map<String, dynamic> ordenesHistorial = {"HOrdenes": {}};
  Map<String, dynamic> ordenActiva = {
    "AOrden": {"Compras": {}}
  };

  dataUser.addAll({"Nombre": name});
  dataUser.addAll({"Matricula": matricula});
  dataUser.addAll({"E-mail": email});
  dataUser.addAll({"Telefono": telefono});
  dataUser.addAll({"Contrasena": contrasena});
  // dataUser.addAll(compras);
  dataUser.addAll(noti);
  dataUser.addAll(ordenesHistorial);
  dataUser.addAll(ordenActiva);

  db.collection('usuarios').doc(matricula).set(dataUser).then((_) {
    print('Usuario agregado con exito');
  });
}
