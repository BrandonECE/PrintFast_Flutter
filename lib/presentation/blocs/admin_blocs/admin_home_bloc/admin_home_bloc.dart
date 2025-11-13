import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:printfast_rebuild/domain/entities/entities.dart';
import 'package:printfast_rebuild/domain/repositories/auth_repository.dart';
import 'package:printfast_rebuild/domain/repositories/admin_repository.dart';

part 'admin_home_event.dart';
part 'admin_home_state.dart';

class AdminHomeBloc extends Bloc<AdminHomeEvent, AdminHomeState> {
  final AuthRepository authRepository;
  final AdminRepository adminRepository;

  // Timer para progreso general
  Timer? _adminProgressTimer;
  static const Duration _adminProgressTick = Duration(seconds: 3);
  int _progressCounter = 0;

  // Streams existentes
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

  bool _wasPendingOrderRejected = false;

  // Archiving
  static const int definedCountdownTime = 3;
  Timer? _archivingTimer;
  int _archivingCountdown = definedCountdownTime;
  bool _isArchivingInProgress = false;

  AdminHomeBloc({required this.authRepository, required this.adminRepository})
    : super(AdminHomeInitial()) {
    // ========== EVENTOS EXISTENTES ==========
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
      add(
        AdminHomeOrderUpdateDeliveryTimeEvent(
          deliveryTime:
              event.selectedOrder.estimatedDeliveryTime ?? DateTime.now(),
        ),
      );
      emit(state.copyWith(selectedOrder: event.selectedOrder));
    });

    on<AdminHomeUpdateHomeLogOutStatusEvent>((event, emit) {
      emit(
        state.copyWith(
          adminHomeLogOutStatus: event.adminHomeLogOutStatus,
          messageError: event.messageError,
        ),
      );
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
      final List<AorderEntity> acceptedOrders = <AorderEntity>[];
      final List<AorderEntity> pendingOrders = <AorderEntity>[];

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

      final doesSelectedAcceptedOrderCanceledByUserExist = event.aorders.any(
        (aorder) => aorder.orderCode == state.selectedAceptedOrderCode,
      );

      final doesSelectedPendingOrderWasCanceledByUser = !pendingOrders.any(
        (aorder) => aorder.orderCode == state.selectedOrder.orderCode,
      );

      print(
        "_wasPendingOrderRejected ($_wasPendingOrderRejected) && doesSelectedPendingOrderWasCanceledByUser ($doesSelectedPendingOrderWasCanceledByUser)",
      );

      emit(
        state.copyWith(
          adminAordersStatus: AdminAordersStatus.success,
          acceptedOrders: acceptedOrders,
          pendingOrders: pendingOrders,
          archivingAcceptedOrderAfterBeingaCancelledByTheUserStatus:
              !doesSelectedAcceptedOrderCanceledByUserExist
              ? ArchivingAcceptedOrderAfterBeingCanceledByTheUserStatus.idle
              : state.archivingAcceptedOrderAfterBeingaCancelledByTheUserStatus,
          wasPendingOrderRejected:
              _wasPendingOrderRejected &&
              doesSelectedPendingOrderWasCanceledByUser,
          messageError: null,
        ),
      );

      // Iniciar/verificar el progress timer después de actualizar órdenes
      _startAdminProgressTimerIfNeeded();

      if (_wasPendingOrderRejected) {
        _wasPendingOrderRejected = false;
      }
    });

    on<AdminHomeAordersErrorEvent>((event, emit) async {
      // Detener timer cuando hay error
      _stopAdminProgressTimer();

      // Si es el primer error, mostrar loading brevemente
      if (_aordersReconnectAttempt == 0) {
        emit(state.copyWith(adminAordersStatus: AdminAordersStatus.loading));
        await Future.delayed(const Duration(milliseconds: 600));
      }

      emit(
        state.copyWith(
          adminAordersStatus: AdminAordersStatus.failure,
          messageError: event.message,
          hasActiveOrders: false,
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

    on<AdminHomeUpdateSelectedAcceptedOrderCodeValueEvent>((event, emit) {
      emit(
        state.copyWith(
          selectedAceptedOrderCode: event.selectedAcceptedOrderCode,
        ),
      );
    });

    on<AdminHomeUpdateAdminHomeActionsEvent>((event, emit) {
      emit(state.copyWith(adminHomeActions: event.adminHomeActions));
    });

    on<AdminHomeUpdateReceptionStatusEvent>((event, emit) {
      emit(state.copyWith(receptionStatus: event.adminReceptionStatus));
    });

    on<AdminHomeOrderShowChangeDeliveryTimeEvent>((event, emit) {
      emit(
        state.copyWith(
          showDeliveryTimeBottomSheet: event.showDeliveryTimeBottomSheet,
        ),
      );
    });

    on<AdminHomeOrderUpdateDeliveryTimeEvent>((event, emit) {
      emit(state.copyWith(deliveryTime: event.deliveryTime));
    });

    on<AdminHomeUpdateChangedeliveryPendingOrderTimeStatusEvent>((event, emit) {
      emit(
        state.copyWith(
          changeDeliveryPendingOrderTimeStatus:
              event.changedeliveryPendingOrderTimeStatus,
        ),
      );
    });

    on<AdminHomeUpdateChangedeliveryAcceptedOrderTimeStatusEvent>((
      event,
      emit,
    ) {
      emit(
        state.copyWith(
          changeDeliveryAcceptedOrderTimeStatus:
              event.changedeliveryAcceptedOrderTimeStatus,
        ),
      );
    });

    on<
      AdminHomeUpdateArchivingAcceptedOrderAfterBeingaCanceledByTheUserStatusEvent
    >((event, emit) {
      emit(
        state.copyWith(
          archivingAcceptedOrderAfterBeingaCancelledByTheUserStatus:
              event.archivingAcceptedOrderAfterBeingaCancelledByTheUserStatus,
        ),
      );
    });

    on<AdminHomeUserAcceptedArchivingEvent>(_userAcceptedArchivingEvent);

    on<AdminHomeAcceptChangeDeliveryTimeEvent>(
      _adminHomeAcceptChangeDeliveryTimeEvent,
    );

    on<AdminHomeArchiveAcceptedOrderAfterBeingCanceledByTheUserEvent>(
      _adminHomeArchiveAcceptedOrderAfterBeingaCanceledByTheUserEvent,
    );

    on<AdminHomeShowMessageArchiveCanceledOrderByUserEvent>((event, emit) {
      emit(
        state.copyWith(
          showMessageArchiveCanceledOrderByUser:
              event.showMessageArchiveCanceledOrderByUser,
        ),
      );
    });

    on<AdminHomeUpdateEnteredPinEvent>((event, emit) {
      emit(state.copyWith(enteredPin: event.enteredPin));
    });

    on<AdminHomeUpdateCodeValidationStatusEvent>((event, emit) {
      emit(state.copyWith(codeValidationStatus: event.codeValidationStatus));
    });

    on<AdminHomeConfirmCodeValidationStatusEvent>(
      _adminHomeConfirmCodeValidationStatusEvent,
    );

    // --- NUEVOS EVENTOS PARA EL PROGRESS TIMER ---
    on<AdminHomeCheckProgressTimerEvent>((event, emit) {
      _startAdminProgressTimerIfNeeded();
    });

    on<AdminHomeForceProgressUpdateEvent>((event, emit) {
      _progressCounter++;
      emit(
        state.copyWith(
          progressTick: _progressCounter,
          hasActiveOrders: _checkIfAnyActiveOrders(),
        ),
      );
    });

    on<AdminHomeUpdateHasActiveOrdersEvent>((event, emit) {
      emit(state.copyWith(hasActiveOrders: event.hasActiveOrders));
    });
  }

  // ========== MÉTODOS DEL PROGRESS TIMER ==========

  void _startAdminProgressTimerIfNeeded() {
    if (state.adminAordersStatus == AdminAordersStatus.failure) {
      _stopAdminProgressTimer();
      return;
    }

    final hasActiveOrders = _checkIfAnyActiveOrders();

    if (hasActiveOrders &&
        (_adminProgressTimer == null || !_adminProgressTimer!.isActive)) {
      _startAdminProgressTimer();
      add(AdminHomeUpdateHasActiveOrdersEvent(hasActiveOrders: true));
    } else if (!hasActiveOrders) {
      _stopAdminProgressTimer();
      add(AdminHomeUpdateHasActiveOrdersEvent(hasActiveOrders: false));
    }
  }

  bool _checkIfAnyActiveOrders() {
    if (state.adminAordersStatus == AdminAordersStatus.failure) {
      return false;
    }

    final allOrders = [...state.acceptedOrders, ...state.pendingOrders];

    return allOrders.any(
      (order) =>
          order.estimatedDeliveryTime != null &&
          DateTime.now().isBefore(order.estimatedDeliveryTime!) &&
          !order.hasItBeenCompleted &&
          !order.hasItBeenCanceledByUser &&
          (order.hasItBeenAccepted == true || order.hasItBeenAccepted == null),
    );
  }

  void _startAdminProgressTimer() {
    _stopAdminProgressTimer();

    _adminProgressTimer = Timer.periodic(_adminProgressTick, (timer) {
      _progressCounter++;
      print(_progressCounter);
      add(AdminHomeForceProgressUpdateEvent());

      if (!_checkIfAnyActiveOrders()) {
        _stopAdminProgressTimer();
        add(AdminHomeCheckProgressTimerEvent());
      }
    });
  }

  void _stopAdminProgressTimer() {
    try {
      _adminProgressTimer?.cancel();
    } catch (_) {}
    _adminProgressTimer = null;
    _progressCounter = 0;
  }

  // ========== MÉTODOS EXISTENTES ==========

  FutureOr<void> _adminHomeConfirmCodeValidationStatusEvent(
    AdminHomeConfirmCodeValidationStatusEvent event,
    Emitter<AdminHomeState> emit,
  ) async {
    try {
      final String pin = state.enteredPin;
      final AorderEntity aorder = state.selectedOrder;
      emit(state.copyWith(codeValidationStatus: CodeValidationStatus.loading));
      await Future.delayed(Duration(milliseconds: 2000));
      emit(
        state.copyWith(codeValidationStatus: CodeValidationStatus.validating),
      );

      //Funciones
      final String registration = state.selectedOrder.userRegistration;
      final String copyShopEmail = state.selectedOrder.copyShopEmail;
      final String verificationCode = pin;

      final bool itWasVerified = await adminRepository
          .verifyOrderByVerificationCode(
            registration,
            copyShopEmail,
            verificationCode,
          );

      print(itWasVerified);

      if (!itWasVerified) {
        emit(
          state.copyWith(
            adminHomeActions: AdminHomeActions.validateCode,
            codeValidationStatus: CodeValidationStatus.invalid,
            messageError: 'Error: El código proporcionado no es correcto',
          ),
        );
        return;
      }

      await Future.delayed(Duration(milliseconds: 2000));

      await adminRepository.completeAndArchiveOrder(
        aorder,
        registration,
        copyShopEmail,
      );

      emit(state.copyWith(codeValidationStatus: CodeValidationStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          adminHomeActions: AdminHomeActions.validateCode,
          codeValidationStatus: CodeValidationStatus.failure,
          messageError: e.toString(),
        ),
      );
    }
    emit(state.copyWith(enteredPin: ''));
  }

  FutureOr<void>
  _adminHomeArchiveAcceptedOrderAfterBeingaCanceledByTheUserEvent(
    AdminHomeArchiveAcceptedOrderAfterBeingCanceledByTheUserEvent event,
    Emitter<AdminHomeState> emit,
  ) async {
    try {
      _cancelArchivingOperation();

      _archivingCountdown = definedCountdownTime;
      _isArchivingInProgress = true;

      emit(
        state.copyWith(
          archivingAcceptedOrderAfterBeingaCancelledByTheUserStatus:
              ArchivingAcceptedOrderAfterBeingCanceledByTheUserStatus.loading,
          archivingCountdown: _archivingCountdown,
        ),
      );

      // CONTADOR SIMPLE CON LOOP
      await Future.delayed(const Duration(milliseconds: 500));
      while (_archivingCountdown > 0 && _isArchivingInProgress) {
        await Future.delayed(const Duration(seconds: 1));

        if (!_isArchivingInProgress) break; // Si fue cancelado

        _archivingCountdown--;

        if (!emit.isDone) {
          emit(state.copyWith(archivingCountdown: _archivingCountdown));
        }

        print('⏰ Countdown: $_archivingCountdown');
      }

      // EJECUTAR FIREBASE SI LLEGÓ A 0 Y NO FUE CANCELADO
      if (_archivingCountdown <= 0 && _isArchivingInProgress) {
        await _executeFirebaseFunction(emit, true);
      }
    } catch (e) {
      _cancelArchivingOperation();

      if (!emit.isDone) {
        emit(
          state.copyWith(
            archivingAcceptedOrderAfterBeingaCancelledByTheUserStatus:
                ArchivingAcceptedOrderAfterBeingCanceledByTheUserStatus.failure,
            messageError: e.toString(),
            adminHomeActions: AdminHomeActions.acceptedOrderCanceledByUser,
            archivingCountdown: 0,
          ),
        );
      }
    }
  }

  FutureOr<void> _userAcceptedArchivingEvent(
    AdminHomeUserAcceptedArchivingEvent event,
    Emitter<AdminHomeState> emit,
  ) async {
    if (_isArchivingInProgress && !emit.isDone) {
      print('Usuario aceptó manualmente');
      emit(state.copyWith(archivingCountdown: 0));
      _cancelArchivingOperation();
      await _executeFirebaseFunction(emit, false);
    }
  }

  Future<void> _executeFirebaseFunction(
    Emitter<AdminHomeState> emit,
    bool fromCountDown,
  ) async {
    print(
      "!_isArchivingInProgress: ${!_isArchivingInProgress} || emit.isDone: ${emit.isDone}",
    );
    if ((!_isArchivingInProgress && fromCountDown) || emit.isDone) return;

    try {
      print('🔥 Ejecutando función de Firebase...');
      await Future.delayed(const Duration(milliseconds: 500)); // Simulación

      // TU FUNCIÓN DE FIREBASE AQUÍ
      final bool doesExistAorder = state.acceptedOrders.any(
        (aorder) => aorder.orderCode == state.selectedAceptedOrderCode,
      );
      if (doesExistAorder) {
        final AorderEntity aorder = state.acceptedOrders.firstWhere(
          (aorder) => aorder.orderCode == state.selectedAceptedOrderCode,
        );
        await adminRepository.archiveAcceptedOrderCanceledByUser(aorder);
      } else {
        throw Exception(
          "No se pudo completar la operación. La referencia de la orden especificada es inexistente.",
        );
      }

      _isArchivingInProgress = false;

      if (!emit.isDone) {
        emit(
          state.copyWith(
            archivingAcceptedOrderAfterBeingaCancelledByTheUserStatus:
                ArchivingAcceptedOrderAfterBeingCanceledByTheUserStatus.success,
            archivingCountdown: 0,
          ),
        );
      }
    } catch (e) {
      _isArchivingInProgress = false;

      if (!emit.isDone) {
        emit(
          state.copyWith(
            archivingAcceptedOrderAfterBeingaCancelledByTheUserStatus:
                ArchivingAcceptedOrderAfterBeingCanceledByTheUserStatus.failure,
            messageError: e.toString(),
            archivingCountdown: 0,
          ),
        );
      }
    }
  }

  void _cancelArchivingOperation() {
    _archivingTimer?.cancel();
    _archivingTimer = null;
    _archivingCountdown = definedCountdownTime;
    _isArchivingInProgress = false;
  }

  FutureOr<void> _adminHomeAcceptChangeDeliveryTimeEvent(
    AdminHomeAcceptChangeDeliveryTimeEvent event,
    Emitter<AdminHomeState> emit,
  ) async {
    final userRegistration = state.userEntity.registration;
    final copyShopEmail = state.copyShopEntity.copyShopEmail;
    final orderCode = state.selectedOrder.orderCode;
    final newDeliveryTime = state.deliveryTime;
    try {
      emit(
        state.copyWith(
          changeDeliveryPendingOrderTimeStatus:
              event.adminHomeActions ==
                  AdminHomeActions.changeDeliveryPendingOrderTime
              ? ChangeDeliveryPendingOrderTimeStatus.loading
              : null,
          changeDeliveryAcceptedOrderTimeStatus:
              event.adminHomeActions ==
                  AdminHomeActions.changeDeliveryAcceptedOrderTime
              ? ChangeDeliveryAcceptedOrderTimeStatus.loading
              : null,
        ),
      );
      await Future.delayed(const Duration(milliseconds: 600));

      await adminRepository.updateEstimatedDeliveryTime(
        userRegistration,
        copyShopEmail,
        orderCode,
        newDeliveryTime,
        updateHasTheEstimatedDeliveryTimeChanged:
            state.selectedOrder.hasItBeenAccepted ?? false,
      );
      print("GOOD");
      emit(
        state.copyWith(
          changeDeliveryPendingOrderTimeStatus:
              event.adminHomeActions ==
                  AdminHomeActions.changeDeliveryPendingOrderTime
              ? ChangeDeliveryPendingOrderTimeStatus.success
              : null,
          changeDeliveryAcceptedOrderTimeStatus:
              event.adminHomeActions ==
                  AdminHomeActions.changeDeliveryAcceptedOrderTime
              ? ChangeDeliveryAcceptedOrderTimeStatus.success
              : null,
        ),
      );
    } catch (e) {
      print("Error: $e");
      emit(
        state.copyWith(
          changeDeliveryPendingOrderTimeStatus:
              event.adminHomeActions ==
                  AdminHomeActions.changeDeliveryPendingOrderTime
              ? ChangeDeliveryPendingOrderTimeStatus.failure
              : null,
          changeDeliveryAcceptedOrderTimeStatus:
              event.adminHomeActions ==
                  AdminHomeActions.changeDeliveryAcceptedOrderTime
              ? ChangeDeliveryAcceptedOrderTimeStatus.failure
              : null,
          adminHomeActions: event.adminHomeActions,
          messageError: e.toString(),
        ),
      );
    }
    emit(state.copyWith(showDeliveryTimeBottomSheet: false));
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

      if (state.pendingOrderDecision == PendingOrderDecision.accept) {
        await adminRepository.acceptPendingOrder(
          userRegistration,
          copyShopEmail,
          orderCode,
        );
      } else if (state.pendingOrderDecision == PendingOrderDecision.reject) {
        _wasPendingOrderRejected = true;
        await adminRepository.rejectPendingOrder(
          userRegistration,
          copyShopEmail,
          orderCode,
          fileUrl,
        );
      }
      emit(state.copyWith(pendingOrderStatus: PendingOrderStatus.success));
    } catch (e) {
      if (state.pendingOrderDecision == PendingOrderDecision.reject) {
        _wasPendingOrderRejected = false;
      }
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
        (List<AorderEntity> aorders) {
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
      _stopAdminProgressTimer();
      await _stopAordersListener();
      _aordersReconnectTimer?.cancel();
      await _stopNotificationsListener();
      _notifReconnectTimer?.cancel();
      await _stopReceptionListener();
      _receptionReconnectTimer?.cancel();
      _cancelArchivingOperation();

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
    _stopAdminProgressTimer();
    _aordersReconnectTimer?.cancel();
    _notifReconnectTimer?.cancel();
    _receptionReconnectTimer?.cancel();
    _cancelArchivingOperation();
    await _stopAordersListener();
    await _stopNotificationsListener();
    await _stopReceptionListener();
    return super.close();
  }
}
