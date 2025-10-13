// lib/presentation/blocs/user_blocs/notifications_bloc/notifications_state.dart

part of 'notifications_bloc.dart';

enum NotificationsStatus { loading, success, failure }

/// Estado único que contiene status, lista y mensaje de error.
/// Usar copyWith para actualizar.
final class NotificationsState extends Equatable {
  final NotificationsStatus status;
  final List<NotificationEntity> notifications;
  final String? errorMessage;

  const NotificationsState({
    required this.status,
    required this.notifications,
    required this.errorMessage,
  });

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<NotificationEntity>? notifications,
    String? errorMessage,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      // si explicitamente se quiere limpiar el error, pasar errorMessage: null
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, notifications, errorMessage];
}

/// Clase que sólo inicializa valores por defecto (constructor que llama a super).
final class NotificationsInitial extends NotificationsState {
  const NotificationsInitial()
      : super(
          status: NotificationsStatus.loading,
          notifications: const [],
          errorMessage: null,
        );
}
