part of 'home_bloc.dart';

enum HomeStatus { initial, loading, success, failure }

final class HomeState extends Equatable {
  const HomeState({
    required this.currentIndex,
    required this.userEntity,
    required this.homeStatus,
    required this.messageError
  });
  final int currentIndex;
  final UserEntity userEntity;
  final HomeStatus homeStatus;
  final String? messageError;

  HomeState copyWith({
    int? currentIndex,
    UserEntity? userEntity,
    HomeStatus? homeStatus,
    String? messageError
  }) {
    return HomeState(
      homeStatus: homeStatus ?? this.homeStatus,
      currentIndex: currentIndex ?? this.currentIndex,
      userEntity: userEntity ?? this.userEntity,
      messageError: messageError ?? this.messageError
    );
  }

  @override
  List<Object?> get props => [currentIndex, userEntity, homeStatus, messageError];
}

final class HomeInitial extends HomeState {
  HomeInitial()
    : super(
        currentIndex: 0,
        userEntity: UserEntity.defaultValues(),
        homeStatus: HomeStatus.initial,
        messageError: null
      );
}
