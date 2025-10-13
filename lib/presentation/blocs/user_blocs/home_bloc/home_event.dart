// lib/presentation/blocs/user_blocs/home_bloc/home_event.dart
part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

final class HomeChangeIndexBottomNavigationBarEvent extends HomeEvent {
  const HomeChangeIndexBottomNavigationBarEvent({required this.currentIndex});
  final int currentIndex;

  @override
  List<Object?> get props => [currentIndex];
}

final class HomeUpdateUserEntityEvent extends HomeEvent {
  const HomeUpdateUserEntityEvent({required this.userEntity});
  final UserEntity userEntity;

  @override
  List<Object?> get props => [userEntity];
}

final class HomeUpdateActiveOrderEvent extends HomeEvent {
  const HomeUpdateActiveOrderEvent({required this.activeOrder});
  final AorderEntity? activeOrder;

  @override
  List<Object?> get props => [activeOrder];
}

final class HomeActiveOrderErrorEvent extends HomeEvent {
  const HomeActiveOrderErrorEvent({required this.message});
  final String message;

  @override
  List<Object?> get props => [message];
}

final class HomeSetOrderWatchStatusEvent extends HomeEvent {
  const HomeSetOrderWatchStatusEvent({required this.status});
  final HomeOrderStatus status;

  @override
  List<Object?> get props => [status];
}

final class HomeStartActiveOrderListenerEvent extends HomeEvent {
  const HomeStartActiveOrderListenerEvent({this.registration});
  final String? registration;

  @override
  List<Object?> get props => [registration];
}

final class HomeStopActiveOrderListenerEvent extends HomeEvent {
  const HomeStopActiveOrderListenerEvent();

  @override
  List<Object?> get props => [];
}

// Progress update (internal)
final class HomeUpdateProgressEvent extends HomeEvent {
  const HomeUpdateProgressEvent({required this.progress, required this.label});
  final double progress;
  final String label;

  @override
  List<Object?> get props => [progress, label];
}

// ---------------- Notifications events ----------------
final class HomeStartNotificationsListenerEvent extends HomeEvent {
  const HomeStartNotificationsListenerEvent({this.registration});
  final String? registration;

  @override
  List<Object?> get props => [registration];
}

final class HomeStopNotificationsListenerEvent extends HomeEvent {
  const HomeStopNotificationsListenerEvent();

  @override
  List<Object?> get props => [];
}

final class HomeUpdateUnseenNotificationsCountEvent extends HomeEvent {
  const HomeUpdateUnseenNotificationsCountEvent({required this.count});
  final int count;

  @override
  List<Object?> get props => [count];
}

final class HomeNotificationsErrorEvent extends HomeEvent {
  const HomeNotificationsErrorEvent({required this.message});
  final String message;

  @override
  List<Object?> get props => [message];
}

// ---------------- Logout status update ----------------
final class HomeUpdateHomeLogOutStatusEvent extends HomeEvent {
  const HomeUpdateHomeLogOutStatusEvent({
    required this.homeLogOutStatus,
    required this.messageError,
  });

  final HomeLogOutStatus homeLogOutStatus;
  final String? messageError;

  @override
  List<Object?> get props => [homeLogOutStatus, messageError];
}


final class HomeMarkAllNotificationsAsSeenEvent extends HomeEvent {
  const HomeMarkAllNotificationsAsSeenEvent();
  @override
  List<Object?> get props => [];
}

