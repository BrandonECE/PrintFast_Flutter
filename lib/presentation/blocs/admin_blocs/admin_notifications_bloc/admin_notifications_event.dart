part of 'admin_notifications_bloc.dart';

sealed class AdminNotificationsEvent extends Equatable {
  const AdminNotificationsEvent();

  @override
  List<Object> get props => [];
}

class LoadAdminNotifications extends AdminNotificationsEvent {
  const LoadAdminNotifications();
}

