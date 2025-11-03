



import 'dart:async' show StreamSubscription;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

part 'connectivity_event.dart';
part 'connectivity_state.dart';


class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  final Connectivity _connectivity;
  // Hacemos el subscription dinámico para evitar errores de asignación si el stream
  // llega a emitir una List<ConnectivityResult> en alguna plataforma/versión.
  StreamSubscription<dynamic>? _subscription;

  ConnectivityBloc({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity(), super(ConnectivityState(hasInternet: true, isChecking: false)) {
    on<ConnectivityStarted>(_onStarted);
    on<ConnectivityStopped>(_onStopped);
    on<ConnectivityChangedEvent>(_onChanged);
    on<ConnectivityCheckRequested>(_onCheckRequested);
  }

  Future<void> _onStarted(
    ConnectivityStarted event,
    Emitter<ConnectivityState> emit,
  ) async {
    print("RESULTADO");
    emit(state.copyWith(isChecking: true));
    try {
       print("RESULTADO");
      final initial = await _connectivity.checkConnectivity();
      final isConnected = initial != ConnectivityResult.none;
      emit(
        state.copyWith(
          hasInternet: isConnected,
          isChecking: false,
          lastResult: initial.first,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isChecking: false));
      _showToast('Error al verificar conectividad: $e', isError: true);
    }

    // Start listening (cancelamos cualquier suscripción previa)
    await _subscription?.cancel();
    _subscription = _connectivity.onConnectivityChanged.listen(
      (result) {
        print("RESULTADO: $result");
        // El resultado puede ser ConnectivityResult ó List<ConnectivityResult>
        if (result is ConnectivityResult) {
          add(ConnectivityChangedEvent(result.first));
        } else {
                 // Si viene una lista, determinamos si hay al menos un conectado
        try {
          final list = result.cast<ConnectivityResult>();
          final hasConnected = list.any((r) => r != ConnectivityResult.none);
          // Elegimos un ConnectivityResult representativo:
          final representative = hasConnected
              ? ConnectivityResult.wifi
              : ConnectivityResult.none;
          add(ConnectivityChangedEvent(representative));
        } catch (_) {
          // Fallback: marcar como no conectado si no podemos castear
          add(ConnectivityChangedEvent(ConnectivityResult.none));
        }
        }
      
      },
      onError: (error) {
        _showToast('Error en monitoreo de red: $error', isError: true);
      },
    );
  }

  Future<void> _onStopped(
    ConnectivityStopped event,
    Emitter<ConnectivityState> emit,
  ) async {
    await _subscription?.cancel();
    _subscription = null;
  }

  Future<void> _onChanged(
    ConnectivityChangedEvent event,
    Emitter<ConnectivityState> emit,
  ) async {
    final prevConnected = state.hasInternet;
    final nowConnected = event.result != ConnectivityResult.none;

    emit(state.copyWith(hasInternet: nowConnected, lastResult: event.result));

    if (prevConnected != nowConnected) {
      if (nowConnected) {
        _showToast('Conexión a Internet restaurada', isError: false);
      } else {
        _showToast('Sin conexión a Internet', isError: true);
      }
    }
  }

  Future<void> _onCheckRequested(
    ConnectivityCheckRequested event,
    Emitter<ConnectivityState> emit,
  ) async {
    emit(state.copyWith(isChecking: true));
    try {
      final result = await _connectivity.checkConnectivity();
      final isConnected = result != ConnectivityResult.none;
      emit(
        state.copyWith(
          hasInternet: isConnected,
          isChecking: false,
          lastResult: result.first,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isChecking: false));
      _showToast('Error al verificar conexión: $e', isError: true);
    }
  }

  void _showToast(String message, {required bool isError}) {
    // Asegúrate de envolver la app con ToastificationWrapper en main.dart
    toastification.show(
      // Usamos title como String para compatibilidad con la API típica
      title: Text(message),
      primaryColor: isError ? Colors.red : Colors.green,
      type: isError ? ToastificationType.error : ToastificationType.success,
      style: ToastificationStyle.fillColored,
      alignment: Alignment.topCenter,
      showProgressBar: true,
      autoCloseDuration: const Duration(seconds: 3),
      icon: isError
          ? const Icon(Icons.error_outline, color: Colors.white)
          : const Icon(Icons.check_circle_outline, color: Colors.white),
      // Animación personalizada: se desliza desde arriba hacia su posición
      animationBuilder: (context, animation, alignment, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        final offset = Tween<Offset>(
          begin: const Offset(0, -1.0),
          end: Offset.zero,
        ).animate(curved);
        return SlideTransition(
          position: offset,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    _subscription = null;
    return super.close();
  }
}
