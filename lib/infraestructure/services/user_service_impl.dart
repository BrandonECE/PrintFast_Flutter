// lib/data/services/user_service_impl.dart
import 'dart:async';
import 'dart:math';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
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
    final controller = StreamController<AorderEntity?>();
    StreamSubscription<dynamic>?
    connSub; // puede emitir ConnectivityResult o List<ConnectivityResult>
    StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? snapSub;

    // Helper: normaliza posibles tipos devueltos por connectivity (ConnectivityResult o List<ConnectivityResult>)
    ConnectivityResult _normalizeConnectivity(dynamic raw) {
      if (raw is ConnectivityResult) return raw;
      if (raw is List && raw.isNotEmpty && raw.first is ConnectivityResult) {
        return raw.first as ConnectivityResult;
      }
      // fallback conservador
      return ConnectivityResult.none;
    }

    // Subscribe (crear) o resumir el listener de snapshots
    void subscribeSnapshots() {
      // si ya existe la suscripción y está pausada, resumirla
      if (snapSub != null) {
        try {
          snapSub?.resume();
        } catch (_) {}
        return;
      }

      snapSub = _firestore
          .collection('users')
          .doc(registration)
          .collection('aorder')
          .doc('information')
          .snapshots()
          .listen(
            (DocumentSnapshot<Map<String, dynamic>> snapshot) {
              try {
                if (!snapshot.exists) {
                  // Documento no existe -> emitimos null
                  if (!controller.isClosed) controller.add(null);
                  return;
                }

                final data = snapshot.data();
                if (data == null) {
                  if (!controller.isClosed) controller.add(null);
                  return;
                }

                final specsRaw = data['specifications'];

                if (specsRaw == null) {
                  if (!controller.isClosed) controller.add(null);
                  return;
                }

                if (specsRaw is! Map) {
                  if (!controller.isClosed) controller.add(null);
                  return;
                }

                final Map<String, dynamic> specifications =
                    Map<String, dynamic>.from(specsRaw);

                if (specifications.isEmpty) {
                  if (!controller.isClosed) controller.add(null);
                  return;
                }

                try {
                  final aorder = AorderEntity.fromMap(specifications);
                  if (!controller.isClosed) controller.add(aorder);
                } catch (e) {
                  // parsing falló -> emitimos null y logueamos
                  // print('getAorderStream: parsing error for $registration: $e\n$st');
                  if (!controller.isClosed) controller.add(null);
                }
              } catch (e) {
                // error inesperado procesando snapshot -> propagar error
                if (!controller.isClosed) {
                  controller.addError(
                    Exception('Error procesando snapshot: $e'),
                  );
                }
              }
            },
            onError: (error) {
              // Propagar error venido del stream de snapshots
              if (!controller.isClosed) controller.addError(error);
            },
            cancelOnError: false,
          );
    }

    // Manejo de conectividad: pausa o (re)subcribe snapshots
    void handleConnectivity(dynamic rawStatus) {
      final status = _normalizeConnectivity(rawStatus);
      final offline = status == ConnectivityResult.none;
      if (offline) {
        // Pausar listener de Firestore y emitir error de conexión
        try {
          snapSub?.pause();
        } catch (_) {}
        if (!controller.isClosed) controller.addError('Sin conexión');
        return;
      }

      // Si estamos online, nos (re)subscribimos a snapshots
      subscribeSnapshots();
    }

    // onListen: arrancamos el listener de connectivity y respondemos al estado inicial
    controller.onListen = () async {
      // 1) crear listener de connectivity, normalizando el evento
      connSub = Connectivity().onConnectivityChanged.listen((dynamic status) {
        try {
          handleConnectivity(status);
        } catch (e) {
          // ignore
        }
      });

      // 2) checar estado inicial y actuar acorde
      try {
        final rawInitial = await Connectivity().checkConnectivity();
        handleConnectivity(rawInitial);
      } catch (e) {
        // Si checkConnectivity falla, intentamos subscribir snapshots por seguridad
        subscribeSnapshots();
      }
    };

    // Limpieza: cancelar suscripciones y cerrar controller
    controller.onCancel = () async {
      try {
        await connSub?.cancel();
      } catch (_) {}
      try {
        await snapSub?.cancel();
      } catch (_) {}
      try {
        if (!controller.isClosed) await controller.close();
      } catch (_) {}
    };

    return controller.stream;
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
        final copyShopPhone = data['copyShopPhone']?.toString() ?? '';
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
          copyShopPhone: copyShopPhone,
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
                if (m.containsKey('orderCode')) {
                  existingCodes.add(m['orderCode'].toString());
                }
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
        final sanitized = aorder.pdfName.replaceAll(RegExp(r'[\\/]+'), '_').trim();
        uploadedPdfPath = await storageRepository.uploadPdfBytes(
          bytes: aorder.pdfFileBytes!,
          userRegistration: aorder.userRegistration,
          pdfName: sanitized,
        );
        uploadedHere = true;
      }

      final Map<String, dynamic> orderMap = aorder.toMap();

      // -------- Batch: escribir user aorder, copyshop aorders y NOTIFICACION --------
      final batch = _firestore.batch();

      final userInfoDoc = _firestore
          .collection('users')
          .doc(aorder.userRegistration)
          .collection('aorder')
          .doc('information');
      batch.set(userInfoDoc, {'specifications': orderMap});

      final copyshopDocRef = _firestore.collection('copyshops').doc(aorder.copyShopEmail);
      final copyshopInfoDoc = copyshopDocRef.collection('aorders').doc('information');

      batch.set(copyshopInfoDoc, {
        'items': {aorder.orderCode: orderMap},
      }, SetOptions(merge: true));

      // Preparar notificación para la copyshop
      final notification = NotificationEntity(
        subject: 'Nueva orden #${aorder.orderCode}',
        message: 'Usu:${aorder.userRegistration}',
        dateTime: DateTime.now(),
        seen: false,
      );

      final copyshopNotificationsDoc = copyshopDocRef
          .collection('notifications')
          .doc('information');

      // Añadir la notificación al array 'items' (merge)
      batch.set(copyshopNotificationsDoc, {
        'items': FieldValue.arrayUnion([notification.toMap()]),
      }, SetOptions(merge: true));

      // Commit del batch (atomic para los documentos que toca)
      await batch.commit();

      return;
    } catch (e) {
      // Si subimos el archivo en esta llamada, intentamos borrarlo (rollback del storage)
      if (uploadedHere && uploadedPdfPath != null) {
        try {
          await storageRepository.deleteFileByPath(uploadedPdfPath);
        } catch (e) {
          // no hacemos más: ya estamos en manejo de error, logueamos opcionalmente
          print('placeAOrder: fallo borrando pdf en rollback: $e');
        }
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
                      ((orderMap['hasItBeenAccepted'] ?? false) == true) && orderMap['hasItBeenCanceledByUser'] == false;
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

      final document = await documentRef.get(
        const GetOptions(source: Source.server),
      );

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
        final Map<String, dynamic> notification = Map<String, dynamic>.from(
          item,
        );
        return {...notification, 'seen': true};
      }).toList();

      await documentRef.update({'items': updatedItems});
    } catch (e) {
      throw Exception('Error markAllNotificationsAsSeen: $e');
    }
  }

@override
Future<void> deleteUserOrder(
  String copyShopEmail,
  String registration,
  AorderEntity aorder,
) async {
  try {
    final orderCode = aorder.orderCode;
    if (orderCode.isEmpty) {
      return Future.error('orderCode vacío en AorderEntity.');
    }

    // Referencias
    final userAorderDocRef = _firestore
        .collection('users')
        .doc(registration)
        .collection('aorder')
        .doc('information');

    final userMainDocRef = _firestore.collection('users').doc(registration);

    final adminAordersDocRef = _firestore
        .collection('copyshops')
        .doc(copyShopEmail)
        .collection('aorders')
        .doc('information');

    final copyshopDocRef = _firestore.collection('copyshops').doc(copyShopEmail);

    // --- Caso: hasItBeenAccepted == null ---
    if (aorder.hasItBeenAccepted == null) {
      Map<String, dynamic>? originalItems;
      Map<String, dynamic>? originalSpecs;

      final Map<String, dynamic> txResult = await _firestore.runTransaction((tx) async {
        // Lecturas: leer TODO lo necesario ANTES de escribir
        final adminSnap = await tx.get(adminAordersDocRef);
        final userSnap = await tx.get(userAorderDocRef);
        final copyshopSnap = await tx.get(copyshopDocRef); // lo leemos por si hay que usarlo luego

        if (!adminSnap.exists) {
          throw Exception('Documento admin (aorders/information) no existe para $copyShopEmail.');
        }
        if (!userSnap.exists) {
          throw Exception('Documento usuario (aorder/information) no existe para $registration.');
        }

        final adminData = adminSnap.data();
        if (adminData == null) throw Exception('Documento admin sin datos.');

        final itemsRaw = adminData['items'];
        if (itemsRaw is! Map) {
          throw Exception('Estructura inválida: "items" no es un Map en admin doc.');
        }
        final Map<String, dynamic> itemsMap = Map<String, dynamic>.from(itemsRaw);

        if (!itemsMap.containsKey(orderCode)) {
          throw Exception('El orderCode "$orderCode" no existe en items (admin).');
        }

        final userData = userSnap.data();
        if (userData == null) throw Exception('Documento usuario sin datos.');
        final specsRaw = userData['specifications'];
        if (specsRaw is! Map) {
          throw Exception('Estructura inválida: "specifications" no es un Map en user doc.');
        }

        // Preparamos cambios en memoria
        final Map<String, dynamic> backupItems = Map<String, dynamic>.from(itemsMap);
        final Map<String, dynamic> updatedItems = Map<String, dynamic>.from(itemsMap);
        updatedItems.remove(orderCode);

        final Map<String, dynamic> specsMap = Map<String, dynamic>.from(specsRaw);
        final Map<String, dynamic> backupSpecs = Map<String, dynamic>.from(specsMap);

        // Todas las escrituras suceden después de las lecturas
        tx.update(adminAordersDocRef, {'items': updatedItems});
        tx.update(userAorderDocRef, {'specifications': FieldValue.delete()});

        // ✅ AGREGAR NOTIFICACIÓN DE CANCELACIÓN
        _addCancellationNotification(tx, copyshopDocRef, orderCode, registration);

        // Nota: no tocamos 'queue' en esta rama según tus instrucciones.

        // devolvemos backups para post-proceso (rollback si Storage falla)
        return {'originalItems': backupItems, 'originalSpecs': backupSpecs};
      });

      originalItems = Map<String, dynamic>.from(txResult['originalItems'] as Map<String, dynamic>);
      originalSpecs = Map<String, dynamic>.from(txResult['originalSpecs'] as Map<String, dynamic>);

      // Borrar Storage si aplica
      final String fileUrl = (aorder.url).trim();
      if (fileUrl.isEmpty) {
        return;
      }

      String storagePath = fileUrl;
      if (fileUrl.startsWith('gs://')) {
        final withoutScheme = fileUrl.substring(5);
        final firstSlash = withoutScheme.indexOf('/');
        storagePath = firstSlash >= 0 ? withoutScheme.substring(firstSlash + 1) : withoutScheme;
      }

      try {
        await storageRepository.deleteFileByPath(storagePath);
        return;
      } on FirebaseException catch (e) {
        final code = (e.code).toLowerCase();
        if (code.contains('object-not-found') || code.contains('not-found')) {
          return;
        }
        // rollback en Firestore
        try {
          await _firestore.runTransaction((tx) async {
            // re-leemos por seguridad antes de reescribir
            final adminSnapCheck = await tx.get(adminAordersDocRef);
            final userSnapCheck = await tx.get(userAorderDocRef);
            if (!adminSnapCheck.exists || !userSnapCheck.exists) {
              throw Exception('Rollback fallido: documentos no existen al intentar revertir.');
            }
            tx.update(adminAordersDocRef, {'items': originalItems});
            tx.update(userAorderDocRef, {'specifications': originalSpecs});
            
            // ✅ EN EL ROLLBACK TAMBIÉN ELIMINAMOS LA NOTIFICACIÓN QUE ACABAMOS DE AGREGAR
            _removeCancellationNotification(tx, copyshopDocRef, orderCode, registration);
          });
          return Future.error(
            'Error borrando archivo en Storage: ${e.message ?? e}. Se revirtió la operación en Firestore.',
          );
        } catch (rollbackError) {
          return Future.error(
            'Error borrando archivo en Storage: ${e.message ?? e}. Intento de rollback en Firestore falló: $rollbackError. '
            'Puede que los datos hayan quedado en estado inconsistente.',
          );
        }
      } catch (e) {
        try {
          await _firestore.runTransaction((tx) async {
            tx.update(adminAordersDocRef, {'items': originalItems});
            tx.update(userAorderDocRef, {'specifications': originalSpecs});
            // ✅ ELIMINAR NOTIFICACIÓN EN ROLLBACK
            _removeCancellationNotification(tx, copyshopDocRef, orderCode, registration);
          });
          return Future.error('Error borrando archivo en Storage: $e. Se revirtió la operación en Firestore.');
        } catch (rollbackError) {
          return Future.error('Error borrando archivo en Storage: $e. Intento de rollback en Firestore falló: $rollbackError.');
        }
      }
    }

    // --- Caso: hasItBeenAccepted == false ---
    if (aorder.hasItBeenAccepted == false) {
      // ❌ NO AGREGAMOS NOTIFICACIÓN EN ESTE CASO (según tu solicitud)
      // Lecturas antes de escribir
      await _firestore.runTransaction((tx) async {
        final userSnap = await tx.get(userAorderDocRef);
        if (!userSnap.exists) {
          throw Exception('Documento usuario (aorder/information) no existe para $registration.');
        }
        final userData = userSnap.data();
        if (userData == null) throw Exception('Documento usuario sin datos.');
        final specsRaw = userData['specifications'];
        if (specsRaw is! Map) {
          throw Exception('Estructura inválida: "specifications" no es un Map en user doc.');
        }

        // Escritura: borrar specifications
        tx.update(userAorderDocRef, {'specifications': FieldValue.delete()});
      });
      return;
    }

    // --- Caso: hasItBeenAccepted == true ---
    if (aorder.hasItBeenAccepted == true) {
      // Leemos snapshots seguros desde servidor (fuera de transacción) para validar existencia
      final adminSnapRead = await adminAordersDocRef.get(const GetOptions(source: Source.server));
      final userAorderSnapRead = await userAorderDocRef.get(const GetOptions(source: Source.server));
      if (!adminSnapRead.exists) {
        return Future.error('Documento admin (aorders/information) no existe para $copyShopEmail.');
      }
      if (!userAorderSnapRead.exists) {
        return Future.error('Documento usuario (aorder/information) no existe para $registration.');
      }

      final adminData = adminSnapRead.data() ?? {};
      final userAorderData = userAorderSnapRead.data() ?? {};

      final dynamic itemsRaw = adminData['items'] ?? {};
      if (itemsRaw is! Map || !Map<String, dynamic>.from(itemsRaw).containsKey(orderCode)) {
        return Future.error('El orderCode "$orderCode" no existe en items (admin).');
      }

      final Map<String, dynamic> itemsMap = Map<String, dynamic>.from(itemsRaw);
      final dynamic itemRaw = itemsMap[orderCode];
      if (itemRaw is! Map) {
        return Future.error('Item admin para $orderCode no tiene la estructura esperada.');
      }

      // Determinar printDate (puede venir del item admin o del specifications del user)
      dynamic printDateRaw;
      if ((itemRaw).containsKey('printDate')) {
        printDateRaw = (itemRaw)['printDate'];
      } else {
        final specsRaw = userAorderData['specifications'];
        if (specsRaw is Map && (specsRaw).containsKey('printDate')) {
          printDateRaw = (specsRaw)['printDate'];
        }
      }

      // -------------- RAMA A: printDate == null --------------
      if (printDateRaw == null) {
        Map<String, dynamic>? originalItems;
        Map<String, dynamic>? originalSpecs;

        final txResult = await _firestore.runTransaction((tx) async {
          // Lecturas: leer admin, userAorder y copyshop ANTES de cualquier write
          final adminSnap = await tx.get(adminAordersDocRef);
          final userSnap = await tx.get(userAorderDocRef);
          final copyshopSnap = await tx.get(copyshopDocRef);

          final adminData2 = adminSnap.data();
          final itemsRaw2 = adminData2?['items'];
          if (itemsRaw2 is! Map) throw Exception('items no es Map en admin doc.');
          final Map<String, dynamic> itemsMap2 = Map<String, dynamic>.from(itemsRaw2);
          if (!itemsMap2.containsKey(orderCode)) throw Exception('orderCode inexistente (admin).');

          final userData2 = userSnap.data();
          if (userData2 == null) throw Exception('user aorder doc sin datos.');
          final specsRaw2 = userData2['specifications'];
          if (specsRaw2 is! Map) throw Exception('specifications no es Map en user doc.');

          // Backups y updatedItems (marcamos hasItBeenCanceledByUser = true)
          final Map<String, dynamic> backupItems = Map<String, dynamic>.from(itemsMap2);
          final Map<String, dynamic> updatedItems = Map<String, dynamic>.from(itemsMap2);
          final Map<String, dynamic> singleItem = Map<String, dynamic>.from(updatedItems[orderCode] as Map);
          singleItem['hasItBeenCanceledByUser'] = true;
          updatedItems[orderCode] = singleItem;

          final Map<String, dynamic> backupSpecs = Map<String, dynamic>.from(specsRaw2);

          // Calcular acceptedCount para ajustar queue (antes de eliminar)
          int acceptedCount = 0;
          itemsMap2.forEach((k, v) {
            try {
              if (v is Map) {
                final h = v['hasItBeenAccepted'];
                final canceled = v['hasItBeenCanceledByUser'];

                final bool isAccepted = (h == true) ||
                    (h is String && h.toLowerCase() == 'true') ||
                    (h is num && h != 0);

                final bool isCanceled = (canceled == true) ||
                    (canceled is String && canceled.toLowerCase() == 'true') ||
                    (canceled is num && canceled != 0);

                if (isAccepted && !isCanceled) {
                  acceptedCount++;
                }
              }
            } catch (_) {}
          });

          final int newQueue = (acceptedCount - 1) >= 0 ? (acceptedCount - 1) : 0;

          // Escrituras (todas después de las lecturas)
          tx.update(adminAordersDocRef, {'items': updatedItems});
          tx.update(userAorderDocRef, {'specifications': FieldValue.delete()});

          // ✅ AGREGAR NOTIFICACIÓN DE CANCELACIÓN
          _addCancellationNotification(tx, copyshopDocRef, orderCode, registration);

          // actualizar queue en documento principal de copyshop (crear si no existe)
          if (copyshopSnap.exists) {
            tx.update(copyshopDocRef, {'queue': newQueue});
          } else {
            tx.set(copyshopDocRef, {'queue': newQueue}, SetOptions(merge: true));
          }

          return {'originalItems': backupItems, 'originalSpecs': backupSpecs};
        });

        originalItems = Map<String, dynamic>.from(txResult['originalItems'] as Map<String, dynamic>);
        originalSpecs = Map<String, dynamic>.from(txResult['originalSpecs'] as Map<String, dynamic>);

        // Borrar Storage si aplica
        final String fileUrl = (aorder.url).trim();
        if (fileUrl.isEmpty) return;
        String storagePath = fileUrl;
        if (fileUrl.startsWith('gs://')) {
          final withoutScheme = fileUrl.substring(5);
          final firstSlash = withoutScheme.indexOf('/');
          storagePath = firstSlash >= 0 ? withoutScheme.substring(firstSlash + 1) : withoutScheme;
        }

        try {
          await storageRepository.deleteFileByPath(storagePath);
          return;
        } on FirebaseException catch (e) {
          final code = (e.code ?? '').toLowerCase();
          if (code.contains('object-not-found') || code.contains('not-found')) {
            return;
          }
          // rollback
          try {
            await _firestore.runTransaction((tx) async {
              final adminSnapCheck = await tx.get(adminAordersDocRef);
              final userSnapCheck = await tx.get(userAorderDocRef);
              if (!adminSnapCheck.exists || !userSnapCheck.exists) {
                throw Exception('Rollback fallido: documentos no existen al intentar revertir.');
              }
              tx.update(adminAordersDocRef, {'items': originalItems});
              tx.update(userAorderDocRef, {'specifications': originalSpecs});
              
              // ✅ ELIMINAR NOTIFICACIÓN EN ROLLBACK
              _removeCancellationNotification(tx, copyshopDocRef, orderCode, registration);
            });
            return Future.error('Error borrando archivo en Storage: ${e.message ?? e}. Se revirtió la operación en Firestore.');
          } catch (rollbackError) {
            return Future.error('Error borrando archivo en Storage: ${e.message ?? e}. Intento de rollback en Firestore falló: $rollbackError.');
          }
        } catch (e) {
          try {
            await _firestore.runTransaction((tx) async {
              tx.update(adminAordersDocRef, {'items': originalItems});
              tx.update(userAorderDocRef, {'specifications': originalSpecs});
              // ✅ ELIMINAR NOTIFICACIÓN EN ROLLBACK
              _removeCancellationNotification(tx, copyshopDocRef, orderCode, registration);
            });
            return Future.error('Error borrando archivo en Storage: $e. Se revirtió la operación en Firestore.');
          } catch (rollbackError) {
            return Future.error('Error borrando archivo en Storage: $e. Intento de rollback en Firestore falló: $rollbackError.');
          }
        }
      } else {
        // -------------- RAMA B: printDate != null --------------
        DateTime printDateTime;
        if (printDateRaw is Timestamp) {
          printDateTime = printDateRaw.toDate();
        } else if (printDateRaw is DateTime) {
          printDateTime = printDateRaw;
        } else {
          try {
            printDateTime = DateTime.parse(printDateRaw.toString());
          } catch (_) {
            return Future.error('printDate tiene un formato desconocido.');
          }
        }

        final now = DateTime.now().toUtc();
        final elapsedSeconds = now.difference(printDateTime.toUtc()).inSeconds;
        final double secondsPerPage = (aorder.isColor == true) ? 2.0 : 1.0;
        final int pagesPrinted = math.min(aorder.pages, (elapsedSeconds / secondsPerPage).floor());

        final int totalPages = (aorder.pages > 0) ? aorder.pages : 1;
        final double perPagePrice = (aorder.price / totalPages);

        final double amountPrinted = perPagePrice * pagesPrinted;
        final double penalty = double.parse((aorder.price * 0.30).toStringAsFixed(2)); // penalización al 30%
        final double outstandingIncrement = double.parse((amountPrinted + penalty).toStringAsFixed(2));

        Map<String, dynamic>? backupItems;
        Map<String, dynamic>? backupSpecs;
        num originalOutstanding = 0;

        final txResult = await _firestore.runTransaction((tx) async {
          // Lecturas: ADMIN, USER AORDER, USER MAIN, COPYSHOP antes de escribir
          final adminSnap2 = await tx.get(adminAordersDocRef);
          final userAorderSnap2 = await tx.get(userAorderDocRef);
          final userMainSnap = await tx.get(userMainDocRef);
          final copyshopSnap = await tx.get(copyshopDocRef);

          if (!adminSnap2.exists) throw Exception('Documento admin no existe.');
          if (!userAorderSnap2.exists) throw Exception('Documento user aorder no existe.');
          if (!userMainSnap.exists) throw Exception('Documento principal del usuario no existe: $registration');

          final adminData2 = adminSnap2.data();
          final itemsRaw2 = adminData2?['items'];
          if (itemsRaw2 is! Map) throw Exception('items no es Map en admin doc.');
          final Map<String, dynamic> itemsMap2 = Map<String, dynamic>.from(itemsRaw2);
          if (!itemsMap2.containsKey(orderCode)) throw Exception('orderCode inexistente (admin).');

          backupItems = Map<String, dynamic>.from(itemsMap2);
          final Map<String, dynamic> updatedItems2 = Map<String, dynamic>.from(itemsMap2);
          final Map<String, dynamic> singleItem2 = Map<String, dynamic>.from(updatedItems2[orderCode] as Map);

          // marcamos cancelado y agregamos info de cobro/printedPages
          singleItem2['hasItBeenCanceledByUser'] = true;
          singleItem2['canceledAt'] = FieldValue.serverTimestamp();
          singleItem2['chargedAmount'] = outstandingIncrement;
          singleItem2['printedPages'] = pagesPrinted;
          updatedItems2[orderCode] = singleItem2;

          final userAorderData2 = userAorderSnap2.data();
          final specsRaw2 = userAorderData2?['specifications'];
          if (specsRaw2 is! Map) throw Exception('specifications no es Map en user aorder doc.');
          backupSpecs = Map<String, dynamic>.from(specsRaw2);

          final userMainData = userMainSnap.data() ?? {};
          final dynamic rawOutstanding = userMainData['outstandingCharges'] ?? 0;
          final num currentOutstanding = (rawOutstanding is num) ? rawOutstanding : (num.tryParse('$rawOutstanding') ?? 0);
          originalOutstanding = currentOutstanding;
          final num newOutstanding = (currentOutstanding) + outstandingIncrement;

          // calcular acceptedCount para queue
          int acceptedCount = 0;
          itemsMap2.forEach((k, v) {
            try {
              if (v is Map) {
                final h = v['hasItBeenAccepted'];
                final canceled = v['hasItBeenCanceledByUser'];

                final bool isAccepted = (h == true) ||
                    (h is String && h.toLowerCase() == 'true') ||
                    (h is num && h != 0);

                final bool isCanceled = (canceled == true) ||
                    (canceled is String && canceled.toLowerCase() == 'true') ||
                    (canceled is num && canceled != 0);

                if (isAccepted || isCanceled) {
                  acceptedCount++;
                }
              }
            } catch (_) {}
          });

          final int newQueue = (acceptedCount - 1) >= 0 ? (acceptedCount - 1) : 0;

          // Escrituras (todas después de lecturas)
          tx.update(adminAordersDocRef, {'items': updatedItems2});
          tx.update(userAorderDocRef, {'specifications': FieldValue.delete()});
          tx.update(userMainDocRef, {'outstandingCharges': newOutstanding});

          // ✅ AGREGAR NOTIFICACIÓN DE CANCELACIÓN (también en printDate != null)
          _addCancellationNotification(tx, copyshopDocRef, orderCode, registration);

          // actualizar queue en doc principal de copyshop
          if (copyshopSnap.exists) {
            tx.update(copyshopDocRef, {'queue': newQueue});
          } else {
            tx.set(copyshopDocRef, {'queue': newQueue}, SetOptions(merge: true));
          }

          return {
            'backupItems': backupItems,
            'backupSpecs': backupSpecs,
            'originalOutstanding': originalOutstanding,
          };
        });

        // post-transacción: borrar archivo en Storage si aplica
        final String fileUrl = (aorder.url).trim();
        if (fileUrl.isNotEmpty) {
          String storagePath = fileUrl;
          if (fileUrl.startsWith('gs://')) {
            final withoutScheme = fileUrl.substring(5);
            final firstSlash = withoutScheme.indexOf('/');
            storagePath = firstSlash >= 0 ? withoutScheme.substring(firstSlash + 1) : withoutScheme;
          }

          try {
            await storageRepository.deleteFileByPath(storagePath);
            return;
          } on FirebaseException catch (e) {
            final code = (e.code ?? '').toLowerCase();
            if (code.contains('object-not-found') || code.contains('not-found')) {
              return;
            }

            // rollback en Firestore con backups guardados en txResult
            try {
              final Map<String, dynamic> bItems = Map<String, dynamic>.from(txResult['backupItems'] as Map<String, dynamic>);
              final Map<String, dynamic> bSpecs = Map<String, dynamic>.from(txResult['backupSpecs'] as Map<String, dynamic>);
              final num origOut = txResult['originalOutstanding'] as num;

              await _firestore.runTransaction((tx) async {
                final adminSnapCheck = await tx.get(adminAordersDocRef);
                final userAorderSnapCheck = await tx.get(userAorderDocRef);
                final userMainSnapCheck = await tx.get(userMainDocRef);
                if (!adminSnapCheck.exists || !userAorderSnapCheck.exists || !userMainSnapCheck.exists) {
                  throw Exception('Rollback fallido: documentos no existen al intentar revertir.');
                }
                tx.update(adminAordersDocRef, {'items': bItems});
                tx.update(userAorderDocRef, {'specifications': bSpecs});
                tx.update(userMainDocRef, {'outstandingCharges': origOut});
                
                // ✅ ELIMINAR NOTIFICACIÓN EN ROLLBACK
                _removeCancellationNotification(tx, copyshopDocRef, orderCode, registration);
              });

              return Future.error('Error borrando archivo en Storage: ${e.message ?? e}. Se revirtió la operación en Firestore.');
            } catch (rollbackError) {
              return Future.error('Error borrando archivo en Storage: ${e.message ?? e}. Intento de rollback en Firestore falló: $rollbackError. Puede que los datos hayan quedado en estado inconsistente.');
            }
          } catch (e) {
            try {
              final Map<String, dynamic> bItems = Map<String, dynamic>.from(txResult['backupItems'] as Map<String, dynamic>);
              final Map<String, dynamic> bSpecs = Map<String, dynamic>.from(txResult['backupSpecs'] as Map<String, dynamic>);
              final num origOut = txResult['originalOutstanding'] as num;

              await _firestore.runTransaction((tx) async {
                tx.update(adminAordersDocRef, {'items': bItems});
                tx.update(userAorderDocRef, {'specifications': bSpecs});
                tx.update(userMainDocRef, {'outstandingCharges': origOut});
                
                // ✅ ELIMINAR NOTIFICACIÓN EN ROLLBACK
                _removeCancellationNotification(tx, copyshopDocRef, orderCode, registration);
              });

              return Future.error('Error borrando archivo en Storage: $e. Se revirtió la operación en Firestore.');
            } catch (rollbackError) {
              return Future.error('Error borrando archivo en Storage: $e. Intento de rollback en Firestore falló: $rollbackError.');
            }
          }
        } else {
          return;
        }
      }
    }

    return;
  } on FirebaseException catch (e) {
    return Future.error('Error en Firebase eliminando orden del usuario: ${e.message ?? e}');
  } catch (e) {
    return Future.error('Error eliminando orden del usuario: $e');
  }
}

// ✅ MÉTODO PARA AGREGAR NOTIFICACIÓN DE CANCELACIÓN
void _addCancellationNotification(
  Transaction tx, 
  DocumentReference copyshopDocRef, 
  String orderCode, 
  String registration
) {
  final notification = NotificationEntity(
    subject: 'Cancelada #$orderCode', // ✅ Cambiado de "Nueva orden" a "Cancelada"
    message: 'Usu:$registration', // ✅ Se mantiene igual
    dateTime: DateTime.now(),
    seen: false,
  );

  final copyshopNotificationsDoc = copyshopDocRef
      .collection('notifications')
      .doc('information');

  // Añadir la notificación al array 'items' (merge)
  tx.set(copyshopNotificationsDoc, {
    'items': FieldValue.arrayUnion([notification.toMap()]),
  }, SetOptions(merge: true));
}

// ✅ MÉTODO PARA ELIMINAR NOTIFICACIÓN EN ROLLBACK
void _removeCancellationNotification(
  Transaction tx, 
  DocumentReference copyshopDocRef, 
  String orderCode, 
  String registration
) {
  final notificationToRemove = NotificationEntity(
    subject: 'Cancelada #$orderCode',
    message: 'Usu:$registration',
    dateTime: DateTime.now(), // Usamos la misma fecha para identificar
    seen: false,
  );

  final copyshopNotificationsDoc = copyshopDocRef
      .collection('notifications')
      .doc('information');

  // Remover la notificación específica del array 'items'
  tx.update(copyshopNotificationsDoc, {
    'items': FieldValue.arrayRemove([notificationToRemove.toMap()]),
  });
}

@override
Future<void> changeOrderPaymentMethod(
  String userRegistration,
  String copyShopEmail,
  String orderCode,
  String paymentMethod,
) async {
  try {
    final adminDocRef = _firestore
        .collection('copyshops')
        .doc(copyShopEmail)
        .collection('aorders')
        .doc('information');

    final userAorderDocRef = _firestore
        .collection('users')
        .doc(userRegistration)
        .collection('aorder')
        .doc('information');

    final copyshopNotificationsDocRef = _firestore
        .collection('copyshops')
        .doc(copyShopEmail)
        .collection('notifications')
        .doc('information');

    await _firestore.runTransaction((tx) async {
      // --- READS (todas antes de writes) ---
      final adminSnap = await tx.get(adminDocRef);
      final userSnap = await tx.get(userAorderDocRef);
      final notifSnap = await tx.get(copyshopNotificationsDocRef);

      if (!adminSnap.exists) {
        throw Exception(
          'Documento admin (aorders/information) no existe para $copyShopEmail.',
        );
      }
      if (!userSnap.exists) {
        throw Exception(
          'Documento usuario (aorder/information) no existe para $userRegistration.',
        );
      }

      final adminData = adminSnap.data();
      if (adminData == null) {
        throw Exception('Documento admin sin datos para $copyShopEmail.');
      }

      final userData = userSnap.data();
      if (userData == null) {
        throw Exception('Documento usuario sin datos para $userRegistration.');
      }

      final dynamic itemsRaw = adminData['items'];
      if (itemsRaw is! Map) {
        throw Exception(
          'Estructura inválida: "items" no es un Map en admin doc.',
        );
      }

      final dynamic specsRaw = userData['specifications'];
      if (specsRaw == null) {
        throw Exception(
          'Campo "specifications" inexistente en users/{registration}/aorder/information.',
        );
      }
      if (specsRaw is! Map) {
        throw Exception(
          'Estructura inválida: "specifications" no es un Map en user aorder doc.',
        );
      }

      // --- Trabajar en memoria ---
      final Map<String, dynamic> items = Map<String, dynamic>.from(itemsRaw);
      if (!items.containsKey(orderCode)) {
        throw Exception(
          'El orderCode "$orderCode" no existe en items (admin).',
        );
      }

      final dynamic itemRaw = items[orderCode];
      if (itemRaw is! Map) {
        throw Exception(
          'El item para "$orderCode" no tiene la estructura esperada (admin).',
        );
      }

      // --- Preparamos admin update ---
      final Map<String, dynamic> updatedItem =
          Map<String, dynamic>.from(itemRaw);
      updatedItem['paymentMethod'] = paymentMethod;
      items[orderCode] = updatedItem;

      // --- Preparar user specs update ---
      final Map<String, dynamic> specs =
          Map<String, dynamic>.from(specsRaw as Map<String, dynamic>);

      bool userUpdated = false;

      // Si specifications contiene un mapa de órdenes por código (mapa de mapas)
      if (specs.containsKey(orderCode)) {
        final dynamic orderNode = specs[orderCode];
        if (orderNode is! Map) {
          throw Exception(
            'El valor specs[$orderCode] no es un Map como se esperaba.',
          );
        }
        final Map<String, dynamic> updatedOrderNode =
            Map<String, dynamic>.from(orderNode);
        updatedOrderNode['paymentMethod'] = paymentMethod;
        specs[orderCode] = updatedOrderNode;
        userUpdated = true;
      } else {
        // Si specifications es la raíz de la orden (orden en root)
        final dynamic maybeOrderCode = specs['orderCode'];
        if (maybeOrderCode != null && maybeOrderCode.toString() == orderCode) {
          final Map<String, dynamic> updatedRootSpecs =
              Map<String, dynamic>.from(specs);
          updatedRootSpecs['paymentMethod'] = paymentMethod;
          // reemplazamos el contenido del mapa
          specs
            ..clear()
            ..addAll(updatedRootSpecs);
          userUpdated = true;
        }
      }

      if (!userUpdated) {
        throw Exception(
          'No se encontró la orden $orderCode dentro de users/$userRegistration/aorder/information/specifications.',
        );
      }

      // --- Preparar notificación para la copyshop ---
      final Timestamp notifTs = Timestamp.fromDate(DateTime.now().toUtc());
      final Map<String, dynamic> notificationMap = {
        'dateTime': notifTs,
        'message': 'Pago actualizado',
        'seen': false,
        'subject': 'Pago act. #$orderCode',
      };

      // --- WRITES (todas después de las reads) ---
      tx.update(adminDocRef, {'items': items});
      tx.update(userAorderDocRef, {'specifications': specs});

      if (notifSnap.exists) {
        tx.update(copyshopNotificationsDocRef, {
          'items': FieldValue.arrayUnion([notificationMap]),
        });
      } else {
        tx.set(copyshopNotificationsDocRef, {
          'items': [notificationMap],
        }, SetOptions(merge: true));
      }
    });

    return;
  } on FirebaseException catch (e) {
    return Future.error(
      'Error de Firebase cambiando método de pago: ${e.message ?? e}',
    );
  } catch (e) {
    return Future.error('Error cambiando método de pago: $e');
  }
}

  @override
  Future<double> getOutstandingCharges(String registration) async {
    try {
      final docRef = _firestore.collection('users').doc(registration);
      final snap = await docRef.get(const GetOptions(source: Source.server));

      if (!snap.exists) {
        return 0.0;
      }

      final data = snap.data() ?? {};
      final dynamic raw = data['outstandingCharges'] ?? 0;

      // Normalizar a double de forma segura
      if (raw is num) {
        final double value = (raw).toDouble();
        return value.isFinite ? (value < 0 ? 0.0 : value) : 0.0;
      }

      if (raw is String) {
        // permitir tanto "12.34" como "12,34"
        final parsed = double.tryParse(raw.replaceAll(',', '.'));
        if (parsed != null) {
          return parsed.isFinite ? (parsed < 0 ? 0.0 : parsed) : 0.0;
        } else {
          return 0.0;
        }
      }

      // Si viene en otro tipo inesperado
      return 0.0;
    } catch (e) {
      return Future.error('Error obteniendo outstandingCharges: $e');
    }
  }
  
  @override
  Future<void> payOutstandingCharges(String registration) async {
    try {
      final docRef = _firestore.collection('users').doc(registration);
      await docRef.update({'outstandingCharges': 0.0});
    } catch (e) {
      return Future.error('Error actualizando saldo pendiente: $e');
    }
  }

  @override
  Future<void> resetEstimatedDeliveryTimeChangedFlag(
    String userRegistration,
    String copyShopEmail,
    String orderCode,
  ) async {
    try {
      final adminAordersDocRef = _firestore
          .collection('copyshops')
          .doc(copyShopEmail)
          .collection('aorders')
          .doc('information');

      final userAorderDocRef = _firestore
          .collection('users')
          .doc(userRegistration)
          .collection('aorder')
          .doc('information');

      await _firestore.runTransaction((tx) async {
        // --- READS (todas antes de writes) ---
        final adminSnap = await tx.get(adminAordersDocRef);
        final userSnap = await tx.get(userAorderDocRef);

        if (!adminSnap.exists) {
          throw Exception('Documento admin (aorders/information) no existe para $copyShopEmail.');
        }
        if (!userSnap.exists) {
          throw Exception('Documento usuario (aorder/information) no existe para $userRegistration.');
        }

        final adminData = adminSnap.data() ?? {};
        final userData = userSnap.data() ?? {};

        final dynamic itemsRaw = adminData['items'] ?? {};
        if (itemsRaw is! Map) {
          throw Exception('Estructura inválida: "items" no es un Map en admin doc.');
        }

        final dynamic specsRaw = userData['specifications'] ?? {};
        if (specsRaw is! Map) {
          throw Exception('Estructura inválida: "specifications" no es un Map en user doc.');
        }

        // --- Trabajar en memoria ---
        final Map<String, dynamic> items = Map<String, dynamic>.from(itemsRaw);
        if (!items.containsKey(orderCode)) {
          throw Exception('El orderCode "$orderCode" no existe en items (admin).');
        }

        final dynamic itemRaw = items[orderCode];
        if (itemRaw is! Map) {
          throw Exception('El item para "$orderCode" no tiene la estructura esperada (admin).');
        }

        final Map<String, dynamic> updatedItem = Map<String, dynamic>.from(itemRaw);
        updatedItem['hasTheEstimatedDeliveryTimeChanged'] = false;
        items[orderCode] = updatedItem;

        final Map<String, dynamic> updatedSpecs = Map<String, dynamic>.from(specsRaw);
        updatedSpecs['hasTheEstimatedDeliveryTimeChanged'] = false;

        // --- WRITES (después de reads) ---
        tx.update(adminAordersDocRef, {'items': items});
        tx.update(userAorderDocRef, {'specifications': updatedSpecs});
      });

      return;
    } on FirebaseException catch (e) {
      return Future.error(
        'Error de Firebase al resetear isEstimatedDeliveryTimeChanged: ${e.message ?? e}',
      );
    } catch (e) {
      return Future.error('Error al resetear isEstimatedDeliveryTimeChanged: $e');
    }
  }

@override
Future<void> archiveUserOrderForUserOffline(
  AorderEntity aorder,
  String userRegistration,
) async {
  try {
    final userAorderDocRef = _firestore
        .collection('users')
        .doc(userRegistration)
        .collection('aorder')
        .doc('information');

    final userHordersDocRef = _firestore
        .collection('users')
        .doc(userRegistration)
        .collection('horders')
        .doc('information');

    final userMainDocRef = _firestore.collection('users').doc(userRegistration);

    // Helper para convertir DateTime -> Timestamp (UTC) seguro
    Timestamp toTs(DateTime? dt) =>
        dt == null ? Timestamp.now() : Timestamp.fromDate(dt.toUtc());

    // --- Resolver paymentMethod siguiendo la lógica que pediste ---
    Object? paymentMethodObject;
    final dynamic pmRaw = aorder.paymentMethod;

    if (pmRaw == null) {
      paymentMethodObject = '';
    } else if (pmRaw is Map) {
      // ya es un objeto (posible caso donde se guardó info de tarjeta)
      paymentMethodObject = Map<String, dynamic>.from(pmRaw);
    } else {
      final String pmStr = pmRaw.toString();
      if (pmStr.toLowerCase() == 'cash') {
        paymentMethodObject = 'cash';
      } else {
        // intentar leer desde userMain.cardPaymentMethods (offline-friendly: get() usa cache cuando no hay red)
        try {
          final userMainSnap = await userMainDocRef.get();
          if (userMainSnap.exists) {
            final dynamic cardMethodsRaw = userMainSnap.data()?['cardPaymentMethods'];
            if (cardMethodsRaw is Map && cardMethodsRaw.containsKey(pmStr)) {
              final found = cardMethodsRaw[pmStr];
              if (found is Map) {
                paymentMethodObject = Map<String, dynamic>.from(found);
              } else {
                // por seguridad, si no es Map guardamos el token
                paymentMethodObject = pmStr;
              }
            } else {
              // no existe el metodo en el mapa del usuario -> guardamos el token
              paymentMethodObject = pmStr;
            }
          } else {
            // no existe user doc en cache -> fallback a token
            paymentMethodObject = pmStr;
          }
        } catch (_) {
          // cualquier error leyendo -> fallback a token
          paymentMethodObject = pmStr;
        }
      }
    }

    // --- Construir el mapa de historial (compatible con HorderEntity.toMap) ---
    final Map<String, dynamic> horderMap = {
      'copyShopName': aorder.copyShopName ?? '',
      'userName': aorder.userName ?? '',
      'userRegistration': aorder.userRegistration?.toString() ?? userRegistration,
      'finalDate': toTs(aorder.estimatedDeliveryTime ?? aorder.initDate),
      'format': aorder.format ?? '',
      'initDate': toTs(aorder.initDate),
      'isColor': aorder.isColor ?? false,
      'pages': aorder.pages ?? 0,
      'pdfName': aorder.pdfName ?? '',
      // place: si tienes lat/long prefieres eso; si tienes campo place úsalo:
      'place': (aorder.copyShopEmail != null && aorder.copyShopEmail!.isNotEmpty)
          ? aorder.copyShopEmail
          : ((aorder.placeLat != null && aorder.placeLong != null)
              ? '${aorder.placeLat},${aorder.placeLong}'
              : ''),
      'price': aorder.price ?? 0.0,
      'url': aorder.url ?? '',
      'paymentMethod': paymentMethodObject,
      'orderCode': aorder.orderCode ?? '',
      'hasItBeenCanceledByUser': aorder.hasItBeenCanceledByUser ?? false,
      'copyShopEmail': aorder.copyShopEmail ?? '',
    };

    // 1) Añadir al historial usando arrayUnion (offline-friendly)
    await userHordersDocRef.set({
      'items': FieldValue.arrayUnion([horderMap]),
    }, SetOptions(merge: true));

    // 2) Borrar specifications del doc aorder (si existe). Si el doc no existe, no es crítico.
    try {
      await userAorderDocRef.update({'specifications': FieldValue.delete()});
    } on FirebaseException catch (e) {
      final code = (e.code ?? '').toString().toLowerCase();
      if (code.contains('not-found') || code.contains('not_exists') || code.contains('not-found')) {
        // documento no existe en cache/local -> no crítico
        print('archiveUserOrderForUserOffline: user aorder doc no existe al intentar borrar specifications (no crítico).');
      } else {
        // otros errores los re-lanzamos
        rethrow;
      }
    }

    return;
  } on FirebaseException catch (e) {
    return Future.error('Error de Firebase archivando orden (offline-friendly): ${e.message ?? e}');
  } catch (e) {
    return Future.error('Error archivando orden (offline-friendly): $e');
  }
}


}

