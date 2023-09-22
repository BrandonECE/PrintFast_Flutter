

import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;
String nameColection = "ubicaciones";

Future<Map> getDB(String nameColection) async {
  Map? dbMap;
  CollectionReference collectionReferenceLocation =
      db.collection(nameColection);
  QuerySnapshot queryLocation = await collectionReferenceLocation.get();

  queryLocation.docs.forEach((element) {
    dbMap = element.data() as Map;
  });

  return dbMap!;
}
