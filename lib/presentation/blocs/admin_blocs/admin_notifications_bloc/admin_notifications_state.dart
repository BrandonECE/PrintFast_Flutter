part of 'admin_notifications_bloc.dart';

enum AdminNotificationsStatus { loading, success, failure }

class AdminNotificationsState extends Equatable {
  final AdminNotificationsStatus status;
  final List<NotificationEntity> notifications;
  final String? errorMessage;

  const AdminNotificationsState({
    required this.status,
    required this.notifications,
    required this.errorMessage,
  });

  AdminNotificationsState copyWith({
    AdminNotificationsStatus? status,
    List<NotificationEntity>? notifications,
    String? errorMessage,
  }) {
    return AdminNotificationsState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, notifications, errorMessage];
}

class AdminNotificationsInitial extends AdminNotificationsState {
  const AdminNotificationsInitial()
      : super(
          status: AdminNotificationsStatus.loading,
          notifications: const [],
          errorMessage: null,
        );
}