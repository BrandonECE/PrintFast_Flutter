// lib/presentation/blocs/user_blocs/home_bloc/home_bloc.dart
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:printfast_rebuild/domain/entities/entities.dart';
import 'package:printfast_rebuild/domain/repositories/auth_repository.dart';
import 'package:printfast_rebuild/domain/repositories/user_repository.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final AuthRepository authRepository;
  final UserRepository userRepository;

  // Streams & reconnection
  StreamSubscription<AorderEntity?>? _aorderSubscription;
  Timer? _aorderReconnectTimer;
  int _aorderReconnectAttempt = 0;

  StreamSubscription<int>? _unseenNotifSubscription;
  Timer? _notifReconnectTimer;
  int _notifReconnectAttempt = 0;

  final int _maxReconnectDelaySeconds = 30;

  // Progress timer for active order (ticks periodically to update label/progress)
  Timer? _progressTimer;
  static const Duration _progressTick = Duration(seconds: 5);

  HomeBloc({required this.authRepository, required this.userRepository})
    : super(HomeInitial()) {
    // --- Basic UI index change
    on<HomeChangeIndexBottomNavigationBarEvent>((event, emit) {
      emit(state.copyWith(currentIndex: event.currentIndex));
    });

    // --- User updated -> start listeners
    on<HomeUpdateUserEntityEvent>((event, emit) {
      emit(state.copyWith(userEntity: event.userEntity));
      // Start both listeners
      add(const HomeStartActiveOrderListenerEvent());
      add(const HomeStartNotificationsListenerEvent());
    });

    // --- Active order update (from stream)
    on<HomeUpdateActiveOrderEvent>((event, emit) async {
      final targetStatus = event.activeOrder == null
          ? HomeOrderStatus.noOrderActive
          : HomeOrderStatus.orderActive;

      // Transition animation: show loading -> wait -> set final
      emit(state.copyWith(homeOrderStatus: HomeOrderStatus.loading));
      await Future.delayed(const Duration(milliseconds: 600));

      // reset reconnect attempts on success
      _aorderReconnectAttempt = 0;

      final computed = _computeProgressAndLabel(event.activeOrder);

      emit(
        state.copyWith(
          activeOrder: event.activeOrder,
          homeOrderStatus: targetStatus,
          messageError: null,
          activeOrderProgress: computed.progress,
          activeOrderTimeLabel: computed.label,
        ),
      );

      // start/stop progress timer depending on accepted
      if (event.activeOrder != null && _orderIsAccepted(event.activeOrder!)) {
        _startProgressTimer(event.activeOrder);
      } else {
        _stopProgressTimer();
      }
    });

    // --- Active order stream error -> failure + schedule reconnect
    on<HomeActiveOrderErrorEvent>((event, emit) async {
      // If first failure, animate a brief loading to failure
      if (_aorderReconnectAttempt == 0) {
        emit(state.copyWith(homeOrderStatus: HomeOrderStatus.loading));
        await Future.delayed(const Duration(milliseconds: 600));
      }

      emit(
        state.copyWith(
          activeOrder: null,
          homeOrderStatus: HomeOrderStatus.failure,
          messageError: event.message,
          activeOrderProgress: 0.0,
          activeOrderTimeLabel: '',
        ),
      );

      _stopProgressTimer();
      _scheduleAorderReconnect();
    });

    // --- Manual set of watch status
    on<HomeSetOrderWatchStatusEvent>((event, emit) {
      emit(state.copyWith(homeOrderStatus: event.status));
    });

    // --- Progress update from internal timer
    on<HomeUpdateProgressEvent>((event, emit) {
      emit(
        state.copyWith(
          activeOrderProgress: event.progress,
          activeOrderTimeLabel: event.label,
        ),
      );
    });

    // --- Notifications: update unseen count
    on<HomeUpdateUnseenNotificationsCountEvent>((event, emit) {
      emit(
        state.copyWith(
          unseenNotificationsCount: event.count,
          notificationsStatus: HomeNotificationsStatus.success,
          notificationsErrorMessage: null,
        ),
      );
      // reset reconnect attempts because we have success
      _notifReconnectAttempt = 0;
    });

    // --- Notifications error
    on<HomeNotificationsErrorEvent>((event, emit) async {
      if (_notifReconnectAttempt == 0) {
        // brief animation (optional)
        emit(
          state.copyWith(notificationsStatus: HomeNotificationsStatus.loading),
        );
        await Future.delayed(const Duration(milliseconds: 400));
      }

      emit(
        state.copyWith(
          unseenNotificationsCount: 0,
          notificationsStatus: HomeNotificationsStatus.failure,
          notificationsErrorMessage: event.message,
        ),
      );

      _scheduleNotificationsReconnect();
    });

    // --- Manual start/stop notifications listener
    on<HomeStartNotificationsListenerEvent>((event, emit) {
      final reg = event.registration ?? state.userEntity.registration;
      if (reg.isNotEmpty) {
        emit(
          state.copyWith(notificationsStatus: HomeNotificationsStatus.loading),
        );
        _startNotificationsListener(reg);
      }
    });

    on<HomeStopNotificationsListenerEvent>((event, emit) async {
      await _stopNotificationsListener();
      emit(
        state.copyWith(
          unseenNotificationsCount: 0,
          notificationsStatus: HomeNotificationsStatus.idle,
          notificationsErrorMessage: null,
        ),
      );
    });

    // --- logout status
    on<HomeUpdateHomeLogOutStatusEvent>((event, emit) {
      emit(
        state.copyWith(
          homeLogOutStatus: event.homeLogOutStatus,
          messageError: event.messageError,
        ),
      );
    });

    // --- start/stop active order listener events (manual control)
    on<HomeStartActiveOrderListenerEvent>((event, emit) {
      final reg = event.registration ?? state.userEntity.registration;
      if (reg.isNotEmpty) {
        emit(state.copyWith(homeOrderStatus: HomeOrderStatus.loading));
        _startAorderListener(reg);
      }
    });

    on<HomeStopActiveOrderListenerEvent>((event, emit) async {
      await _stopAorderListener();
      _stopProgressTimer();
      emit(
        state.copyWith(
          activeOrder: null,
          homeOrderStatus: HomeOrderStatus.idle,
          activeOrderProgress: 0.0,
          activeOrderTimeLabel: '',
        ),
      );
    });

    on<HomeMarkAllNotificationsAsSeenEvent>(_markAllAsSeen);
  }

  Future<void> _markAllAsSeen(
    HomeMarkAllNotificationsAsSeenEvent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      await userRepository.markAllNotificationsAsSeen(
        state.userEntity.registration,
      );
    } catch (e) {
      print(e);
    }
  }

  // ------------------ AORDER STREAM ------------------
  void _startAorderListener(String registration) {
    _aorderSubscription?.cancel();
    _aorderSubscription = null;

    try {
      final Stream<AorderEntity?> stream = userRepository.getAorderStream(
        registration,
      );

      _aorderSubscription = stream.listen(
        (aorder) {
          add(HomeUpdateActiveOrderEvent(activeOrder: aorder));
        },
        onError: (error, stack) {
          final msg =
              (error?.toString() ?? 'Error desconocido en aorder stream');
          // ignore: avoid_print
          print('HomeBloc - error en aorder stream: $msg');
          add(HomeActiveOrderErrorEvent(message: msg));
        },
        onDone: () {
          // ignore: avoid_print
          print('HomeBloc - aorder stream done (onDone) — reconectando');
          add(const HomeActiveOrderErrorEvent(message: 'Stream finalizó'));
        },
        cancelOnError: false,
      );
    } catch (e) {
      final msg = 'HomeBloc - excepción iniciando aorder stream: $e';
      // ignore: avoid_print
      print(msg);
      add(HomeActiveOrderErrorEvent(message: msg));
    }
  }

  void _scheduleAorderReconnect() {
    if (_aorderReconnectTimer != null && _aorderReconnectTimer!.isActive)
      return;

    _aorderReconnectAttempt++;
    final seconds = (_aorderReconnectAttempt > 6)
        ? _maxReconnectDelaySeconds
        : (1 << (_aorderReconnectAttempt - 1));
    final backoff = Duration(
      seconds: seconds.clamp(1, _maxReconnectDelaySeconds),
    );

    // ignore: avoid_print
    print(
      'HomeBloc - reconectando aorder en ${backoff.inSeconds}s (intento #$_aorderReconnectAttempt)',
    );

    _aorderReconnectTimer = Timer(backoff, () {
      _aorderSubscription?.cancel();
      _aorderSubscription = null;
      final reg = state.userEntity.registration;
      if (reg.isNotEmpty) {
        _startAorderListener(reg);
      }
    });
  }

  Future<void> _stopAorderListener() async {
    try {
      await _aorderSubscription?.cancel();
    } catch (e) {
      // ignore: avoid_print
      print('Error cancelando aorderSubscription: $e');
    } finally {
      _aorderSubscription = null;
      // emit update to ensure UI resets
      add(const HomeUpdateActiveOrderEvent(activeOrder: null));
    }
  }

  // ------------------ NOTIFICATIONS STREAM (unseen count) ------------------
  void _startNotificationsListener(String registration) {
    _unseenNotifSubscription?.cancel();
    _unseenNotifSubscription = null;

    try {
      final Stream<int> stream = userRepository.unseenNotificationsCount(
        registration,
      );

      _unseenNotifSubscription = stream.listen(
        (count) {
          print(count);
          add(HomeUpdateUnseenNotificationsCountEvent(count: count));
        },
        onError: (error, stack) {
          final msg =
              (error?.toString() ??
              'Error desconocido en notifications stream');
          // ignore: avoid_print
          print('HomeBloc - error en notifications stream: $msg');
          add(HomeNotificationsErrorEvent(message: msg));
          add(HomeUpdateUnseenNotificationsCountEvent(count: 0));
        },
        onDone: () {
          // ignore: avoid_print
          print('HomeBloc - notifications stream done (onDone) — reconectando');
          add(const HomeNotificationsErrorEvent(message: 'Stream finalizó'));
          add(HomeUpdateUnseenNotificationsCountEvent(count: 0));
        },
        cancelOnError: false,
      );
    } catch (e) {
      final msg = 'HomeBloc - excepción iniciando notifications stream: $e';
      // ignore: avoid_print
      print(msg);
      add(HomeNotificationsErrorEvent(message: msg));
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

    // ignore: avoid_print
    print(
      'HomeBloc - reconectando notifications en ${backoff.inSeconds}s (intento #$_notifReconnectAttempt)',
    );

    _notifReconnectTimer = Timer(backoff, () {
      _unseenNotifSubscription?.cancel();
      _unseenNotifSubscription = null;
      final reg = state.userEntity.registration;
      if (reg.isNotEmpty) {
        _startNotificationsListener(reg);
      }
    });
  }

  Future<void> _stopNotificationsListener() async {
    try {
      await _unseenNotifSubscription?.cancel();
    } catch (e) {
      // ignore: avoid_print
      add(const HomeUpdateUnseenNotificationsCountEvent(count: 0));
      print('Error cancelando unseenNotifSubscription: $e');
    } finally {
      _unseenNotifSubscription = null;
      add(const HomeUpdateUnseenNotificationsCountEvent(count: 0));
    }
  }

  // ------------------ Progress timer helpers ------------------
  void _startProgressTimer(AorderEntity? order) {
    _stopProgressTimer();
    if (order == null) return;
    if (!_orderIsAccepted(order)) return;
    _updateProgressState(order); // immediate run
    _progressTimer = Timer.periodic(_progressTick, (_) {
      _updateProgressState(order);
    });
  }

  void _stopProgressTimer() {
    try {
      _progressTimer?.cancel();
    } catch (_) {}
    _progressTimer = null;
  }

  bool _orderIsAccepted(AorderEntity order) {
    try {
      final v = order.hasItBeenAccepted;
      if (v == null) return false;
      if (v is bool) return v;
      return false;
    } catch (_) {
      return false;
    }
  }

  void _updateProgressState(AorderEntity? order) {
    if (order == null) return;

    final computed = _computeProgressAndLabel(order);

    final changedProgress =
        (computed.progress - state.activeOrderProgress).abs() > 0.001;
    final changedLabel = computed.label != state.activeOrderTimeLabel;

    if (changedProgress || changedLabel) {
      add(
        HomeUpdateProgressEvent(
          progress: computed.progress,
          label: computed.label,
        ),
      );
    }
  }

  // ------------------ Sign out & cleanup ------------------
  Future<void> signOut() async {
    add(
      HomeUpdateHomeLogOutStatusEvent(
        homeLogOutStatus: HomeLogOutStatus.loading,
        messageError: null,
      ),
    );
    await Future.delayed(const Duration(milliseconds: 1000));
    try {
      await authRepository.signOut();
      add(
        HomeUpdateHomeLogOutStatusEvent(
          homeLogOutStatus: HomeLogOutStatus.success,
          messageError: null,
        ),
      );

      // stop everything
      await _stopAorderListener();
      _stopProgressTimer();
      await _stopNotificationsListener();

      add(HomeChangeIndexBottomNavigationBarEvent(currentIndex: 0));
    } catch (e) {
      add(
        HomeUpdateHomeLogOutStatusEvent(
          homeLogOutStatus: HomeLogOutStatus.failure,
          messageError: e.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    _aorderReconnectTimer?.cancel();
    _notifReconnectTimer?.cancel();
    _stopProgressTimer();
    await _stopAorderListener();
    await _stopNotificationsListener();
    return super.close();
  }

  // ------------------------------------------------------------
  // Helper: calcula progreso (0..1) y label ("12 min" o "1.5 h")
  // ------------------------------------------------------------
  _ProgressLabel _computeProgressAndLabel(AorderEntity? order) {
    if (order == null) return _ProgressLabel(progress: 0.0, label: '');

    final DateTime? init = order.initDate;
    final DateTime? estimated = order.estimatedDeliveryTime;
    final now = DateTime.now();

    if (init == null || estimated == null) {
      return _ProgressLabel(progress: 0.0, label: '');
    }

    if (estimated.isBefore(init)) {
      return _ProgressLabel(progress: 0.0, label: '');
    }

    final total = estimated.difference(init).inSeconds;
    final elapsed = now.difference(init).inSeconds;

    double progress;
    if (now.isBefore(init)) {
      progress = 0.0;
    } else if (now.isAfter(estimated)) {
      progress = 1.0;
    } else {
      progress = total > 0 ? (elapsed / total) : 0.0;
    }
    progress = progress.clamp(0.0, 1.0);

    final remaining = estimated.difference(now);
    String label;
    if (remaining.inSeconds <= 0) {
      label = '0 min';
    } else if (remaining.inMinutes < 60) {
      label = '${remaining.inMinutes} min';
    } else {
      final double hours = remaining.inMinutes / 60.0;
      final double rounded = (hours * 10).roundToDouble() / 10.0;
      label = '${rounded.toStringAsFixed((rounded % 1 == 0) ? 0 : 1)} h';
    }

    return _ProgressLabel(progress: progress, label: label);
  }
}

class _ProgressLabel {
  final double progress;
  final String label;
  _ProgressLabel({required this.progress, required this.label});
}
