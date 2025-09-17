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
  List<Object> get props => [currentIndex];
}

final class HomeUpdateUserEntityEvent extends HomeEvent {
  const HomeUpdateUserEntityEvent({required this.userEntity});
  final UserEntity userEntity;

  @override
  List<Object> get props => [userEntity];
}

final class HomeUpdateSelectedOrderEvent extends HomeEvent {
  const HomeUpdateSelectedOrderEvent({required this.selectedOrder});
  final AorderEntity selectedOrder;

  @override
  List<Object> get props => [selectedOrder];
}

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
