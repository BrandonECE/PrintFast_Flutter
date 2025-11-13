import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:printfast_rebuild/domain/entities/entities.dart';
import 'package:printfast_rebuild/domain/repositories/storage_repository.dart';
import 'package:printfast_rebuild/domain/services/admin_service.dart';

class AdminServiceImpl extends AdminService {
  final FirebaseFirestore _firestore;
  final StorageRepository storageRepository;

  AdminServiceImpl({
    FirebaseFirestore? firestore,
    required this.storageRepository,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<CopyShopEntity> getCopyShopInfo(String adminLocationByEmail) async {
    try {
      final docRef = _firestore
          .collection('copyshops')
          .doc(adminLocationByEmail);
      final snapshot = await docRef.get(
        const GetOptions(source: Source.server),
      );

      if (!snapshot.exists) {
        return Future.error(
          'No se encontró el copyshop para: $adminLocationByEmail',
        );
      }

      final data = snapshot.data();
      if (data == null) {
        return Future.error('Documento vacío para: $adminLocationByEmail');
      }

      final Map<String, dynamic> map = Map<String, dynamic>.from(data);
      return CopyShopEntity.fromMap(map);
    } on FirebaseException catch (e) {
      return Future.error(
        'Firebase error obteniendo copyshop: ${e.code} ${e.message}',
      );
    } catch (e) {
      return Future.error('Error obteniendo copyshop: $e');
    }
  }

  @override
  Stream<List<AorderEntity>> getAordersStream(String copyShopEmail) {
    final controller = StreamController<List<AorderEntity>>();
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? snapSub;
    StreamSubscription? connSub; // sin genérico para evitar mismatches
    bool isOnline = true;

    final collectionRef = _firestore
        .collection('copyshops')
        .doc(copyShopEmail)
        .collection('aorders');

    // (Re)subscribir a los snapshots de Firestore
    void subscribeToSnapshots() {
      if (snapSub != null) {
        snapSub!.resume();
        return;
      }

      snapSub = collectionRef.snapshots().listen(
        (snapshot) {
          // Si estamos offline, ignoramos emisiones de la cache
          if (!isOnline) return;

          final List<AorderEntity> result = [];

          for (final doc in snapshot.docs) {
            final Map<String, dynamic> data =
                doc.data() as Map<String, dynamic>? ?? {};

            try {
              final items = data['items'];

              if (items is Map) {
                // items: Map<String, dynamic> donde cada value es otro Map
                items.forEach((key, value) {
                  if (value is Map<String, dynamic>) {
                    try {
                      result.add(AorderEntity.fromMap(value));
                    } catch (e, st) {
                      controller.addError(
                        'Error convirtiendo item $key: $e\n$st',
                      );
                    }
                  } else {
                    controller.addError(
                      'Warning: item $key no es Map, es ${value.runtimeType}',
                    );
                  }
                });
              } else if (items is List) {
                // items: List de maps
                for (var value in items) {
                  if (value is Map<String, dynamic>) {
                    try {
                      result.add(AorderEntity.fromMap(value));
                    } catch (e, st) {
                      controller.addError(
                        'Error convirtiendo item en lista: $e\n$st',
                      );
                    }
                  } else {
                    controller.addError(
                      'Warning: item en lista no es Map, es ${value.runtimeType}',
                    );
                  }
                }
              } else {
                // Fallback: el documento ya es una orden plana
                try {
                  result.add(AorderEntity.fromMap(data));
                } catch (e, st) {
                  controller.addError(
                    'No hay items y falla fromMap con doc ${doc.id}: $e\n$st',
                  );
                }
              }
            } catch (e, st) {
              controller.addError('Error procesando doc ${doc.id}: $e\n$st');
            }
          } // for docs

          // Emitimos la lista (aunque vacía)
          controller.add(result);
        },
        onError: (error) {
          controller.addError('Error snapshots aorders: $error');
        },
      );
    }

    // Chequeo inicial de conectividad y subscripción
    Connectivity()
        .checkConnectivity()
        .then((status) {
          isOnline = status.first != ConnectivityResult.none;
          if (!isOnline) {
            controller.addError('Sin conexión');
          } else {
            subscribeToSnapshots();
          }
        })
        .catchError((e) {
          // Si falló el check inicial, asumimos online y subscribimos
          isOnline = true;
          subscribeToSnapshots();
        });

    // Escuchar cambios de conectividad (manejo seguro si status viene como List o ConnectivityResult)
    connSub = Connectivity().onConnectivityChanged.listen((status) {
      bool nowOnline;
      if (status is ConnectivityResult) {
        nowOnline = status.first != ConnectivityResult.none;
      } else {
        nowOnline = status.any((s) => s != ConnectivityResult.none);
      }

      if (nowOnline && !isOnline) {
        // volvemos online: (re)subscribimos
        isOnline = true;
        try {
          subscribeToSnapshots();
        } catch (e) {
          controller.addError('Error al re-suscribir snapshots: $e');
        }
      } else if (!nowOnline && isOnline) {
        // pasamos a offline: pausamos la subscripción y emitimos error
        isOnline = false;
        snapSub?.pause();
        controller.addError('Sin conexión');
      }
    });

    // Limpieza cuando cancelen el stream
    controller.onCancel = () async {
      await connSub?.cancel();
      await snapSub?.cancel();
      await controller.close();
    };

    return controller.stream;
  }

  @override
  Future<List<HorderEntity>> getCopyShopHOrders(String copyShopEmail) async {
    try {
      final docRef = _firestore
          .collection('copyshops')
          .doc(copyShopEmail)
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
  Future<List<NotificationEntity>> getCopyShopNotifications(
    String copyShopEmail,
  ) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('copyshops')
          .doc(copyShopEmail)
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
  Stream<int> unseenCopyShopNotificationsCount(String copyShopEmail) {
    try {
      return _firestore
          .collection('copyshops')
          .doc(copyShopEmail)
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
  Future<void> markAllCopyShopNotificationsAsSeen(String copyShopEmail) async {
    try {
      final documentRef = _firestore
          .collection('copyshops')
          .doc(copyShopEmail)
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
  Stream<bool> getCopyShopReceptionAvailabilityValue(String copyShopEmail) {
    final controller = StreamController<bool>();
    StreamSubscription? snapSub;

    final connSub = Connectivity().onConnectivityChanged.listen((status) {
      final offline = status.first == ConnectivityResult.none;
      if (offline) {
        // cuando pierdes la conexión, cancela/pausa el listener de Firestore y emite error
        snapSub?.pause();
        controller.addError('Sin conexión');
        return;
      }

      // si hay conexión y aún no estamos suscritos, suscribimos al snapshots
      snapSub ??= FirebaseFirestore.instance
          .collection('copyshops')
          .doc(copyShopEmail)
          .snapshots()
          .listen((snapshot) {
            try {
              if (!snapshot.exists) throw Exception('Documento inexistente');
              final data = snapshot.data();
              if (data == null) throw Exception('Datos null');
              final raw = data['pauseReception'];
              if (raw is! bool) throw Exception('pauseReception no es bool');
              controller.add(raw);
            } catch (e) {
              controller.addError(e);
            }
          }, onError: controller.addError);
      snapSub?.resume();
    });

    controller.onCancel = () async {
      await connSub.cancel();
      await snapSub?.cancel();
      await controller.close();
    };

    return controller.stream;
  }

  @override
  Future<void> updateCopyShopReceptionAvailabilityValue(
    String copyShopEmail,
    bool copyShopReceptionAvailabilityValue,
  ) async {
    final conn = await Connectivity().checkConnectivity();
    if (conn.first == ConnectivityResult.none) {
      return Future.error('Sin conexión: no se puede actualizar ahora');
    }

    try {
      await _firestore.collection('copyshops').doc(copyShopEmail).update({
        'pauseReception': copyShopReceptionAvailabilityValue,
      });

      // OPCIONAL: esperar confirmación del servidor (fallará si no llega en X segundos)
      await _firestore.waitForPendingWrites().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw Exception(
            'No se confirmó la escritura en el servidor (timeout).',
          );
        },
      );
    } on FirebaseException catch (e) {
      return Future.error('Error de Firebase al actualizar: ${e.message}');
    } catch (e) {
      return Future.error(
        'Error actualizando copyShopReceptionAvailabilityValue: $e',
      );
    }
  }

  @override
  Future<CardPaymentMethodEntity?> getUserCard(
    String userRegistration,
    String token,
  ) async {
    try {
      final docRef = _firestore.collection('users').doc(userRegistration);

      // Atención: Source.server obliga a consultar el servidor (fallará si estás offline).
      final snap = await docRef.get(const GetOptions(source: Source.server));

      if (!snap.exists) return null;

      final data = snap.data(); // casteo seguro
      if (data == null) return null;

      final rawMap = data['cardPaymentMethods'];
      if (rawMap is! Map) return null;

      final tokenMap = rawMap[token];
      if (tokenMap is! Map<String, dynamic>) return null;

      // Si fromMap lanza, lo capturamos y devolvemos un error controlado
      try {
        final CardPaymentMethodEntity userCard =
            CardPaymentMethodEntity.fromMap(tokenMap);
        return userCard;
      } catch (e) {
        return Future.error('Error parseando tarjeta: $e');
      }
    } on FirebaseException catch (e) {
      // Errores específicos de Firebase (ej. permisos, timeout, offline con Source.server, etc.)
      return Future.error(
        'Error de Firebase obteniendo tarjeta: ${e.message ?? e}',
      );
    } catch (e) {
      return Future.error('Error obteniendo tarjeta: $e');
    }
  }

  @override
  Future<void> acceptPendingOrder(
    String userRegistration,
    String copyShopEmail,
    String orderCode,
  ) async {
    try {
      final adminDocRef = _firestore
          .collection('copyshops')
          .doc(copyShopEmail)
          .collection('aorders')
          .doc('information');

      final copyshopDocRef = _firestore
          .collection('copyshops')
          .doc(copyShopEmail);

      final userAorderRef = _firestore
          .collection('users')
          .doc(userRegistration)
          .collection('aorder')
          .doc('information');

      final userNotificationsRef = _firestore
          .collection('users')
          .doc(userRegistration)
          .collection('notifications')
          .doc('information');

      // ✅ OBTENER TIMESTAMP ANTES de la transacción
      final timestamp = DateTime.now();

      await _firestore.runTransaction((tx) async {
        // ---------- READS ----------
        final adminSnap = await tx.get(adminDocRef);
        final userAorderSnap = await tx.get(userAorderRef);
        final copyshopSnap = await tx.get(copyshopDocRef);
        final userNotifSnap = await tx.get(userNotificationsRef);

        if (!adminSnap.exists) {
          throw Exception('Documento admin (aorders/information) no existe.');
        }
        if (!userAorderSnap.exists) {
          throw Exception('Documento usuario (aorder/information) no existe.');
        }

        final adminData = adminSnap.data() ?? {};
        final userAorderData = userAorderSnap.data() ?? {};

        final itemsRaw = adminData['items'];
        final specsRaw = userAorderData['specifications'];

        if (itemsRaw is! Map) {
          throw Exception(
            'Estructura inválida: "items" no es un Map en admin doc.',
          );
        }
        if (specsRaw is! Map) {
          throw Exception(
            'Estructura inválida: "specifications" no es un Map en user doc.',
          );
        }

        // ---------- WORK IN MEMORY ----------
        final Map<String, dynamic> items = Map<String, dynamic>.from(itemsRaw);
        if (!items.containsKey(orderCode)) {
          throw Exception(
            'El orderCode "$orderCode" no existe en items (admin).',
          );
        }

        final itemRaw = items[orderCode];
        if (itemRaw is! Map) {
          throw Exception(
            'El item para "$orderCode" no tiene la estructura esperada (admin).',
          );
        }

        final Map<String, dynamic> updatedItem = Map<String, dynamic>.from(
          itemRaw,
        );
        updatedItem['hasItBeenAccepted'] = true;
        // ✅ CAMBIO: Usar DateTime normal en lugar de FieldValue.serverTimestamp()
        updatedItem['initDate'] = timestamp;
        items[orderCode] = updatedItem;

        final Map<String, dynamic> updatedSpecs = Map<String, dynamic>.from(
          specsRaw,
        );
        updatedSpecs['hasItBeenAccepted'] = true;
        // ✅ CAMBIO: Usar DateTime normal
        updatedSpecs['initDate'] = timestamp;

        // calcular queue
        int acceptedCount = 0;
        items.forEach((key, value) {
          try {
            if (value is Map) {
              final h = value['hasItBeenAccepted'];
              final canceled = value['hasItBeenCanceledByUser'];

              final bool isAccepted =
                  (h == true) ||
                  (h is String && h.toLowerCase() == 'true') ||
                  (h is num && h != 0);

              final bool isCanceled =
                  (canceled == true) ||
                  (canceled is String && canceled.toLowerCase() == 'true') ||
                  (canceled is num && canceled != 0);

              if (isAccepted && !isCanceled) {
                acceptedCount++;
              }
            }
          } catch (_) {}
        });
        final int newQueueValue = acceptedCount;

        // ✅ CAMBIO: Usar DateTime normal para notificaciones
        final Map<String, dynamic> newNotif = {
          'dateTime': timestamp,
          'message': 'Pronto estara listo.',
          'seen': false,
          'subject': 'Orden aceptada',
        };

        // ---------- WRITES ----------
        tx.update(adminDocRef, {'items': items});
        tx.update(userAorderRef, {'specifications': updatedSpecs});

        if (copyshopSnap.exists) {
          tx.update(copyshopDocRef, {'queue': newQueueValue});
        } else {
          tx.set(copyshopDocRef, {
            'queue': newQueueValue,
          }, SetOptions(merge: true));
        }

        // Notificaciones
        if (userNotifSnap.exists) {
          tx.update(userNotificationsRef, {
            'items': FieldValue.arrayUnion([newNotif]),
          });
        } else {
          tx.set(userNotificationsRef, {
            'items': [newNotif],
          });
        }
      });

      return;
    } on FirebaseException catch (e) {
      print('acceptPendingOrder - FirebaseException: ${e.code} ${e.message}');
      return Future.error(
        'Error de Firebase aceptando orden: ${e.message ?? e}',
      );
    } catch (e, st) {
      print('acceptPendingOrder - Exception: $e\n$st');
      return Future.error('Error aceptando orden: $e');
    }
  }

  @override
  Future<void> rejectPendingOrder(
    String userRegistration,
    String copyShopEmail,
    String orderCode,
    String fileUrl,
  ) async {
    try {
      // ✅ Obtener timestamp ANTES de la transacción
      final timestamp = DateTime.now();

      final adminDocRef = _firestore
          .collection('copyshops')
          .doc(copyShopEmail)
          .collection('aorders')
          .doc('information');

      final userDocRef = _firestore
          .collection('users')
          .doc(userRegistration)
          .collection('aorder')
          .doc('information');

      // ✅ Agregar referencia a notificaciones
      final userNotificationsRef = _firestore
          .collection('users')
          .doc(userRegistration)
          .collection('notifications')
          .doc('information');

      // Transacción: eliminar items[orderCode] y actualizar specifications.hasItBeenAccepted = false
      final Map<String, dynamic> txResult = await _firestore.runTransaction((
        tx,
      ) async {
        // --- Leer admin doc ---
        final adminSnap = await tx.get(adminDocRef);
        if (!adminSnap.exists) {
          throw Exception('Documento admin (aorders/information) no existe.');
        }
        final adminData = adminSnap.data();
        if (adminData == null) {
          throw Exception('Documento admin sin datos.');
        }

        final itemsRaw = adminData['items'];
        if (itemsRaw is! Map<String, dynamic>) {
          throw Exception(
            'Estructura inválida: "items" no es un Map en admin doc.',
          );
        }

        if (!itemsRaw.containsKey(orderCode)) {
          throw Exception(
            'El orderCode "$orderCode" no existe en items (admin).',
          );
        }

        // Copia de seguridad
        final Map<String, dynamic> originalItems = Map<String, dynamic>.from(
          itemsRaw,
        );

        // Verificamos que el item tenga la estructura esperada
        final itemRaw = itemsRaw[orderCode];
        if (itemRaw is! Map<String, dynamic>) {
          throw Exception(
            'El item para "$orderCode" no tiene la estructura esperada (admin).',
          );
        }

        // Construimos items actualizado sin la key orderCode (eliminamos)
        final Map<String, dynamic> updatedItems = Map<String, dynamic>.from(
          itemsRaw,
        );
        updatedItems.remove(orderCode);

        // --- Leer user doc ---
        final userSnap = await tx.get(userDocRef);
        if (!userSnap.exists) {
          throw Exception('Documento usuario (aorder/information) no existe.');
        }
        final userData = userSnap.data();
        if (userData == null) {
          throw Exception('Documento usuario sin datos.');
        }

        final specsRaw = userData['specifications'];
        if (specsRaw is! Map<String, dynamic>) {
          throw Exception(
            'Estructura inválida: "specifications" no es un Map en user doc.',
          );
        }

        // Copia de seguridad
        final Map<String, dynamic> originalSpecs = Map<String, dynamic>.from(
          specsRaw,
        );

        // Actualizamos specifications: solo setear hasItBeenAccepted = false
        final Map<String, dynamic> updatedSpecs = Map<String, dynamic>.from(
          specsRaw,
        );
        updatedSpecs['hasItBeenAccepted'] = false;
        // ✅ CAMBIO: Usar DateTime.now() en lugar de FieldValue.serverTimestamp()
        updatedSpecs['rejectedAt'] = timestamp;

        // ✅ Leer notificaciones
        final userNotifSnap = await tx.get(userNotificationsRef);

        final Map<String, dynamic> notifMap = {
          'dateTime': timestamp, // ✅ Usar DateTime.now()
          'message': 'Inténtalo de nuevo.',
          'seen': false, // ✅
          'subject': 'Orden rechazada',
        };

        // Aplicamos los cambios dentro de la transacción
        tx.update(adminDocRef, {'items': updatedItems});
        tx.update(userDocRef, {'specifications': updatedSpecs});

        // ✅ Agregar notificación
        if (userNotifSnap.exists) {
          tx.update(userNotificationsRef, {
            'items': FieldValue.arrayUnion([notifMap]),
          });
        } else {
          tx.set(userNotificationsRef, {
            'items': [notifMap],
          });
        }

        // Retornamos datos necesarios para post-proceso (rollback si delete falla)
        return {'originalItems': originalItems, 'originalSpecs': originalSpecs};
      });

      // Transacción aplicada con éxito
      final Map<String, dynamic> originalItems = Map<String, dynamic>.from(
        txResult['originalItems'] as Map<String, dynamic>,
      );
      final Map<String, dynamic> originalSpecs = Map<String, dynamic>.from(
        txResult['originalSpecs'] as Map<String, dynamic>,
      );

      // Si el caller pasó fileUrl, intentamos borrarlo en Storage
      if (fileUrl.isNotEmpty) {
        // Convertir gs://bucket/path -> path (path = parte después del bucket)
        String storagePath = fileUrl;
        if (fileUrl.startsWith('gs://')) {
          final withoutScheme = fileUrl.substring(5); // remove 'gs://'
          final firstSlash = withoutScheme.indexOf('/');
          storagePath = firstSlash >= 0
              ? withoutScheme.substring(firstSlash + 1)
              : withoutScheme;
        }

        try {
          await storageRepository.deleteFileByPath(storagePath);
          // eliminado correctamente
          return;
        } catch (e) {
          // Si falla la eliminación en Storage, intentamos rollback en Firestore
          try {
            await _firestore.runTransaction((tx) async {
              // Verificamos existencia actual antes de reescribir (por seguridad)
              final adminSnap = await tx.get(adminDocRef);
              final userSnap = await tx.get(userDocRef);
              final userNotifSnap = await tx.get(userNotificationsRef);

              if (!adminSnap.exists || !userSnap.exists) {
                throw Exception(
                  'Rollback fallido: documentos no existen al intentar revertir.',
                );
              }
              tx.update(adminDocRef, {'items': originalItems});
              tx.update(userDocRef, {'specifications': originalSpecs});

              // ✅ También revertir la notificación si existe
              if (userNotifSnap.exists) {
                // Para revertir la notificación, necesitaríamos guardar el estado original
                // Pero por simplicidad, al menos intentamos eliminar la notificación recién agregada
                final notifData = userNotifSnap.data() ?? {};
                final notifItems = List<dynamic>.from(notifData['items'] ?? []);
                if (notifItems.isNotEmpty) {
                  // Eliminar la última notificación (asumiendo que fue la que acabamos de agregar)
                  notifItems.removeLast();
                  tx.update(userNotificationsRef, {'items': notifItems});
                }
              }
            });
            // rollback aplicado
            return Future.error(
              'Error borrando archivo en Storage: $e. Se revirtió la operación en Firestore.',
            );
          } catch (rollbackError) {
            return Future.error(
              'Error borrando archivo en Storage: $e. Intento de rollback en Firestore falló: $rollbackError. '
              'Puede que los datos hayan quedado en estado inconsistente.',
            );
          }
        }
      } else {
        // No hay archivo que borrar -> operación completada
        return;
      }
    } on FirebaseException catch (e) {
      return Future.error(
        'Error de Firebase rechazando orden: ${e.message ?? e}',
      );
    } catch (e) {
      return Future.error('Error rechazando orden: $e');
    }
  }

  @override
  Future<void> markOrderAsPrinting(
    String userRegistration,
    String copyShopEmail,
    String orderCode,
  ) async {
    try {
      final adminDocRef = _firestore
          .collection('copyshops')
          .doc(copyShopEmail)
          .collection('aorders')
          .doc('information');

      final userDocRef = _firestore
          .collection('users')
          .doc(userRegistration)
          .collection('aorder')
          .doc('information');

      final userNotificationsDocRef = _firestore
          .collection('users')
          .doc(userRegistration)
          .collection('notifications')
          .doc('information');

      await _firestore.runTransaction((tx) async {
        // --- READS (todas antes de writes) ---
        final adminSnap = await tx.get(adminDocRef);
        final userSnap = await tx.get(userDocRef);
        final notifSnap = await tx.get(userNotificationsDocRef);

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
          throw Exception(
            'Documento usuario sin datos para $userRegistration.',
          );
        }

        final dynamic itemsRaw = adminData['items'];
        if (itemsRaw is! Map) {
          throw Exception(
            'Estructura inválida: "items" no es un Map en admin doc.',
          );
        }

        final dynamic specsRaw = userData['specifications'];
        if (specsRaw is! Map) {
          throw Exception(
            'Estructura inválida: "specifications" no es un Map en user doc.',
          );
        }

        // --- Actualizar en memoria ---
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

        final Map<String, dynamic> updatedItem = Map<String, dynamic>.from(
          itemRaw,
        );
        // marcar printDate en el admin (server timestamp)
        updatedItem['printDate'] = FieldValue.serverTimestamp();
        items[orderCode] = updatedItem;

        // actualizar specifications en memoria (usuario)
        final Map<String, dynamic> specs = Map<String, dynamic>.from(specsRaw);
        specs['printDate'] = FieldValue.serverTimestamp();

        // --- Preparar notificación corta ---
        final Timestamp notifTs = Timestamp.fromDate(DateTime.now().toUtc());
        final Map<String, dynamic> notificationMap = {
          'dateTime': notifTs,
          'message': 'Tu orden está en impresión.',
          'seen': false,
          'subject': 'Imprimiendo',
        };

        // --- WRITES (después de las reads) ---
        tx.update(adminDocRef, {'items': items});
        tx.update(userDocRef, {'specifications': specs});

        if (notifSnap.exists) {
          tx.update(userNotificationsDocRef, {
            'items': FieldValue.arrayUnion([notificationMap]),
          });
        } else {
          tx.set(userNotificationsDocRef, {
            'items': [notificationMap],
          }, SetOptions(merge: true));
        }
      });

      // transacción exitosa
      return;
    } on FirebaseException catch (e) {
      return Future.error(
        'Error de Firebase marcando printDate: ${e.message ?? e}',
      );
    } catch (e) {
      return Future.error('Error marcando printDate: $e');
    }
  }

  @override
  Future<void> updateEstimatedDeliveryTime(
    String userRegistration,
    String copyShopEmail,
    String orderCode,
    DateTime newDeliveryTime, {
    bool updateHasTheEstimatedDeliveryTimeChanged = false,
  }) async {
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

      final userNotificationsDocRef = _firestore
          .collection('users')
          .doc(userRegistration)
          .collection('notifications')
          .doc('information');

      // Timestamp a guardar para el estimatedDeliveryTime (UTC)
      final Timestamp newEstimateTs = Timestamp.fromDate(
        newDeliveryTime.toUtc(),
      );

      await _firestore.runTransaction((tx) async {
        // --- READS (todas antes de writes) ---
        final adminSnap = await tx.get(adminDocRef);
        final userSnap = await tx.get(userAorderDocRef);
        final notifSnap = await tx.get(userNotificationsDocRef);

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

        final adminData = adminSnap.data() ?? {};
        final userData = userSnap.data() ?? {};

        final dynamic itemsRaw = adminData['items'] ?? {};
        if (itemsRaw is! Map) {
          throw Exception(
            'Estructura inválida: "items" no es un Map en admin doc.',
          );
        }

        final dynamic specsRaw = userData['specifications'] ?? {};
        if (specsRaw is! Map) {
          throw Exception(
            'Estructura inválida: "specifications" no es un Map en user doc.',
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

        final Map<String, dynamic> updatedItem = Map<String, dynamic>.from(
          itemRaw,
        );
        updatedItem['estimatedDeliveryTime'] = newEstimateTs;
        if (updateHasTheEstimatedDeliveryTimeChanged) {
          updatedItem['hasTheEstimatedDeliveryTimeChanged'] = true;
        }
        items[orderCode] = updatedItem;

        final Map<String, dynamic> updatedSpecs = Map<String, dynamic>.from(
          specsRaw,
        );
        updatedSpecs['estimatedDeliveryTime'] = newEstimateTs;
        if (updateHasTheEstimatedDeliveryTimeChanged) {
          updatedSpecs['hasTheEstimatedDeliveryTimeChanged'] = true;
        }

        // --- Preparar notificación ---
        // Uso Timestamp.now() en UTC para evitar FieldValue.serverTimestamp() dentro
        // de la estructura de la lista (reduce posibilidad de error en la transacción).
        final Timestamp notifTs = Timestamp.fromDate(DateTime.now().toUtc());
        final Map<String, dynamic> notificationMap = {
          'dateTime': notifTs,
          'message': 'Fecha de entrega actualizada.',
          'seen': false,
          'subject': 'Entrega actualizada',
        };

        // --- WRITES (después de todas las reads) ---
        tx.update(adminDocRef, {'items': items});
        tx.update(userAorderDocRef, {'specifications': updatedSpecs});

        // Añadir notificación de forma segura:
        if (notifSnap.exists) {
          // Si existe doc de notifications usamos arrayUnion para no reescribir toda la lista
          tx.update(userNotificationsDocRef, {
            'items': FieldValue.arrayUnion([notificationMap]),
          });
        } else {
          // Si no existe, crearlo (merge: true para no eliminar otros campos)
          tx.set(userNotificationsDocRef, {
            'items': [notificationMap],
          }, SetOptions(merge: true));
        }
      });

      return;
    } on FirebaseException catch (e, st) {
      // loguea para depuración; devuelve el mensaje para el caller
      print('FirebaseException en updateEstimatedDeliveryTime: ${e.message}');
      print(st);
      return Future.error(
        'Error de Firebase actualizando estimatedDeliveryTime: ${e.message ?? e}',
      );
    } catch (e, st) {
      print('Error en updateEstimatedDeliveryTime: $e');
      print(st);
      return Future.error('Error actualizando estimatedDeliveryTime: $e');
    }
  }

  @override
  Future<void> archiveAcceptedOrderCanceledByUser(AorderEntity aorder) async {
    try {
      final orderCode = aorder.orderCode;
      final copyShopEmail = aorder.copyShopEmail;
      final userRegistration = aorder.userRegistration;

      if (orderCode.isEmpty) {
        return Future.error('orderCode vacío en AorderEntity.');
      }
      if (copyShopEmail.isEmpty) {
        return Future.error('copyShopEmail vacío en AorderEntity.');
      }
      if (userRegistration.isEmpty) {
        return Future.error('userRegistration vacío en AorderEntity.');
      }

      final adminAordersDocRef = _firestore
          .collection('copyshops')
          .doc(copyShopEmail)
          .collection('aorders')
          .doc('information');

      final hordersDocRef = _firestore
          .collection('copyshops')
          .doc(copyShopEmail)
          .collection('horders')
          .doc('information');

      final userDocRef = _firestore.collection('users').doc(userRegistration);

      await _firestore.runTransaction((tx) async {
        // --- READS (todas antes de writes) ---
        final adminSnap = await tx.get(adminAordersDocRef);
        final hordersSnap = await tx.get(hordersDocRef);
        final userSnap = await tx.get(userDocRef);

        if (!adminSnap.exists) {
          throw Exception(
            'Documento admin (aorders/information) no existe para $copyShopEmail.',
          );
        }

        final adminData = adminSnap.data() ?? {};
        final dynamic itemsRaw = adminData['items'] ?? {};
        if (itemsRaw is! Map) {
          throw Exception(
            'Estructura inválida: "items" no es un Map en admin doc.',
          );
        }

        final Map<String, dynamic> itemsMap = Map<String, dynamic>.from(
          itemsRaw,
        );
        if (!itemsMap.containsKey(orderCode)) {
          throw Exception(
            'El orderCode "$orderCode" no existe en items (admin).',
          );
        }

        // Extraer el item original
        final dynamic itemRaw = itemsMap[orderCode];
        if (itemRaw is! Map) {
          throw Exception(
            'El item para "$orderCode" no tiene la estructura esperada (admin).',
          );
        }
        final Map<String, dynamic> itemMap = Map<String, dynamic>.from(itemRaw);

        // --- Construir el objeto historico (map) ---
        // finalDate: usar estimatedDeliveryTime si existe, si no usar initDate o now
        DateTime finalDate = DateTime.now();
        if (itemMap.containsKey('estimatedDeliveryTime') &&
            itemMap['estimatedDeliveryTime'] != null) {
          finalDate = (itemMap['estimatedDeliveryTime'] is Timestamp)
              ? (itemMap['estimatedDeliveryTime'] as Timestamp).toDate()
              : DateTime.tryParse(
                      itemMap['estimatedDeliveryTime'].toString(),
                    ) ??
                    finalDate;
        } else if (itemMap.containsKey('finalDate') &&
            itemMap['finalDate'] != null) {
          finalDate = (itemMap['finalDate'] is Timestamp)
              ? (itemMap['finalDate'] as Timestamp).toDate()
              : DateTime.tryParse(itemMap['finalDate'].toString()) ?? finalDate;
        } else if (itemMap.containsKey('initDate') &&
            itemMap['initDate'] != null) {
          finalDate = (itemMap['initDate'] is Timestamp)
              ? (itemMap['initDate'] as Timestamp).toDate()
              : DateTime.tryParse(itemMap['initDate'].toString()) ?? finalDate;
        }

        DateTime initDate = DateTime.now();
        if (itemMap.containsKey('initDate') && itemMap['initDate'] != null) {
          initDate = (itemMap['initDate'] is Timestamp)
              ? (itemMap['initDate'] as Timestamp).toDate()
              : DateTime.tryParse(itemMap['initDate'].toString()) ?? initDate;
        }

        // Buscar paymentMethod: si es 'cash' -> 'cash', si no -> intentar traer el mapa desde users/<reg>.cardPaymentMethods[token]
        Object? pmForHistory;
        final dynamic rawPaymentMethod =
            itemMap['paymentMethod'] ??
            itemMap['paymentMethodToken'] ??
            aorder.paymentMethod;
        final String maybeToken = rawPaymentMethod?.toString() ?? '';

        if (maybeToken.toLowerCase() == 'cash' || maybeToken.isEmpty) {
          pmForHistory = 'cash';
        } else {
          // intentar leer cardPaymentMethods del user (ya hicimos userSnap arriba en la transacción)
          if (userSnap.exists) {
            final userData = userSnap.data() ?? {};
            final dynamic cardMethodsRaw = userData['cardPaymentMethods'] ?? {};
            if (cardMethodsRaw is Map &&
                cardMethodsRaw.containsKey(maybeToken)) {
              final dynamic cardObj = cardMethodsRaw[maybeToken];
              if (cardObj is Map) {
                pmForHistory = Map<String, dynamic>.from(cardObj);
              } else {
                pmForHistory = cardObj; // fallback
              }
            } else {
              // no existe el metodo en el usuario -> guardar token como string (para no fallar)
              pmForHistory = maybeToken;
            }
          } else {
            // no existe user doc -> guardar token como string
            pmForHistory = maybeToken;
          }
        }

        // Rellenar campos del historial tomando desde itemMap / aorder (preferir itemMap si existe)
        final Map<String, dynamic> horderMap = {
          'copyShopName':
              itemMap['copyShopName']?.toString() ?? aorder.copyShopName ?? '',
          'userRegistration':
              itemMap['userRegistration']?.toString() ??
              aorder.userRegistration ??
              '',
          'userName': itemMap['userName']?.toString() ?? aorder.userName ?? '',
          'finalDate': finalDate,
          'format': itemMap['format']?.toString() ?? aorder.format ?? '',
          'initDate': initDate,
          'isColor': (itemMap['isColor'] is bool)
              ? itemMap['isColor']
              : (aorder.isColor ?? false),
          'pages': (itemMap['pages'] is int)
              ? itemMap['pages']
              : (int.tryParse('${itemMap['pages'] ?? aorder.pages ?? 0}') ??
                    (aorder.pages ?? 0)),
          'pdfName': itemMap['pdfName']?.toString() ?? aorder.pdfName ?? '',
          'place': itemMap['place']?.toString() ?? aorder.copyShopName ?? '',
          'price': (itemMap['price'] is num)
              ? (itemMap['price'] as num).toDouble()
              : (double.tryParse(
                      '${itemMap['price'] ?? aorder.price ?? 0.0}',
                    ) ??
                    (aorder.price ?? 0.0)),
          'url': itemMap['url']?.toString() ?? aorder.url ?? '',
          'paymentMethod': pmForHistory,
          'orderCode': itemMap['orderCode']?.toString() ?? orderCode,
          'hasItBeenCanceledByUser': true,
          'copyShopEmail': copyShopEmail,
        };

        // --- PREPARAR updatedItems (eliminar la orden del mapa) ---
        final Map<String, dynamic> updatedItems = Map<String, dynamic>.from(
          itemsMap,
        );
        updatedItems.remove(orderCode);

        // --- WRITES (todas las escrituras hechas DESPUÉS de las lecturas) ---
        tx.update(adminAordersDocRef, {'items': updatedItems});

        if (hordersSnap.exists) {
          // si existe, usar arrayUnion para añadir el nuevo historial
          tx.update(hordersDocRef, {
            'items': FieldValue.arrayUnion([horderMap]),
          });
        } else {
          // si no existe, crear el doc con items: [horderMap]
          tx.set(hordersDocRef, {
            'items': [horderMap],
          }, SetOptions(merge: true));
        }
      });

      // si llegamos aquí la transacción fue exitosa
      return;
    } on FirebaseException catch (e) {
      return Future.error(
        'Error de Firebase archivando orden: ${e.message ?? e}',
      );
    } catch (e) {
      return Future.error('Error archivando orden: $e');
    }
  }

  @override
  Future<bool> verifyOrderByVerificationCode(
    String registration,
    String copyShopEmail,
    String verificationCode,
  ) async {
    try {
      final userAorderDocRef = _firestore
          .collection('users')
          .doc(registration)
          .collection('aorder')
          .doc('information');

      final adminAordersDocRef = _firestore
          .collection('copyshops')
          .doc(copyShopEmail)
          .collection('aorders')
          .doc('information');

      // Leer ambos documentos desde servidor para evitar caches inconsistentes
      final userSnap = await userAorderDocRef.get(
        const GetOptions(source: Source.server),
      );
      final adminSnap = await adminAordersDocRef.get(
        const GetOptions(source: Source.server),
      );

      if (!userSnap.exists) {
        return Future.error(
          'Documento usuario (aorder/information) no existe para $registration.',
        );
      }
      if (!adminSnap.exists) {
        return Future.error(
          'Documento admin (aorders/information) no existe para $copyShopEmail.',
        );
      }

      final userData = userSnap.data() ?? {};
      final adminData = adminSnap.data() ?? {};

      // Extraer verificationCode desde user.specifications
      final specsRaw = userData['specifications'];
      if (specsRaw is! Map) {
        return Future.error(
          'Estructura inválida: user.specifications no es un Map.',
        );
      }
      final dynamic userCodeRaw = specsRaw['verificationCode'];
      final String userCode = (userCodeRaw ?? '').toString();

      // Buscar verificationCode en items del admin
      final itemsRaw = adminData['items'];
      if (itemsRaw is! Map) {
        return Future.error('Estructura inválida: admin.items no es un Map.');
      }

      // Normalizar entrada
      final String target = verificationCode.trim();

      // Encontrar si existe algún item cuyo verificationCode coincida con target
      bool foundInAdmin = false;
      String foundInAdminOrderCode = '';
      Map<String, dynamic>? foundItem;
      (itemsRaw).forEach((key, value) {
        try {
          if (value is Map) {
            final String code = (value['verificationCode'] ?? '').toString();
            if (code.trim() == target) {
              foundInAdmin = true;
              foundInAdminOrderCode = key.toString();
              foundItem = Map<String, dynamic>.from(value);
            }
          }
        } catch (_) {}
      });

      // Casos:
      // - Si user no tiene code y admin no tiene code -> error (no hay nada)
      if (userCode.isEmpty && !foundInAdmin) {
        return Future.error(
          'No se encontró verificationCode ni en user ni en admin.',
        );
      }

      // - Si user tiene code pero difiere del target -> false
      if (userCode.isNotEmpty && userCode.trim() != target) {
        return false;
      }

      // - Si admin tiene code pero difiere del target -> false (pero ya comparamos exacto)
      // (ya buscámos por target, así que si foundInAdmin == true -> coincide)

      // Si llegamos aquí: userCode coincide (o está vacío pero admin coincide) y admin coincide:
      if (foundInAdmin) {
        // si userCode vacío pero admin tiene, devolvemos false? Según tu petición:
        // "si lo encuentra pero no es la misma entonces devuelve false, si si es la misma devuelve true"
        // Ya comprobamos que si userCode no vacío debe coincidir; si userCode vacío y admin encontrado,
        // interpretamos que no son la "misma" -> devolvemos false.
        if (userCode.isEmpty) {
          return false;
        } else {
          // ambos existen y coinciden
          return true;
        }
      } else {
        // admin no tiene target: si userCode == target ? No (ya chequeado)
        return false;
      }
    } catch (e) {
      return Future.error('Error verificando verificationCode: $e');
    }
  }

  @override
  Future<void> completeAndArchiveOrder(
    AorderEntity aorder,
    String userRegistration,
    String copyShopEmail, {
    bool deleteStorage = true,
  }) async {
    try {
      final String orderCode = aorder.orderCode;
      if (orderCode.isEmpty) {
        return Future.error('orderCode vacío en AorderEntity.');
      }

      final adminAordersDocRef = _firestore
          .collection('copyshops')
          .doc(copyShopEmail)
          .collection('aorders')
          .doc('information');

      final copyshopDocRef = _firestore
          .collection('copyshops')
          .doc(copyShopEmail);

      final userAorderDocRef = _firestore
          .collection('users')
          .doc(userRegistration)
          .collection('aorder')
          .doc('information');

      final userMainDocRef = _firestore
          .collection('users')
          .doc(userRegistration);

      final historyDocRef = _firestore
          .collection('copyshops')
          .doc(copyShopEmail)
          .collection('horders')
          .doc('information');

      final notificationsDocRef = _firestore
          .collection('users')
          .doc(userRegistration)
          .collection('notifications')
          .doc('information');

      // 1) Transacción: lecturas primero, luego writes
      final Map<String, dynamic> txResult = await _firestore.runTransaction((
        tx,
      ) async {
        // LECTURAS
        final adminSnap = await tx.get(adminAordersDocRef);
        final copyshopSnap = await tx.get(copyshopDocRef);
        final userAorderSnap = await tx.get(userAorderDocRef);
        final userMainSnap = await tx.get(userMainDocRef);
        final historySnap = await tx.get(historyDocRef);
        final notificationsSnap = await tx.get(notificationsDocRef);

        if (!adminSnap.exists) {
          throw Exception(
            'Documento admin (aorders/information) no existe para $copyShopEmail.',
          );
        }
        if (!userAorderSnap.exists) {
          throw Exception(
            'Documento usuario (aorder/information) no existe para $userRegistration.',
          );
        }
        if (!userMainSnap.exists) {
          throw Exception(
            'Documento principal del usuario no existe: $userRegistration',
          );
        }

        final adminData = adminSnap.data() ?? {};
        final userAorderData = userAorderSnap.data() ?? {};
        final userMainData = userMainSnap.data() ?? {};

        final dynamic itemsRaw = adminData['items'] ?? {};
        if (itemsRaw is! Map) {
          throw Exception('Estructura inválida: admin.items no es Map.');
        }
        final Map<String, dynamic> itemsMap = Map<String, dynamic>.from(
          itemsRaw,
        );

        if (!itemsMap.containsKey(orderCode)) {
          throw Exception('orderCode "$orderCode" no existe en admin.items.');
        }

        // BACKUPS (para rollback posible después)
        final Map<String, dynamic> originalItems = Map<String, dynamic>.from(
          itemsMap,
        );
        final Map<String, dynamic> originalUserSpecs =
            (userAorderData['specifications'] is Map)
            ? Map<String, dynamic>.from(userAorderData['specifications'] as Map)
            : <String, dynamic>{};
        final List<dynamic> originalHistoryList =
            (historySnap.exists && historySnap.data()?['items'] is List)
            ? List<dynamic>.from(historySnap.data()!['items'] as List<dynamic>)
            : <dynamic>[];
        final List<dynamic> originalNotificationsList =
            (notificationsSnap.exists &&
                notificationsSnap.data()?['items'] is List)
            ? List<dynamic>.from(
                notificationsSnap.data()!['items'] as List<dynamic>,
              )
            : <dynamic>[];
        final int originalQueue =
            (copyshopSnap.exists && (copyshopSnap.data()?['queue'] is num))
            ? (copyshopSnap.data()!['queue'] as num).toInt()
            : 0;

        // Construir paymentMethod para el historial:
        Object? paymentMethodObject;
        final dynamic pmRaw = aorder.paymentMethod;
        if (pmRaw == null) {
          paymentMethodObject = null;
        } else {
          final String pmString = pmRaw.toString();
          if (pmString.toLowerCase() == 'cash') {
            paymentMethodObject = 'cash';
          } else {
            final dynamic cardMethodsRaw = userMainData['cardPaymentMethods'];
            if (cardMethodsRaw is Map && cardMethodsRaw.containsKey(pmString)) {
              final found = cardMethodsRaw[pmString];
              if (found is Map) {
                paymentMethodObject = Map<String, dynamic>.from(found);
              } else {
                paymentMethodObject = pmString;
              }
            } else {
              paymentMethodObject = pmString;
            }
          }
        }

        // Construir Horder map (sin duplicar keys)
        Map<String, dynamic> horderMap = {
          'copyShopName': aorder.copyShopName,
          'userRegistration': aorder.userRegistration,
          'userName': aorder.userName,
          'finalDate': aorder.estimatedDeliveryTime == null
              ? null
              : Timestamp.fromDate(aorder.estimatedDeliveryTime!),
          'format': aorder.format,
          'initDate': aorder.initDate == null
              ? FieldValue.serverTimestamp()
              : Timestamp.fromDate(aorder.initDate),
          'isColor': aorder.isColor,
          'pages': aorder.pages,
          'pdfName': aorder.pdfName,
          'place': '${aorder.placeLat},${aorder.placeLong}',
          'price': aorder.price,
          'url': aorder.url,
          'paymentMethod': paymentMethodObject,
          'orderCode': aorder.orderCode,
          'hasItBeenCanceledByUser': (aorder.hasItBeenCanceledByUser ?? false),
          'copyShopEmail': aorder.copyShopEmail,
        };

        // PREPARAR WRITES EN MEMORIA
        // 1) eliminar item del admin.items
        final Map<String, dynamic> updatedItems = Map<String, dynamic>.from(
          itemsMap,
        );
        updatedItems.remove(orderCode);

        // 2) añadir al history (lista)
        final List<dynamic> updatedHistory = List<dynamic>.from(
          originalHistoryList,
        );
        updatedHistory.add(horderMap);

        // 3) calcular nueva queue: contar items con hasItBeenAccepted == true && hasItBeenCanceledByUser != true
        int acceptedCount = 0;
        updatedItems.forEach((k, v) {
          try {
            if (v is Map) {
              final dynamic acceptedRaw = v['hasItBeenAccepted'];
              final dynamic canceledRaw = v['hasItBeenCanceledByUser'];
              final bool accepted =
                  (acceptedRaw == true) ||
                  (acceptedRaw is String &&
                      acceptedRaw.toString().toLowerCase() == 'true') ||
                  (acceptedRaw is num && acceptedRaw != 0);
              final bool canceled =
                  (canceledRaw == true) ||
                  (canceledRaw is String &&
                      canceledRaw.toString().toLowerCase() == 'true') ||
                  (canceledRaw is num && canceledRaw != 0);
              if (accepted && !canceled) acceptedCount++;
            }
          } catch (_) {}
        });

        final int newQueueValue = (acceptedCount - 1) >= 0
            ? (acceptedCount - 1)
            : 0;

        // 4) user specs: marcar hasItBeenCompleted = true (sin borrar otras fields)
        final Map<String, dynamic> updatedUserSpecs = Map<String, dynamic>.from(
          originalUserSpecs,
        );
        updatedUserSpecs['hasItBeenCompleted'] = true;

        // 5) push notificación al usuario (seen = false)
        final Map<String, dynamic> newNotification = {
          'dateTime': Timestamp.now(),
          'message': 'Gracias por preferirnos',
          'seen': false,
          'subject': 'Orden completada',
        };
        final List<dynamic> updatedNotifications = List<dynamic>.from(
          originalNotificationsList,
        );
        updatedNotifications.add(newNotification);

        // ESCRITURAS DENTRO DE LA TRANSACCIÓN (después de todas las lecturas)
        tx.update(adminAordersDocRef, {'items': updatedItems});

        if (historySnap.exists) {
          tx.update(historyDocRef, {'items': updatedHistory});
        } else {
          tx.set(historyDocRef, {
            'items': updatedHistory,
          }, SetOptions(merge: true));
        }

        if (copyshopSnap.exists) {
          tx.update(copyshopDocRef, {'queue': newQueueValue});
        } else {
          tx.set(copyshopDocRef, {
            'queue': newQueueValue,
          }, SetOptions(merge: true));
        }

        tx.update(userAorderDocRef, {'specifications': updatedUserSpecs});

        if (notificationsSnap.exists) {
          tx.update(notificationsDocRef, {'items': updatedNotifications});
        } else {
          tx.set(notificationsDocRef, {
            'items': updatedNotifications,
          }, SetOptions(merge: true));
        }

        // devolver backups para rollback si Storage falla después
        return {
          'originalItems': originalItems,
          'originalUserSpecs': originalUserSpecs,
          'originalHistory': originalHistoryList,
          'originalNotifications': originalNotificationsList,
          'originalQueue': originalQueue,
        };
      });

      // Transacción aplicada correctamente. txResult tiene los backups.
      // Ahora borramos Storage si el flag lo indica.
      final String fileUrl = (aorder.url ?? '').trim();
      if (deleteStorage && fileUrl.isNotEmpty) {
        String storagePath = fileUrl;
        if (fileUrl.startsWith('gs://')) {
          final withoutScheme = fileUrl.substring(5);
          final firstSlash = withoutScheme.indexOf('/');
          storagePath = firstSlash >= 0
              ? withoutScheme.substring(firstSlash + 1)
              : withoutScheme;
        }

        try {
          await storageRepository.deleteFileByPath(storagePath);
          return; // todo OK
        } on FirebaseException catch (e) {
          final code = (e.code ?? '').toLowerCase();
          if (code.contains('object-not-found') || code.contains('not-found')) {
            return; // ya no existe, consideramos OK
          }

          // fallo borrando storage -> intentar rollback con la info de txResult
          try {
            final Map<String, dynamic> bItems = Map<String, dynamic>.from(
              txResult['originalItems'] as Map<String, dynamic>,
            );
            final Map<String, dynamic> bSpecs = Map<String, dynamic>.from(
              txResult['originalUserSpecs'] as Map<String, dynamic>,
            );
            final List<dynamic> bHistory = List<dynamic>.from(
              txResult['originalHistory'] as List<dynamic>,
            );
            final List<dynamic> bNotifications = List<dynamic>.from(
              txResult['originalNotifications'] as List<dynamic>,
            );
            final int origQueue = txResult['originalQueue'] as int;

            await _firestore.runTransaction((tx) async {
              final adminSnapCheck = await tx.get(adminAordersDocRef);
              final userAorderSnapCheck = await tx.get(userAorderDocRef);
              final historySnapCheck = await tx.get(historyDocRef);
              final notificationsSnapCheck = await tx.get(notificationsDocRef);
              final copyshopSnapCheck = await tx.get(copyshopDocRef);

              if (!adminSnapCheck.exists || !userAorderSnapCheck.exists) {
                throw Exception(
                  'Rollback fallido: documentos no existen al intentar revertir.',
                );
              }

              tx.update(adminAordersDocRef, {'items': bItems});
              tx.update(userAorderDocRef, {'specifications': bSpecs});

              if (historySnapCheck.exists) {
                tx.update(historyDocRef, {'items': bHistory});
              } else {
                tx.set(historyDocRef, {
                  'items': bHistory,
                }, SetOptions(merge: true));
              }

              if (notificationsSnapCheck.exists) {
                tx.update(notificationsDocRef, {'items': bNotifications});
              } else {
                tx.set(notificationsDocRef, {
                  'items': bNotifications,
                }, SetOptions(merge: true));
              }

              if (copyshopSnapCheck.exists) {
                tx.update(copyshopDocRef, {'queue': origQueue});
              } else {
                tx.set(copyshopDocRef, {
                  'queue': origQueue,
                }, SetOptions(merge: true));
              }
            });

            return Future.error(
              'Error borrando archivo en Storage: ${e.message ?? e}. Se revirtió la operación en Firestore.',
            );
          } catch (rollbackError) {
            return Future.error(
              'Error borrando archivo en Storage: ${e.message ?? e}. Intento de rollback falló: $rollbackError.',
            );
          }
        } catch (e) {
          // rollback fallback
          try {
            final Map<String, dynamic> bItems = Map<String, dynamic>.from(
              txResult['originalItems'] as Map<String, dynamic>,
            );
            final Map<String, dynamic> bSpecs = Map<String, dynamic>.from(
              txResult['originalUserSpecs'] as Map<String, dynamic>,
            );
            final List<dynamic> bHistory = List<dynamic>.from(
              txResult['originalHistory'] as List<dynamic>,
            );
            final List<dynamic> bNotifications = List<dynamic>.from(
              txResult['originalNotifications'] as List<dynamic>,
            );
            final int origQueue = txResult['originalQueue'] as int;

            await _firestore.runTransaction((tx) async {
              tx.update(adminAordersDocRef, {'items': bItems});
              tx.update(userAorderDocRef, {'specifications': bSpecs});
              final historySnapCheck = await tx.get(historyDocRef);
              if (historySnapCheck.exists) {
                tx.update(historyDocRef, {'items': bHistory});
              } else {
                tx.set(historyDocRef, {
                  'items': bHistory,
                }, SetOptions(merge: true));
              }
              final notificationsSnapCheck = await tx.get(notificationsDocRef);
              if (notificationsSnapCheck.exists) {
                tx.update(notificationsDocRef, {'items': bNotifications});
              } else {
                tx.set(notificationsDocRef, {
                  'items': bNotifications,
                }, SetOptions(merge: true));
              }
              tx.update(copyshopDocRef, {'queue': origQueue});
            });

            return Future.error(
              'Error borrando archivo en Storage: $e. Se revirtió la operación en Firestore.',
            );
          } catch (rollbackError) {
            return Future.error(
              'Error borrando archivo en Storage: $e. Intento de rollback falló: $rollbackError.',
            );
          }
        }
      } else {
        // no hay archivo que borrar o deleteStorage == false
        return;
      }
    } on FirebaseException catch (e) {
      return Future.error(
        'Error de Firebase completando/archivando orden: ${e.message ?? e}',
      );
    } catch (e) {
      return Future.error('Error completando/archivando orden: $e');
    }
  }
}
