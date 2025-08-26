part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

final class HomeChangeIndexBottomNavigationBarEvent extends HomeEvent {
  const HomeChangeIndexBottomNavigationBarEvent({required this.currentInde});
  final int currentInde;

  @override
  List<Object> get props => [currentInde];
}

final class HomeUpdateUserEntityEvent extends HomeEvent {
  const HomeUpdateUserEntityEvent({required this.userEntity});
  final UserEntity userEntity;

  @override
  List<Object> get props => [userEntity];
}

final class HomeUpdateHomeStatusEvent extends HomeEvent {
  const HomeUpdateHomeStatusEvent({required this.homeStatus, required this.messageError});
  final HomeStatus homeStatus;
  final String? messageError;

  @override
  List<Object?> get props => [homeStatus, messageError];
}
