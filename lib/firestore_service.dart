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
    "AOrden": {"Compras": {}, "Time": "0", "Place": "---", "Price": "0"}
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
