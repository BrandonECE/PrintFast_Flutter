import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:printfast_rebuild/domain/entities/entities.dart';
import 'package:printfast_rebuild/domain/services/user_service.dart';

class UserServiceImpl extends UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<UserEntity> getUserInfo(String registration) async {
    try {
      final doc = await _firestore.collection('users').doc(registration).get();

      if (!doc.exists) return Future.error("No existe el usuario.");

      // Convertir los datos del documento a UserEntity
      return UserEntity.fromMap(doc.data()!);
    } catch (e) {
      return Future.error("Error obteniendo info del usuario: $e");
    }
  }

  @override
  Future<void> setNewUser(UserEntity userEntity) async {
    try {
      final userDocRef = _firestore
          .collection('users')
          .doc(userEntity.registration);

      // 1) Documento principal del usuario
      await userDocRef.set({
        'email': userEntity.email,
        'name': userEntity.name,
        'phone': userEntity.phone,
        'registration': userEntity.registration,
      }, SetOptions(merge: true));

      // 2) notifications -> information { items: [] }
      final notificationsRef = userDocRef
          .collection('notifications')
          .doc('information');
      await notificationsRef.set({
        'items': <Map<String, dynamic>>[], // lista vacía de mapas
      }, SetOptions(merge: true));

      // 3) horders -> information { items: [] }
      final hordersRef = userDocRef.collection('horders').doc('information');
      await hordersRef.set({
        'items': <Map<String, dynamic>>[], // lista vacía de mapas
      }, SetOptions(merge: true));

      // 4) aorder -> information { specifications: {} }
      final aorderRef = userDocRef.collection('aorder').doc('information');
      await aorderRef.set({
        'specifications': <String, dynamic>{}, // mapa vacío
      }, SetOptions(merge: true));

      return;
    } catch (e) {
      // Usamos Future.error como pediste
      return Future.error("Error creando el usuario: $e");
    }
  }

  @override
  Future<bool> registrationExists(String registration) async {
    try {
      final doc = await _firestore.collection('users').doc(registration).get();
      return doc.exists;
    } catch (e) {
      return Future.error('Error verificando existencia en Firestore: $e');
    }
  }

  @override
  Future<List<HorderEntity>> getHOrders(String registration) async {
    try {
      final docRef = _firestore
          .collection('users')
          .doc(registration)
          .collection('horders')
          .doc('information');

      final snap = await docRef.get();

      if (!snap.exists) {
        // Si no existe, devolvemos lista vacía (podrías preferir Future.error)
        return <HorderEntity>[];
      }

      final data = snap.data() ?? {};
      final rawList = List.from(data['items'] ?? []);

      final List<HorderEntity> result = rawList.map<HorderEntity>((raw) {
        if (raw is Map<String, dynamic>) {
          return HorderEntity.fromMap(raw);
        } else if (raw is Map) {
          return HorderEntity.fromMap(Map<String, dynamic>.from(raw));
        } else {
          // si viene en un formato inesperado, devolvemos un objeto vacío razonable
          return HorderEntity.fromMap({});
        }
      }).toList();

      return result;
    } catch (e) {
      return Future.error('Error obteniendo horders: $e');
    }
  }
  
  @override
  Future<List<NotificationEntity>> getNotifications(String registration) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(registration)
          .collection('notifications')
          .doc('information');

      final snap = await docRef.get();

      if (!snap.exists) {
        // si no existe el doc devolvemos lista vacía
        return <NotificationEntity>[];
      }

      final data = snap.data() ?? {};
      final rawList = List.from(data['items'] ?? []);

      final List<NotificationEntity> result = rawList.map<NotificationEntity>((raw) {
        if (raw is Map<String, dynamic>) {
          return NotificationEntity.fromMap(raw);
        } else if (raw is Map) {
          return NotificationEntity.fromMap(Map<String, dynamic>.from(raw));
        } else {
          // formato inesperado -> devolver entidad con valores por defecto
          return NotificationEntity.fromMap({});
        }
      }).toList();

      return result;
    } catch (e) {
      return Future.error('Error obteniendo notifications: $e');
    }
  }
  
  @override
  Stream<int> unseenNotificationsCount(String registration) {
    try {
      return _firestore
          .collection('notifications')
          .where('registration', isEqualTo: registration)
          .where('seen', isEqualTo: false)
          .snapshots()
          .map((snapshot) => snapshot.docs.length);
    } catch (e) {
      // Devolvemos un Stream que emite 0 si hay error
      return Stream.value(0);
    }
  }
  
  @override
  Stream<AorderEntity?> getAordersStream(String registration) {
    try {
      return _firestore
          .collection('users')
          .doc(registration)
          .collection('aorder')
          .doc('information')
          .snapshots()
          .map((snapshot) {
            // Si no existe el documento, significa que no hay orden activa
            if (!snapshot.exists) return null;

            final data = snapshot.data();
            // Si no hay data o specifications, significa que tampoco hay orden activa
            if (data == null || !data.containsKey('specifications')) return null;

            // Extraemos specifications y convertimos a entidad
            final specifications = Map<String, dynamic>.from(data['specifications']);
            return AorderEntity.fromMap(specifications);
          })
          .handleError((error) {
            // Aquí atrapamos errores de conexión o de Firebase
            throw Exception("Error obteniendo la orden activa: $error");
          });
    } catch (e) {
      // Si el problema ocurre antes de inicializar el stream
      return Stream.error("Error iniciando el stream: $e");
    }
  }

}
