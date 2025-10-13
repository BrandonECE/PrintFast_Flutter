import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:printfast_rebuild/domain/entities/entities.dart';
import 'package:printfast_rebuild/domain/services/copyshop_service.dart';

class CopyshopServiceImpl extends CopyshopService {
  final FirebaseFirestore _firestore;

  CopyshopServiceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<CopyShopEntity> getCopyShopInfo(String adminLocationByEmail) async {
    try {
      final docRef = _firestore.collection('copyshops').doc(adminLocationByEmail);

      // Forzar lectura desde servidor para detectar falta de conexión inmediatamente
      final snapshot = await docRef.get(const GetOptions(source: Source.server));

      if (!snapshot.exists) {
        return Future.error('No se encontró el copyshop para: $adminLocationByEmail');
      }

      final data = snapshot.data();
      if (data == null) {
        return Future.error('Documento vacío para: $adminLocationByEmail');
      }

      // Mapear de forma segura a Map<String, dynamic>
      final Map<String, dynamic> map = Map<String, dynamic>.from(data);
      return CopyShopEntity.fromMap(map);
    } on FirebaseException catch (e) {
      // Errores de Firebase (por ejemplo problemas de permisos o conexión)
      return Future.error('Firebase error obteniendo copyshop: ${e.code} ${e.message}');
    } catch (e) {
      // Otros errores inesperados
      return Future.error('Error obteniendo copyshop: $e');
    }
  }
}
