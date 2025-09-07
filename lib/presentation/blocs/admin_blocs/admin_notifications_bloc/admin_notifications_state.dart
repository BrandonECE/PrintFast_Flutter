part of 'admin_notifications_bloc.dart';

sealed class AdminNotificationsState extends Equatable {
  const AdminNotificationsState();
  
  @override
  List<Object> get props => [];
}

final class AdminNotificationsInitial extends AdminNotificationsState {}
