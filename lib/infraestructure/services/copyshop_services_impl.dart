import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:printfast_rebuild/domain/entities/entities.dart';
import 'package:printfast_rebuild/domain/services/copyshop_services.dart';

class CopyshopServicesImpl extends CopyshopServices{
  final FirebaseFirestore _firestore;

  CopyshopServicesImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<CopyShopEntity> getCopyShopInfo(String adminLocationByEmail) async {
    try {
      final docRef = _firestore.collection('copyshops').doc(adminLocationByEmail);
      final snapshot = await docRef.get();

      if (!snapshot.exists) {
        return Future.error(Exception('No se encontró el copyshop para: $adminLocationByEmail'));
      }

      final data = snapshot.data();
      if (data == null) {
        return Future.error(Exception('Documento vacío para: $adminLocationByEmail'));
      }

      return CopyShopEntity.fromMap(Map<String, dynamic>.from(data));
    } catch (e) {
      return Future.error(e);
    }
  }
}
