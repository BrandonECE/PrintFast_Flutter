part of 'home_bloc.dart';

enum HomeLogOutStatus { initial, loading, success, failure }

final class HomeState extends Equatable {
  const HomeState({
    required this.currentIndex,
    required this.userEntity,
    required this.homeLogOutStatus,
    required this.messageError,
    required this.historyOrders,
    required this.activeOrder,
    required this.selectedOrder,
  });
  final int currentIndex;
  final UserEntity userEntity;
  final HomeLogOutStatus homeLogOutStatus;
  final String? messageError;
  final List<AorderEntity> historyOrders;
  final AorderEntity? activeOrder;
  final AorderEntity selectedOrder;

  HomeState copyWith({
    int? currentIndex,
    UserEntity? userEntity,
    HomeLogOutStatus? homeLogOutStatus,
    String? messageError,
    final List<AorderEntity>? historyOrders,
    AorderEntity? activeOrder,
    AorderEntity? selectedOrder,
  }) {
    return HomeState(
      homeLogOutStatus: homeLogOutStatus ?? this.homeLogOutStatus,
      currentIndex: currentIndex ?? this.currentIndex,
      userEntity: userEntity ?? this.userEntity,
      messageError: messageError ?? this.messageError,
      historyOrders: historyOrders ?? this.historyOrders,
      activeOrder: activeOrder ?? this.activeOrder,
      selectedOrder: selectedOrder ?? this.selectedOrder,
    );
  }

  @override
  List<Object?> get props => [
    currentIndex,
    userEntity,
    homeLogOutStatus,
    messageError,
    activeOrder,
    selectedOrder,
    historyOrders,
  ];
}

final class HomeInitial extends HomeState {
  HomeInitial()
    : super(
        currentIndex: 0,
        userEntity: UserEntity.defaultValues,
        homeLogOutStatus: HomeLogOutStatus.initial,
        messageError: null,
        historyOrders: AorderEntity.historyOrders,
        activeOrder: null,
        selectedOrder: AorderEntity.aorderEntityExample,
      );
}
