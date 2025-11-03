import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
// import 'package:flutter/material.dart';
import 'package:printfast_rebuild/domain/entities/entities.dart';
import 'package:printfast_rebuild/domain/repositories/auth_repository.dart';
import 'package:printfast_rebuild/domain/repositories/admin_repository.dart';
// import 'package:toastification/toastification.dart';

part 'admin_home_event.dart';
part 'admin_home_state.dart';

class AdminHomeBloc extends Bloc<AdminHomeEvent, AdminHomeState> {
  final AuthRepository authRepository;
  final AdminRepository adminRepository;

  StreamSubscription<List<AorderEntity>>? _aordersSubscription;
  Timer? _aordersReconnectTimer;
  int _aordersReconnectAttempt = 0;
  final int _maxReconnectDelaySeconds = 30;

  // Notificaciones
  StreamSubscription<int>? _unseenNotifSubscription;
  Timer? _notifReconnectTimer;
  int _notifReconnectAttempt = 0;

  // Reception Availability
  StreamSubscription<bool>? _receptionSubscription;
  Timer? _receptionReconnectTimer;
  int _receptionReconnectAttempt = 0;

  AdminHomeBloc({required this.authRepository, required this.adminRepository})
    : super(AdminHomeInitial()) {
    on<AdminHomeChangeIndexBottomNavigationBarEvent>((event, emit) {
      emit(state.copyWith(currentIndex: event.currentIndex));
    });

    on<AdminHomeUpdateUserEntityEvent>((event, emit) {
      emit(state.copyWith(userEntity: event.userEntity));
      // Iniciar ambos listeners cuando se actualiza el usuario
      add(
        AdminHomeStartAordersListenerEvent(
          copyShopEmail: event.userEntity.adminLocationByEmail,
        ),
      );
      add(
        AdminHomeStartNotificationsListenerEvent(
          copyShopEmail: event.userEntity.adminLocationByEmail,
        ),
      );
    });

    on<AdminHomeUpdateCopyShopEntityEvent>((event, emit) {
      emit(state.copyWith(copyShopEntity: event.copyShopEntity));
      // Iniciar listener cuando se actualiza la recepción de la copyShop
      add(
        AdminHomeStartReceptionListenerEvent(
          copyShopEmail: event.copyShopEntity.copyShopEmail,
        ),
      );
    });

    on<AdminHomeUpdateSelectedOrderEvent>((event, emit) {
      emit(state.copyWith(selectedOrder: event.selectedOrder));
    });

    on<AdminHomeUpdateHomeLogOutStatusEvent>((event, emit) {
      emit(state.copyWith(adminHomeLogOutStatus: event.adminHomeLogOutStatus));
    });

    // --- Eventos para aorders ---
    on<AdminHomeStartAordersListenerEvent>((event, emit) async {
      final copyShopEmail = event.copyShopEmail ?? "";
      if (copyShopEmail.isNotEmpty) {
        emit(state.copyWith(adminAordersStatus: AdminAordersStatus.loading));
        await Future.delayed(const Duration(milliseconds: 1250));
        _startAordersListener(copyShopEmail);
      }
    });

    on<AdminHomeStopAordersListenerEvent>((event, emit) async {
      await _stopAordersListener();
      emit(
        state.copyWith(
          adminAordersStatus: AdminAordersStatus.initial,
          acceptedOrders: [],
          pendingOrders: [],
        ),
      );
    });

    on<AdminHomeUpdateAordersEvent>((event, emit) {
      // Separar órdenes en aceptadas y pendientes
      final acceptedOrders = <AorderEntity>[];
      final pendingOrders = <AorderEntity>[];

      for (final order in event.aorders) {
        if (order.hasItBeenAccepted == true) {
          acceptedOrders.add(order);
        } else if (order.hasItBeenAccepted == null) {
          pendingOrders.add(order);
        }
      }

      // Ordenar de más reciente a más antigua (por initDate)
      if (acceptedOrders.isNotEmpty) {
        acceptedOrders.sort((a, b) => b.initDate.compareTo(a.initDate));
      }
      if (pendingOrders.isNotEmpty) {
        pendingOrders.sort((a, b) => b.initDate.compareTo(a.initDate));
      }

      // Reset reconnect attempts on success
      _aordersReconnectAttempt = 0;

      emit(
        state.copyWith(
          adminAordersStatus: AdminAordersStatus.success,
          acceptedOrders: acceptedOrders,
          pendingOrders: pendingOrders,
          messageError: null,
        ),
      );
    });

    on<AdminHomeAordersErrorEvent>((event, emit) async {
      // Si es el primer error, mostrar loading brevemente
      if (_aordersReconnectAttempt == 0) {
        emit(state.copyWith(adminAordersStatus: AdminAordersStatus.loading));
        await Future.delayed(const Duration(milliseconds: 600));
      }

      emit(
        state.copyWith(
          adminAordersStatus: AdminAordersStatus.failure,
          messageError: event.message,
        ),
      );

      _scheduleAordersReconnect();
    });

    // --- Eventos para notificaciones ---
    on<AdminHomeStartNotificationsListenerEvent>((event, emit) {
      final copyShopEmail =
          event.copyShopEmail ?? state.userEntity.adminLocationByEmail;
      if (copyShopEmail.isNotEmpty) {
        emit(
          state.copyWith(
            notificationsStatus: AdminCountNotificationsStatus.loading,
          ),
        );
        _startNotificationsListener(copyShopEmail);
      }
    });

    on<AdminHomeStopNotificationsListenerEvent>((event, emit) async {
      await _stopNotificationsListener();
      emit(
        state.copyWith(
          unseenNotificationsCount: 0,
          notificationsStatus: AdminCountNotificationsStatus.idle,
          notificationsErrorMessage: null,
        ),
      );
    });

    on<AdminHomeUpdateUnseenNotificationsCountEvent>((event, emit) {
      emit(
        state.copyWith(
          unseenNotificationsCount: event.count,
          notificationsStatus: AdminCountNotificationsStatus.success,
          notificationsErrorMessage: null,
        ),
      );
      _notifReconnectAttempt = 0;
    });

    on<AdminHomeNotificationsErrorEvent>((event, emit) async {
      if (_notifReconnectAttempt == 0) {
        emit(
          state.copyWith(
            notificationsStatus: AdminCountNotificationsStatus.loading,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 400));
      }

      emit(
        state.copyWith(
          unseenNotificationsCount: 0,
          notificationsStatus: AdminCountNotificationsStatus.failure,
          notificationsErrorMessage: event.message,
        ),
      );

      _scheduleNotificationsReconnect();
    });

    on<AdminHomeMarkAllNotificationsAsSeenEvent>(_markAllAsSeen);

    // --- Eventos para reception availability ---
    on<AdminHomeStartReceptionListenerEvent>((event, emit) async {
      await Future.delayed(const Duration(milliseconds: 1250));
      final copyShopEmail =
          event.copyShopEmail ?? state.copyShopEntity.copyShopEmail;
      if (copyShopEmail.isNotEmpty) {
        emit(state.copyWith(receptionStatus: AdminReceptionStatus.loading));
        _startReceptionListener(copyShopEmail);
      }
    });

    on<AdminHomeStopReceptionListenerEvent>((event, emit) async {
      await _stopReceptionListener();
      emit(
        state.copyWith(
          receptionStatus: AdminReceptionStatus.initial,
          receptionErrorMessage: null,
        ),
      );
    });

    on<AdminHomeUpdateReceptionValueEvent>((event, emit) {
      emit(
        state.copyWith(
          receptionStatus: AdminReceptionStatus.success,
          copyShopEntity: state.copyShopEntity.copyWith(
            pauseReception: event.pauseReception,
          ),
          receptionErrorMessage: null,
        ),
      );
      _receptionReconnectAttempt = 0;
    });

    on<AdminHomeUpdateDataBaseReceptionValueEvent>(
      _updateDataBaseReceptionValue,
    );

    on<AdminHomeReceptionErrorEvent>((event, emit) async {
      if (_receptionReconnectAttempt == 0) {
        emit(state.copyWith(receptionStatus: AdminReceptionStatus.loading));
        await Future.delayed(const Duration(milliseconds: 400));
      }

      emit(
        state.copyWith(
          receptionStatus: AdminReceptionStatus.connectionFailure,
          receptionErrorMessage: event.message,
        ),
      );

      _scheduleReceptionReconnect();
    });

    on<AdminHomeUpdatePendingOrderDecisionEvent>((event, emit) {
      emit(state.copyWith(pendingOrderDecision: event.pendingOrderDecision));
    });

    on<AdminHomeMakePendingOrderDecisionEvent>(
      _adminHomeMakePendingOrderDecisionEvent,
    );

    on<AdminHomeUpdatePendingOrderStatusEvent>((event, emit) {
      emit(state.copyWith(pendingOrderStatus: event.pendingOrderStatus));
    });

    on<AdminHomeUpdateSelectedPendingOrderCodeValueEvent>((event, emit) {
      emit(
        state.copyWith(
          selectedPendingOrderCode: event.selectedPendingOrderCode,
        ),
      );
    });

    on<AdminHomeUpdateAdminHomeActionsEvent>((event, emit) {
      emit(state.copyWith(adminHomeActions: event.adminHomeActions));
    });

    on<AdminHomeUpdateReceptionStatusEvent>((event, emit) {
      emit(state.copyWith(receptionStatus: event.adminReceptionStatus));
    });
  }

  Future<void> _adminHomeMakePendingOrderDecisionEvent(
    AdminHomeMakePendingOrderDecisionEvent event,
    Emitter<AdminHomeState> emit,
  ) async {
    final userRegistration = state.userEntity.registration;
    final copyShopEmail = state.copyShopEntity.copyShopEmail;
    final orderCode = state.selectedOrder.orderCode;
    final fileUrl = state.selectedOrder.url;
    try {
      emit(state.copyWith(pendingOrderStatus: PendingOrderStatus.loading));
      await Future.delayed(const Duration(milliseconds: 600));
      // await Future.delayed(const Duration(milliseconds: 5000));
      // throw Exception("PRUEBADECISION");
      if (state.pendingOrderDecision == PendingOrderDecision.accept) {
        await adminRepository.acceptPendingOrder(
          userRegistration,
          copyShopEmail,
          orderCode,
        );
      } else if (state.pendingOrderDecision == PendingOrderDecision.reject) {
        await adminRepository.rejectPendingOrder(
          userRegistration,
          copyShopEmail,
          orderCode,
          fileUrl,
        );
      } //Pending
      emit(state.copyWith(pendingOrderStatus: PendingOrderStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          adminHomeActions: AdminHomeActions.makePendingOrderDecision,
          pendingOrderStatus: PendingOrderStatus.failure,
          pendingOrderErrorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _updateDataBaseReceptionValue(
    AdminHomeUpdateDataBaseReceptionValueEvent event,
    Emitter<AdminHomeState> emit,
  ) async {
    final copyShopEmail = state.userEntity.adminLocationByEmail;
    emit(state.copyWith(receptionStatus: AdminReceptionStatus.loading));
    await Future.delayed(Duration(milliseconds: 800));

    try {
      await adminRepository.updateCopyShopReceptionAvailabilityValue(
        copyShopEmail,
        event.copyShopReceptionAvailabilityValue,
      );
    } catch (e) {
      emit(
        state.copyWith(
          adminHomeActions: AdminHomeActions.togglePauseReception,
          receptionStatus: AdminReceptionStatus.requestFailure,
          receptionErrorMessage: e.toString(),
        ),
      );
    }
    _startReceptionListener(copyShopEmail);
  }

  Future<void> _markAllAsSeen(
    AdminHomeMarkAllNotificationsAsSeenEvent event,
    Emitter<AdminHomeState> emit,
  ) async {
    try {
      await adminRepository.markAllCopyShopNotificationsAsSeen(
        state.userEntity.adminLocationByEmail,
      );
    } catch (e) {
      print(e);
    }
  }

  // ------------------ AORDERS STREAM ------------------
  void _startAordersListener(String copyShopEmail) {
    _aordersSubscription?.cancel();
    _aordersSubscription = null;

    try {
      final Stream<List<AorderEntity>> stream = adminRepository
          .getAordersStream(copyShopEmail);

      _aordersSubscription = stream.listen(
        (aorders) {
          final doesTheSelectedOrderExist = aorders.any(
            (aorder) => aorder.orderCode == state.selectedOrder.orderCode,
          );
          if (doesTheSelectedOrderExist) {
            final updatedSelectedOrder = aorders.firstWhere(
              (aorder) => aorder.orderCode == state.selectedOrder.orderCode,
            );
            add(
              AdminHomeUpdateSelectedOrderEvent(
                selectedOrder: updatedSelectedOrder,
              ),
            );
          }
          add(AdminHomeUpdateAordersEvent(aorders: aorders));
        },
        onError: (error, stack) {
          final msg =
              error?.toString() ?? 'Error desconocido en aorders stream';
          print('AdminHomeBloc - error en aorders stream: $msg');
          add(AdminHomeAordersErrorEvent(message: msg));
        },
        onDone: () {
          print('AdminHomeBloc - aorders stream done (onDone) — reconectando');
          add(const AdminHomeAordersErrorEvent(message: 'Stream finalizó'));
        },
        cancelOnError: false,
      );
    } catch (e) {
      final msg = 'AdminHomeBloc - excepción iniciando aorders stream: $e';
      print(msg);
      add(AdminHomeAordersErrorEvent(message: msg));
    }
  }

  void _scheduleAordersReconnect() {
    if (_aordersReconnectTimer != null && _aordersReconnectTimer!.isActive)
      return;

    _aordersReconnectAttempt++;
    final seconds = (_aordersReconnectAttempt > 6)
        ? _maxReconnectDelaySeconds
        : (1 << (_aordersReconnectAttempt - 1));
    final backoff = Duration(
      seconds: seconds.clamp(1, _maxReconnectDelaySeconds),
    );

    print(
      'AdminHomeBloc - reconectando aorders en ${backoff.inSeconds}s (intento #$_aordersReconnectAttempt)',
    );

    _aordersReconnectTimer = Timer(backoff, () {
      _aordersSubscription?.cancel();
      _aordersSubscription = null;
      final email = state.userEntity.adminLocationByEmail;
      if (email.isNotEmpty) {
        _startAordersListener(email);
      }
    });
  }

  Future<void> _stopAordersListener() async {
    try {
      await _aordersSubscription?.cancel();
    } catch (e) {
      print('Error cancelando aordersSubscription: $e');
    } finally {
      _aordersSubscription = null;
    }
  }

  // ------------------ NOTIFICATIONS STREAM ------------------
  void _startNotificationsListener(String copyShopEmail) {
    _unseenNotifSubscription?.cancel();
    _unseenNotifSubscription = null;

    try {
      final Stream<int> stream = adminRepository
          .unseenCopyShopNotificationsCount(copyShopEmail);

      _unseenNotifSubscription = stream.listen(
        (count) {
          print('AdminHomeBloc - notificaciones no vistas: $count');
          add(AdminHomeUpdateUnseenNotificationsCountEvent(count: count));
        },
        onError: (error, stack) {
          final msg =
              error?.toString() ?? 'Error desconocido en notifications stream';
          print('AdminHomeBloc - error en notifications stream: $msg');
          add(AdminHomeNotificationsErrorEvent(message: msg));
        },
        onDone: () {
          print(
            'AdminHomeBloc - notifications stream done (onDone) — reconectando',
          );
          add(
            const AdminHomeNotificationsErrorEvent(message: 'Stream finalizó'),
          );
        },
        cancelOnError: false,
      );
    } catch (e) {
      final msg =
          'AdminHomeBloc - excepción iniciando notifications stream: $e';
      print(msg);
      add(AdminHomeNotificationsErrorEvent(message: msg));
    }
  }

  void _scheduleNotificationsReconnect() {
    if (_notifReconnectTimer != null && _notifReconnectTimer!.isActive) return;

    _notifReconnectAttempt++;
    final seconds = (_notifReconnectAttempt > 6)
        ? _maxReconnectDelaySeconds
        : (1 << (_notifReconnectAttempt - 1));
    final backoff = Duration(
      seconds: seconds.clamp(1, _maxReconnectDelaySeconds),
    );

    print(
      'AdminHomeBloc - reconectando notifications en ${backoff.inSeconds}s (intento #$_notifReconnectAttempt)',
    );

    _notifReconnectTimer = Timer(backoff, () {
      _unseenNotifSubscription?.cancel();
      _unseenNotifSubscription = null;
      final email = state.userEntity.adminLocationByEmail;
      if (email.isNotEmpty) {
        _startNotificationsListener(email);
      }
    });
  }

  Future<void> _stopNotificationsListener() async {
    try {
      await _unseenNotifSubscription?.cancel();
    } catch (e) {
      print('Error cancelando unseenNotifSubscription: $e');
    } finally {
      _unseenNotifSubscription = null;
      add(const AdminHomeUpdateUnseenNotificationsCountEvent(count: 0));
    }
  }

  // ------------------ RECEPTION AVAILABILITY STREAM ------------------
  void _startReceptionListener(String copyShopEmail) {
    _receptionSubscription?.cancel();
    _receptionSubscription = null;

    try {
      final Stream<bool> stream = adminRepository
          .getCopyShopReceptionAvailabilityValue(copyShopEmail);

      _receptionSubscription = stream.listen(
        (pauseReception) {
          print('AdminHomeBloc - pauseReception actualizado: $pauseReception');
          add(
            AdminHomeUpdateReceptionValueEvent(pauseReception: pauseReception),
          );
        },
        onError: (error, stack) {
          final msg =
              error?.toString() ?? 'Error desconocido en reception stream';
          print('AdminHomeBloc - error en reception stream: $msg');
          add(AdminHomeReceptionErrorEvent(message: msg));
        },
        onDone: () {
          print(
            'AdminHomeBloc - reception stream done (onDone) — reconectando',
          );
          add(const AdminHomeReceptionErrorEvent(message: 'Stream finalizó'));
        },
        cancelOnError: false,
      );
    } catch (e) {
      final msg = 'AdminHomeBloc - excepción iniciando reception stream: $e';
      print(msg);
      add(AdminHomeReceptionErrorEvent(message: msg));
    }
  }

  void _scheduleReceptionReconnect() {
    if (_receptionReconnectTimer != null &&
        _receptionReconnectTimer!.isActive) {
      return;
    }

    _receptionReconnectAttempt++;
    final seconds = (_receptionReconnectAttempt > 6)
        ? _maxReconnectDelaySeconds
        : (1 << (_receptionReconnectAttempt - 1));
    final backoff = Duration(
      seconds: seconds.clamp(1, _maxReconnectDelaySeconds),
    );

    print(
      'AdminHomeBloc - reconectando reception en ${backoff.inSeconds}s (intento #$_receptionReconnectAttempt)',
    );

    _receptionReconnectTimer = Timer(backoff, () {
      _receptionSubscription?.cancel();
      _receptionSubscription = null;
      final email = state.copyShopEntity.copyShopEmail;
      if (email.isNotEmpty) {
        _startReceptionListener(email);
      }
    });
  }

  Future<void> _stopReceptionListener() async {
    try {
      await _receptionSubscription?.cancel();
    } catch (e) {
      print('Error cancelando receptionSubscription: $e');
    } finally {
      _receptionSubscription = null;
    }
  }

  Future<void> signOut() async {
    add(
      AdminHomeUpdateHomeLogOutStatusEvent(
        adminHomeLogOutStatus: AdminHomeLogOutStatus.loading,
        messageError: null,
      ),
    );
    await Future.delayed(const Duration(milliseconds: 1000));
    try {
      await authRepository.signOut();
      add(
        AdminHomeUpdateHomeLogOutStatusEvent(
          adminHomeLogOutStatus: AdminHomeLogOutStatus.success,
          messageError: null,
        ),
      );

      // Detener todo
      await _stopAordersListener();
      _aordersReconnectTimer?.cancel();
      await _stopNotificationsListener();
      _notifReconnectTimer?.cancel();
      await _stopReceptionListener();
      _receptionReconnectTimer?.cancel();
      add(
        AdminHomeUpdateReceptionStatusEvent(
          adminReceptionStatus: AdminReceptionStatus.loading,
        ),
      );
      add(AdminHomeChangeIndexBottomNavigationBarEvent(currentIndex: 0));
    } catch (e) {
      add(
        AdminHomeUpdateHomeLogOutStatusEvent(
          adminHomeLogOutStatus: AdminHomeLogOutStatus.failure,
          messageError: e.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    _aordersReconnectTimer?.cancel();
    _notifReconnectTimer?.cancel();
    _receptionReconnectTimer?.cancel();
    await _stopAordersListener();
    await _stopNotificationsListener();
    await _stopReceptionListener();
    return super.close();
  }
}



  // void _showToast(String message) {
  //   // Asegúrate de envolver la app con ToastificationWrapper en main.dart
  //   toastification.show(
  //     // Usamos title como String para compatibilidad con la API típica
  //     title: Text(message),
  //     primaryColor: Colors.white,
  //     backgroundColor:Colors.black,
  //     foregroundColor: Colors.purple.shade400,
  //     type: ToastificationType.success,
  //     style: ToastificationStyle.fillColored,
  //     alignment: Alignment.topCenter,
  //     showProgressBar: true,
  //     autoCloseDuration: const Duration(seconds: 3),
  //     icon: Icon(Icons.error_outline, color: Colors.purple.shade400),
  //     // Animación personalizada: se desliza desde arriba hacia su posición
  //     animationBuilder: (context, animation, alignment, child) {
  //       final curved = CurvedAnimation(
  //         parent: animation,
  //         curve: Curves.easeOutCubic,
  //       );
  //       final offset = Tween<Offset>(
  //         begin: const Offset(0, -1.0),
  //         end: Offset.zero,
  //       ).animate(curved);
  //       return SlideTransition(
  //         position: offset,
  //         child: FadeTransition(opacity: animation, child: child),
  //       );
  //     },
  //   );
  // }
