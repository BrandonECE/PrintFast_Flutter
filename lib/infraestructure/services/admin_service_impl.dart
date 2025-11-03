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

    final copyshopDocRef = _firestore.collection('copyshops').doc(copyShopEmail);

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

      if (!adminSnap.exists) throw Exception('Documento admin (aorders/information) no existe.');
      if (!userAorderSnap.exists) throw Exception('Documento usuario (aorder/information) no existe.');

      final adminData = adminSnap.data() ?? {};
      final userAorderData = userAorderSnap.data() ?? {};

      final itemsRaw = adminData['items'];
      final specsRaw = userAorderData['specifications'];

      if (itemsRaw is! Map) throw Exception('Estructura inválida: "items" no es un Map en admin doc.');
      if (specsRaw is! Map) throw Exception('Estructura inválida: "specifications" no es un Map en user doc.');

      // ---------- WORK IN MEMORY ----------
      final Map<String, dynamic> items = Map<String, dynamic>.from(itemsRaw);
      if (!items.containsKey(orderCode)) throw Exception('El orderCode "$orderCode" no existe en items (admin).');

      final itemRaw = items[orderCode];
      if (itemRaw is! Map) throw Exception('El item para "$orderCode" no tiene la estructura esperada (admin).');

      final Map<String, dynamic> updatedItem = Map<String, dynamic>.from(itemRaw);
      updatedItem['hasItBeenAccepted'] = true;
      // ✅ CAMBIO: Usar DateTime normal en lugar de FieldValue.serverTimestamp()
      updatedItem['initDate'] = timestamp;
      items[orderCode] = updatedItem;

      final Map<String, dynamic> updatedSpecs = Map<String, dynamic>.from(specsRaw);
      updatedSpecs['hasItBeenAccepted'] = true;
      // ✅ CAMBIO: Usar DateTime normal
      updatedSpecs['initDate'] = timestamp;

      // calcular queue
      int acceptedCount = 0;
      items.forEach((key, value) {
        try {
          if (value is Map) {
            final h = value['hasItBeenAccepted'];
            if (h == true || (h is String && h.toLowerCase() == 'true') || (h is num && h != 0)) {
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
        tx.set(copyshopDocRef, {'queue': newQueueValue}, SetOptions(merge: true));
      }

      // Notificaciones
      if (userNotifSnap.exists) {
        tx.update(userNotificationsRef, {
          'items': FieldValue.arrayUnion([newNotif])
        });
      } else {
        tx.set(userNotificationsRef, {'items': [newNotif]});
      }
    });

    return;
  } on FirebaseException catch (e) {
    print('acceptPendingOrder - FirebaseException: ${e.code} ${e.message}');
    return Future.error('Error de Firebase aceptando orden: ${e.message ?? e}');
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
    final Map<String, dynamic> txResult = await _firestore.runTransaction((tx) async {
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
      final Map<String, dynamic> originalItems = Map<String, dynamic>.from(itemsRaw);

      // Verificamos que el item tenga la estructura esperada
      final itemRaw = itemsRaw[orderCode];
      if (itemRaw is! Map<String, dynamic>) {
        throw Exception(
          'El item para "$orderCode" no tiene la estructura esperada (admin).',
        );
      }

      // Construimos items actualizado sin la key orderCode (eliminamos)
      final Map<String, dynamic> updatedItems = Map<String, dynamic>.from(itemsRaw);
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
      final Map<String, dynamic> originalSpecs = Map<String, dynamic>.from(specsRaw);

      // Actualizamos specifications: solo setear hasItBeenAccepted = false
      final Map<String, dynamic> updatedSpecs = Map<String, dynamic>.from(specsRaw);
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
          'items': FieldValue.arrayUnion([notifMap])
        });
      } else {
        tx.set(userNotificationsRef, {'items': [notifMap]});
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

      await _firestore.runTransaction((tx) async {
        // --- Leer admin doc ---
        final adminSnap = await tx.get(adminDocRef);
        if (!adminSnap.exists) {
          throw Exception(
            'Documento admin (aorders/information) no existe para $copyShopEmail.',
          );
        }
        final adminData = adminSnap.data();
        if (adminData == null) {
          throw Exception('Documento admin sin datos para $copyShopEmail.');
        }

        final dynamic itemsRaw = adminData['items'];
        if (itemsRaw is! Map) {
          throw Exception(
            'Estructura inválida: "items" no es un Map en admin doc.',
          );
        }

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

        // --- Actualizar item en memoria (admin) ---
        final Map<String, dynamic> updatedItem = Map<String, dynamic>.from(
          itemRaw,
        );
        // usamos server timestamp para ambos campos dentro de la transacción
        updatedItem['printDate'] = FieldValue.serverTimestamp();
        items[orderCode] = updatedItem;

        // --- Leer user doc ---
        final userSnap = await tx.get(userDocRef);
        if (!userSnap.exists) {
          throw Exception(
            'Documento usuario (aorder/information) no existe para $userRegistration.',
          );
        }
        final userData = userSnap.data();
        if (userData == null) {
          throw Exception(
            'Documento usuario sin datos para $userRegistration.',
          );
        }

        final dynamic specsRaw = userData['specifications'];
        if (specsRaw is! Map) {
          throw Exception(
            'Estructura inválida: "specifications" no es un Map en user doc.',
          );
        }

        final Map<String, dynamic> specs = Map<String, dynamic>.from(specsRaw);

        // --- Actualizar specifications (usuario) ---
        specs['printDate'] = FieldValue.serverTimestamp();

        // --- Aplicar cambios en la transacción ---
        tx.update(adminDocRef, {'items': items});
        tx.update(userDocRef, {'specifications': specs});
      });

      // si llegamos aquí, transacción exitosa
      return;
    } on FirebaseException catch (e) {
      return Future.error(
        'Error de Firebase marcando printDate: ${e.message ?? e}',
      );
    } catch (e) {
      return Future.error('Error marcando printDate: $e');
    }
  }
}
