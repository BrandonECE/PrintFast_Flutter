// lib/data/services/user_service_impl.dart
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:printfast_rebuild/domain/entities/entities.dart';
import 'package:printfast_rebuild/domain/repositories/storage_repository.dart';
import 'package:printfast_rebuild/domain/services/user_service.dart';

class UserServiceImpl extends UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageRepository storageRepository;
  UserServiceImpl({required this.storageRepository});

  @override
  Future<UserEntity> getUserInfo(String registration) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(registration)
          .get(const GetOptions(source: Source.server));

      if (!doc.exists) return Future.error("No existe el usuario.");

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
      await userDocRef.set(userEntity.toMap(), SetOptions(merge: true));

      // 2) notifications -> information { items: [] }
      final notificationsRef = userDocRef
          .collection('notifications')
          .doc('information');
      await notificationsRef.set({
        'items': <Map<String, dynamic>>[],
      }, SetOptions(merge: true));

      // 3) horders -> information { items: [] }
      final hordersRef = userDocRef.collection('horders').doc('information');
      await hordersRef.set({
        'items': <Map<String, dynamic>>[],
      }, SetOptions(merge: true));

      // 4) aorder -> information { specifications: {} }
      final aorderRef = userDocRef.collection('aorder').doc('information');
      await aorderRef.set({
        'specifications': <String, dynamic>{},
      }, SetOptions(merge: true));

      return;
    } catch (e) {
      return Future.error("Error creando el usuario: $e");
    }
  }

  @override
  Future<bool> registrationExists(String registration) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(registration)
          .get(const GetOptions(source: Source.server));
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

      final snap = await docRef.get(const GetOptions(source: Source.server));

      if (!snap.exists) {
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

      final snap = await docRef.get(const GetOptions(source: Source.server));

      if (!snap.exists) {
        return <NotificationEntity>[];
      }

      final data = snap.data() ?? {};
      final rawList = List.from(data['items'] ?? []);

      final List<NotificationEntity> result = rawList.map<NotificationEntity>((
        raw,
      ) {
        if (raw is Map<String, dynamic>) {
          return NotificationEntity.fromMap(raw);
        } else if (raw is Map) {
          return NotificationEntity.fromMap(Map<String, dynamic>.from(raw));
        } else {
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
        .collection('users')
        .doc(registration)
        .collection('notifications')
        .doc('information')
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) {
            return 0;
          }
          
          final data = snapshot.data();
          if (data == null || !data.containsKey('items')) {
            return 0;
          }
          
          final List<dynamic> items = data['items'];
          if (items.isEmpty) {
            return 0;
          }
          
          // Contar las notificaciones no vistas (seen: false)
          final unseenCount = items.where((item) {
            final Map<String, dynamic> notification = item;
            return notification['seen'] == false;
          }).length;
          
          return unseenCount;
        });
  } catch (e) {
    return Stream.error('Error unseenNotificationsCount: $e');
  }
}

  @override
  Stream<AorderEntity?> getAorderStream(String registration) {
    try {
      return _firestore
          .collection('users')
          .doc(registration)
          .collection('aorder')
          .doc('information')
          .snapshots()
          .map((snapshot) {
            // Si el documento no existe -> null
            if (!snapshot.exists) {
              print(
                'getAorderStream: document does not exist for $registration',
              );
              return null;
            }

            final data = snapshot.data();
            // Si no hay data -> null
            if (data == null) {
              print(
                'getAorderStream: snapshot.data() == null for $registration',
              );
              return null;
            }

            // Extraer el campo 'specifications'
            final specsRaw = data['specifications'];

            // Si no existe o es null -> null
            if (specsRaw == null) {
              print(
                'getAorderStream: specifications is null or missing for $registration',
              );
              return null;
            }

            // Si specifications no es un Map -> null (protección contra tipos inesperados)
            if (specsRaw is! Map) {
              print(
                'getAorderStream: specifications is not a Map (type=${specsRaw.runtimeType}) for $registration',
              );
              return null;
            }

            final Map<String, dynamic> specifications =
                Map<String, dynamic>.from(specsRaw);

            // Si el map está vacío -> null
            if (specifications.isEmpty) {
              print(
                'getAorderStream: specifications map is empty for $registration',
              );
              return null;
            }

            // Intentar parsear a AorderEntity; si falla devolvemos null y logeamos
            try {
              return AorderEntity.fromMap(specifications);
            } catch (e, st) {
              print(
                'getAorderStream: error parsing AorderEntity for $registration: $e\n$st',
              );
              return null;
            }
          })
          .handleError((error) {
            // Pasar el error hacia arriba (se mantiene tu manejo anterior)
            print('getAorderStream - stream error: $error');
            throw Exception("Error obteniendo la orden activa: $error");
          });
    } catch (e) {
      print('getAorderStream - exception iniciando el stream: $e');
      return Stream.error("Error iniciando el stream: $e");
    }
  }

  @override
  Future<List<CopyShopEntity>> getCopyShopsWithAorders() async {
    try {
      final colRef = _firestore.collection('copyshops');
      final snapshot = await colRef.get(
        const GetOptions(source: Source.server),
      );

      final docs = snapshot.docs;
      final futures = docs.map((doc) async {
        final data = doc.data();

        final copyShopName = data['copyShopName']?.toString() ?? '';
        final copyShopEmail = data['copyShopEmail']?.toString() ?? doc.id;
        final lat = data['lat']?.toString() ?? '';
        final long = data['long']?.toString() ?? '';
        final pauseReception = data['pauseReception'] is bool
            ? (data['pauseReception'] as bool)
            : (data['pauseReception']?.toString().toLowerCase() == 'true');
        final queue = (data['queue'] ?? 0) is int
            ? (data['queue'] ?? 0) as int
            : int.tryParse('${data['queue'] ?? 0}') ?? 0;

        final baseShop = CopyShopEntity(
          copyShopName: copyShopName,
          lat: lat,
          long: long,
          pauseReception: pauseReception,
          queue: queue,
          copyShopEmail: copyShopEmail,
        );

        final aordersDocRef = colRef
            .doc(doc.id)
            .collection('aorders')
            .doc('information');
        final aordersSnap = await aordersDocRef.get(
          const GetOptions(source: Source.server),
        );

        Map<String, AorderEntity> aordersMap = {};

        if (aordersSnap.exists) {
          final aordersData = aordersSnap.data();
          if (aordersData != null) {
            final dynamic rawOrders =
                aordersData['orders'] ??
                aordersData['items'] ??
                aordersData['aorders'] ??
                {};
            if (rawOrders is Map) {
              final Map<String, dynamic> casted = Map<String, dynamic>.from(
                rawOrders,
              );
              casted.forEach((orderKey, orderValue) {
                try {
                  if (orderValue is Map<String, dynamic>) {
                    aordersMap[orderKey] = AorderEntity.fromMap(orderValue);
                  } else if (orderValue is Map) {
                    aordersMap[orderKey] = AorderEntity.fromMap(
                      Map<String, dynamic>.from(orderValue),
                    );
                  }
                } catch (e) {
                  // ignore malformed order
                }
              });
            }
          }
        }

        return baseShop.copyWith(aorders: aordersMap);
      });

      final List<CopyShopEntity> copyshops = await Future.wait(futures);
      return copyshops;
    } catch (e) {
      return Future.error('Error obteniendo copyshops con aorders: $e');
    }
  }

  @override
  Future<String> generateUniqueOrderCode(
    String copyShopEmail, {
    int length = 4,
  }) async {
    try {
      if (length <= 0) {
        return Future.error('Length debe ser mayor que 0');
      }

      final aordersDocRef = _firestore
          .collection('copyshops')
          .doc(copyShopEmail)
          .collection('aorders')
          .doc('information');

      final aordersSnap = await aordersDocRef.get(
        const GetOptions(source: Source.server),
      );

      final Set<String> existingCodes = <String>{};

      if (aordersSnap.exists) {
        final data = aordersSnap.data();
        if (data != null) {
          final dynamic rawOrders =
              data['orders'] ??
              data['aorders'] ??
              data['items'] ??
              data['specifications'];

          if (rawOrders is Map) {
            try {
              final Map<String, dynamic> mapOrders = Map<String, dynamic>.from(
                rawOrders,
              );
              existingCodes.addAll(mapOrders.keys.map((k) => k.toString()));
              for (final val in mapOrders.values) {
                if (val is Map) {
                  final v = Map<String, dynamic>.from(val);
                  if (v.containsKey('orderCode')) {
                    existingCodes.add(v['orderCode'].toString());
                  }
                }
              }
            } catch (_) {}
          } else if (rawOrders is List) {
            for (final item in rawOrders) {
              if (item is Map) {
                final m = Map<String, dynamic>.from(item);
                if (m.containsKey('orderCode'))
                  existingCodes.add(m['orderCode'].toString());
              }
            }
          } else {
            void extractOrderCodesRecursively(dynamic obj) {
              if (obj is Map) {
                final mapObj = Map<String, dynamic>.from(obj);
                if (mapObj.containsKey('orderCode')) {
                  existingCodes.add(mapObj['orderCode'].toString());
                }
                mapObj.values.forEach(extractOrderCodesRecursively);
              } else if (obj is List) {
                obj.forEach(extractOrderCodesRecursively);
              }
            }

            extractOrderCodesRecursively(data);
          }
        }
      }

      String randomAlphaNum(int len) {
        final Random random = Random();
        const chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        final buffer = StringBuffer();
        for (int i = 0; i < len; i++) {
          buffer.write(chars[random.nextInt(chars.length)]);
        }
        return buffer.toString();
      }

      const int maxAttempts = 10000;
      String newCode = '';
      int attempts = 0;

      do {
        if (attempts >= maxAttempts) {
          return Future.error(
            'No se pudo generar un código único tras $maxAttempts intentos.',
          );
        }
        newCode = randomAlphaNum(length);
        attempts++;
      } while (existingCodes.contains(newCode));

      return newCode;
    } catch (e) {
      return Future.error('Error generando código único: $e');
    }
  }

  @override
  Future<void> placeAOrder(
    AorderEntity aorder, {
    bool uploadPdf = false,
  }) async {
    if (uploadPdf && aorder.pdfFileBytes == null) {
      return Future.error('uploadPdf es true pero aorder.pdfFileBytes es null');
    }

    String? uploadedPdfPath;
    bool uploadedHere = false;

    try {
      bool fileAlreadyExists = false;
      if (uploadPdf && aorder.url.isNotEmpty) {
        try {
          final ref = FirebaseStorage.instance.refFromURL(aorder.url);
          await ref.getMetadata();
          uploadedPdfPath = ref.fullPath;
          fileAlreadyExists = true;
          uploadedHere = false;
        } on FirebaseException catch (e) {
          if (e.code == 'object-not-found' || e.code == 'not-found') {
            // subir luego
          }
        } catch (_) {}
      }

      if (uploadPdf && !fileAlreadyExists) {
        final sanitized = aorder.pdfName
            .replaceAll(RegExp(r'[\\/]+'), '_')
            .trim();
        uploadedPdfPath = await storageRepository.uploadPdfBytes(
          bytes: aorder.pdfFileBytes!,
          userRegistration: aorder.userRegistration,
          pdfName: sanitized,
        );
        uploadedHere = true;
      }

      final Map<String, dynamic> orderMap = aorder.toMap();

      final batch = _firestore.batch();

      final userInfoDoc = _firestore
          .collection('users')
          .doc(aorder.userRegistration)
          .collection('aorder')
          .doc('information');
      batch.set(userInfoDoc, {'specifications': orderMap});

      final copyshopDocRef = _firestore
          .collection('copyshops')
          .doc(aorder.copyShopEmail);
      final copyshopInfoDoc = copyshopDocRef
          .collection('aorders')
          .doc('information');

      batch.set(copyshopInfoDoc, {
        'items': {aorder.orderCode: orderMap},
      }, SetOptions(merge: true));

      await batch.commit();

      return;
    } catch (e) {
      if (uploadedHere && uploadedPdfPath != null) {
        try {
          await storageRepository.deleteFileByPath(uploadedPdfPath);
        } catch (_) {}
      }
      return Future.error('Error colocando orden: $e');
    }
  }

  @override
  Future<void> refreshCopyshopQueue(String copyshopEmail) async {
    try {
      final copyshopDocRef = _firestore
          .collection('copyshops')
          .doc(copyshopEmail);
      final copyshopSnap = await copyshopDocRef.get(
        const GetOptions(source: Source.server),
      );
      if (!copyshopSnap.exists) {
        return Future.error('Copyshop no encontrado: $copyshopEmail');
      }

      final aordersDocRef = copyshopDocRef
          .collection('aorders')
          .doc('information');
      final snap = await aordersDocRef.get(
        const GetOptions(source: Source.server),
      );

      int count = 0;
      if (snap.exists) {
        final data = snap.data();
        if (data != null) {
          final dynamic rawItems = data['items'] ?? {};
          if (rawItems is Map) {
            final Map<String, dynamic> itemsMap = Map<String, dynamic>.from(
              rawItems,
            );
            itemsMap.forEach((key, value) {
              try {
                if (value is Map) {
                  final Map<String, dynamic> orderMap =
                      Map<String, dynamic>.from(value);
                  final bool accepted =
                      (orderMap['hasItBeenAccepted'] ?? false) == true;
                  if (accepted) count++;
                }
              } catch (_) {}
            });
          }
        }
      }

      final currentQueue = copyshopSnap.data()?['queue'];
      if (currentQueue is int && currentQueue == count) {
        return;
      }

      try {
        await copyshopDocRef.update({'queue': count});
      } on FirebaseException catch (_) {
        await copyshopDocRef.set({'queue': count}, SetOptions(merge: true));
      }

      return;
    } catch (e) {
      return Future.error('Error actualizando queue: $e');
    }
  }

  @override
  Future<bool> isCopyshopPaused(String copyshopEmail) async {
    try {
      final docRef = _firestore.collection('copyshops').doc(copyshopEmail);
      final snap = await docRef.get(const GetOptions(source: Source.server));
      if (!snap.exists) {
        return Future.error('Copyshop no encontrado: $copyshopEmail');
      }

      final data = snap.data();
      if (data == null) return false;

      final pauseVal = data['pauseReception'];
      if (pauseVal is bool) return pauseVal;
      if (pauseVal is String) {
        return pauseVal.toLowerCase() == 'true';
      }
      if (pauseVal is num) {
        return pauseVal != 0;
      }

      return false;
    } catch (e) {
      return Future.error('Error verificando pauseReception: $e');
    }
  }

  @override
  Future<void> addCardPaymentMethod(
    String registration,
    CardPaymentMethodEntity card,
  ) async {
    try {
      final docRef = _firestore.collection('users').doc(registration);

      await _firestore.runTransaction((tx) async {
        // dentro de transacción llamamos tx.get(docRef) SIN GetOptions (transaction reads server by default)
        final snap = await tx.get(docRef);
        Map<String, dynamic> currentCards = <String, dynamic>{};

        if (snap.exists) {
          final data = snap.data();
          if (data != null && data['cardPaymentMethods'] != null) {
            final dynamic raw = data['cardPaymentMethods'];
            if (raw is Map) {
              currentCards = Map<String, dynamic>.from(raw);
            }
          }
        }

        if (card.isDefault) {
          currentCards.forEach((key, value) {
            if (value is Map<String, dynamic>) {
              final m = Map<String, dynamic>.from(value);
              m['isDefault'] = false;
              currentCards[key] = m;
            }
          });
        }

        dynamic existingCreatedAt;
        if (currentCards.containsKey(card.token)) {
          final existing = currentCards[card.token];
          if (existing is Map && existing['createdAt'] != null) {
            existingCreatedAt = existing['createdAt'];
          }
        }

        final Map<String, dynamic> cardMap = {
          'token': card.token,
          'last4': card.last4,
          'brand': card.brand,
          'expMonth': card.expMonth,
          'expYear': card.expYear,
          'isDefault': card.isDefault,
          'createdAt': existingCreatedAt ?? FieldValue.serverTimestamp(),
        };

        currentCards[card.token] = cardMap;

        tx.set(docRef, {
          'cardPaymentMethods': currentCards,
        }, SetOptions(merge: true));
      });

      return;
    } catch (e) {
      return Future.error('Error agregando tarjeta: $e');
    }
  }

  @override
  Future<void> setDefaultCard(String registration, String token) async {
    try {
      final docRef = _firestore.collection('users').doc(registration);

      await _firestore.runTransaction((tx) async {
        // tx.get no acepta GetOptions -> transaction reads from server by default
        final snap = await tx.get(docRef);

        if (!snap.exists) {
          throw Exception('Usuario no encontrado: $registration');
        }

        final data = snap.data() ?? {};
        final dynamic raw = data['cardPaymentMethods'] ?? {};

        if (raw is! Map) {
          throw Exception('No hay tarjetas para este usuario.');
        }

        Map<String, dynamic> currentCards = Map<String, dynamic>.from(raw);

        // Si no es "cash", verificamos que el token exista.
        if (token != 'cash' && !currentCards.containsKey(token)) {
          throw Exception('Token no encontrado: $token');
        }

        // Actualizar isDefault para todas las tarjetas.
        currentCards.forEach((key, value) {
          if (value is Map<String, dynamic>) {
            final m = Map<String, dynamic>.from(value);
            m['isDefault'] = (token == 'cash') ? false : (key == token);
            currentCards[key] = m;
          }
        });

        tx.set(docRef, {
          'cardPaymentMethods': currentCards,
        }, SetOptions(merge: true));
      });

      return;
    } catch (e) {
      return Future.error('Error estableciendo tarjeta por defecto: $e');
    }
  }

  @override
  Future<List<CardPaymentMethodEntity>> getCards(String registration) async {
    try {
      final docRef = _firestore.collection('users').doc(registration);
      final snap = await docRef.get(const GetOptions(source: Source.server));

      if (!snap.exists) {
        return <CardPaymentMethodEntity>[];
      }

      final data = snap.data() ?? {};
      final dynamic rawMap = data['cardPaymentMethods'] ?? {};

      if (rawMap is! Map) {
        return <CardPaymentMethodEntity>[];
      }

      final Map<String, dynamic> cardMap = Map<String, dynamic>.from(rawMap);

      final List<CardPaymentMethodEntity> result = [];

      cardMap.forEach((key, value) {
        try {
          if (value is Map<String, dynamic>) {
            final Map<String, dynamic> m = Map<String, dynamic>.from(value);
            final entity = CardPaymentMethodEntity.fromMap(m);
            result.add(entity);
          } else if (value is Map) {
            final Map<String, dynamic> m = Map<String, dynamic>.from(value);
            final entity = CardPaymentMethodEntity.fromMap(m);
            result.add(entity);
          }
        } catch (e) {
          // ignore malformed
        }
      });

      return result;
    } catch (e) {
      return Future.error('Error obteniendo tarjetas: $e');
    }
  }

  /// Nueva: elimina una lista de tokens en UNA sola transacción.
  /// Elimina varias tarjetas (por tokens). Reintentos con verificación server-side.
  /// Usa dos estrategias: (A) escribir mapa completo sin tokens, (B) eliminar por path con FieldValue.delete().
  @override
  Future<void> removeCards(String registration, List<String> tokens) async {
    if (tokens.isEmpty) return;

    final docRef = _firestore.collection('users').doc(registration);
    const int maxAttempts = 5;
    int attempt = 0;

    // Helper para lectura server
    Future<Map<String, dynamic>> _readServerMap() async {
      final serverSnap = await docRef.get(
        const GetOptions(source: Source.server),
      );
      final serverData = serverSnap.data() ?? {};
      final dynamic serverRaw = serverData['cardPaymentMethods'] ?? {};
      return (serverRaw is Map)
          ? Map<String, dynamic>.from(serverRaw)
          : <String, dynamic>{};
    }

    while (true) {
      attempt++;
      try {
        // 1) Estrategia A: transacción que escribe el mapa completo excluyendo los tokens
        await _firestore.runTransaction((tx) async {
          final snap = await tx.get(docRef);
          if (!snap.exists) {
            throw Exception('Usuario no encontrado: $registration');
          }

          Map<String, dynamic> currentCards = <String, dynamic>{};
          final data = snap.data();
          if (data != null && data['cardPaymentMethods'] != null) {
            final raw = data['cardPaymentMethods'];
            if (raw is Map) currentCards = Map<String, dynamic>.from(raw);
          }

          // Si ninguno de los tokens está presente -> nothing to do
          final presentTokens = tokens
              .where((t) => currentCards.containsKey(t))
              .toList();
          if (presentTokens.isEmpty) return;

          bool removedDefault = false;
          for (final token in presentTokens) {
            final removed = currentCards[token];
            final wasDefault =
                (removed is Map && (removed['isDefault'] == true));
            if (wasDefault) removedDefault = true;
            currentCards.remove(token);
          }

          // Si se eliminó default y quedan otras tarjetas -> marcar la primera como default
          if (removedDefault && currentCards.isNotEmpty) {
            final String firstKey = currentCards.keys.first;
            final dynamic firstVal = currentCards[firstKey];
            final Map<String, dynamic> firstMap =
                (firstVal is Map<String, dynamic>)
                ? Map<String, dynamic>.from(firstVal)
                : <String, dynamic>{};
            firstMap['isDefault'] = true;
            currentCards[firstKey] = firstMap;
          }

          // Marcar la hora de actualización para detección externa (opcional pero útil)
          final nowMarker = FieldValue.serverTimestamp();

          if (currentCards.isEmpty) {
            tx.update(docRef, {
              'cardPaymentMethods': FieldValue.delete(),
              'cardPaymentMethodsLastUpdated': nowMarker,
            });
          } else {
            tx.set(docRef, {
              'cardPaymentMethods': currentCards,
              'cardPaymentMethodsLastUpdated': nowMarker,
            }, SetOptions(merge: true));
          }
        });

        // 2) Verificación server
        final serverMap = await _readServerMap();
        final stillPresent = tokens
            .where((t) => serverMap.containsKey(t))
            .toList();
        if (stillPresent.isEmpty) {
          print(
            '[removeCards] éxito (estrategia A) intento #$attempt para tokens=${tokens.join(",")}',
          );
          return;
        }

        print(
          '[removeCards] estrategia A no eliminó todos. tokens aún presentes: ${stillPresent.join(",")}',
        );

        // 3) Estrategia B (fall back): eliminar por path usando FieldValue.delete()
        await _firestore.runTransaction((tx) async {
          final snap = await tx.get(docRef);
          if (!snap.exists) {
            throw Exception('Usuario no encontrado: $registration');
          }

          // Preparamos mapa de updates: 'cardPaymentMethods.<token>': FieldValue.delete()
          final updateMap = <String, Object>{};
          final currentData = snap.data() ?? {};
          final dynamic currentRaw = currentData['cardPaymentMethods'] ?? {};
          final currentMap = (currentRaw is Map)
              ? Map<String, dynamic>.from(currentRaw)
              : <String, dynamic>{};

          final presentTokens = tokens
              .where((t) => currentMap.containsKey(t))
              .toList();
          for (final token in presentTokens) {
            // construimos la path: cardPaymentMethods.<token>
            final path = 'cardPaymentMethods.$token';
            updateMap[path] = FieldValue.delete();
          }

          if (updateMap.isNotEmpty) {
            // también actualizamos el marcador temporal
            updateMap['cardPaymentMethodsLastUpdated'] =
                FieldValue.serverTimestamp();
            tx.update(docRef, updateMap);
          }
        });

        // 4) Verificar después de la estrategia B
        final serverMapAfterB = await _readServerMap();
        final stillPresentAfterB = tokens
            .where((t) => serverMapAfterB.containsKey(t))
            .toList();
        if (stillPresentAfterB.isEmpty) {
          print(
            '[removeCards] éxito (estrategia B) intento #$attempt para tokens=${tokens.join(",")}',
          );
          return;
        }

        // Si aún quedan, reintentamos si no llegamos al max
        final err =
            'Tras estrategias A+B, tokens todavía presentes: ${stillPresentAfterB.join(",")}';
        print('[removeCards] intento #$attempt: $err');

        if (attempt >= maxAttempts) {
          return Future.error(
            'Error eliminando tarjetas tras $attempt intentos: $err',
          );
        }

        // backoff y reintentar
        await Future.delayed(Duration(milliseconds: 250 * attempt));
        continue;
      } catch (e) {
        print('[removeCards] intento #$attempt falló: $e');
        if (attempt >= maxAttempts) {
          return Future.error(
            'Error eliminando tarjetas tras $attempt intentos: $e',
          );
        }
        await Future.delayed(Duration(milliseconds: 200 * attempt));
        continue;
      }
    }
  }

@override
Future<void> markAllNotificationsAsSeen(String registration) async {
  try {
    final documentRef = _firestore
        .collection('users')
        .doc(registration)
        .collection('notifications')
        .doc('information');

    final document = await documentRef.get(const GetOptions(source: Source.server));
    
    if (!document.exists) {
      return;
    }

    final data = document.data();
    if (data == null || !data.containsKey('items')) {
      return;
    }

    final List<dynamic> items = data['items'];
    if (items.isEmpty) {
      return;
    }

    // Marcamos todos los items como vistos
    final updatedItems = items.map((item) {
      final Map<String, dynamic> notification = Map<String, dynamic>.from(item);
      return {
        ...notification,
        'seen': true,
      };
    }).toList();

    await documentRef.update({
      'items': updatedItems,
    });

  } catch (e) {
    throw Exception('Error markAllNotificationsAsSeen: $e');
  }
}

}
