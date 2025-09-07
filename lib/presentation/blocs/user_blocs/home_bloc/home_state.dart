part of 'home_bloc.dart';

enum HomeStatus { initial, loading, success, failure }

final class HomeState extends Equatable {
  const HomeState({
    required this.currentIndex,
    required this.userEntity,
    required this.homeStatus,
    required this.messageError,
    required this.historyOrders,
    required this.activeOrder,
    required this.selectedOrder
  });
  final int currentIndex;
  final UserEntity userEntity;
  final HomeStatus homeStatus;
  final String? messageError;
  final List<AorderEntity> historyOrders;
  final AorderEntity? activeOrder;
  final AorderEntity selectedOrder;

  HomeState copyWith({
    int? currentIndex,
    UserEntity? userEntity,
    HomeStatus? homeStatus,
    String? messageError,
     final List<AorderEntity>? historyOrders,
    AorderEntity? activeOrder,
    AorderEntity? selectedOrder
  }) {
    return HomeState(
      homeStatus: homeStatus ?? this.homeStatus,
      currentIndex: currentIndex ?? this.currentIndex,
      userEntity: userEntity ?? this.userEntity,
      messageError: messageError ?? this.messageError,
      historyOrders: historyOrders ?? this.historyOrders,
      activeOrder: activeOrder ?? this.activeOrder,
      selectedOrder: selectedOrder ?? this.selectedOrder
    );
  }

  @override
  List<Object?> get props => [currentIndex, userEntity, homeStatus, messageError, activeOrder, selectedOrder, historyOrders];
}

final class HomeInitial extends HomeState {
  HomeInitial()
    : super(
        currentIndex: 0,
        userEntity: UserEntity.defaultValues,
        homeStatus: HomeStatus.initial,
        messageError: null,
        historyOrders: AorderEntity.historyOrders,
        activeOrder: null,
        selectedOrder: AorderEntity.aorderEntityExample
      );
}
