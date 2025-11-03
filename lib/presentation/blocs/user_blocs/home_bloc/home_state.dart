// lib/presentation/blocs/user_blocs/home_bloc/home_state.dart
part of 'home_bloc.dart';

enum HomeLogOutStatus { initial, loading, success, failure }

/// Estado de la escucha / orden activa
enum HomeOrderStatus {
  idle, loading, orderActive,
  // noOrderActive,
  failure, canceledByCopyShop,
}

enum HomeCanceledOrderStatus{
  idle,
  loading, 
  sucessul,
  failure
}

/// Estado para el contador de notificaciones no vistas
enum HomeNotificationsStatus { idle, loading, success, failure }

enum HomeActions { none, cancelOrder }

final class HomeState extends Equatable {
  const HomeState({
    required this.currentIndex,
    required this.userEntity,
    required this.homeLogOutStatus,
    required this.messageError,
    required this.activeOrder,
    required this.homeOrderStatus,
    required this.activeOrderProgress,
    required this.activeOrderTimeLabel,
    required this.unseenNotificationsCount,
    required this.notificationsStatus,
    required this.notificationsErrorMessage,
    required this.homeActions,
    required this.isCanceledByCopyShopLoading,
    required this.remainingMinutes,
    required this.isTheShoppingButtonBlocked,
    required this.homeCanceledOrderStatus
  });

  final int currentIndex;
  final UserEntity userEntity;
  final HomeLogOutStatus homeLogOutStatus;
  final String? messageError;
  final AorderEntity? activeOrder;
  final HomeOrderStatus homeOrderStatus;
  final HomeActions homeActions;
  final bool isCanceledByCopyShopLoading;
  final bool isTheShoppingButtonBlocked;
  final HomeCanceledOrderStatus homeCanceledOrderStatus;

  // Progress / label for active order
  final double activeOrderProgress;
  final String activeOrderTimeLabel;
  final double remainingMinutes;

  // Unseen notifications count + status
  final int unseenNotificationsCount;
  final HomeNotificationsStatus notificationsStatus;
  final String? notificationsErrorMessage;

  HomeState copyWith({
    int? currentIndex,
    UserEntity? userEntity,
    HomeLogOutStatus? homeLogOutStatus,
    String? messageError,
    AorderEntity? activeOrder,
    HomeOrderStatus? homeOrderStatus,
    double? activeOrderProgress,
    String? activeOrderTimeLabel,
    int? unseenNotificationsCount,
    HomeNotificationsStatus? notificationsStatus,
    String? notificationsErrorMessage,
    HomeActions? homeActions,
    bool? isCanceledByCopyShopLoading,
    double? remainingMinutes,
    bool? isTheShoppingButtonBlocked,
    HomeCanceledOrderStatus? homeCanceledOrderStatus
  }) {
    return HomeState(
      currentIndex: currentIndex ?? this.currentIndex,
      userEntity: userEntity ?? this.userEntity,
      homeLogOutStatus: homeLogOutStatus ?? this.homeLogOutStatus,
      messageError: messageError ?? this.messageError,
      activeOrder: activeOrder ?? this.activeOrder,
      homeOrderStatus: homeOrderStatus ?? this.homeOrderStatus,
      activeOrderProgress: activeOrderProgress ?? this.activeOrderProgress,
      activeOrderTimeLabel: activeOrderTimeLabel ?? this.activeOrderTimeLabel,
      unseenNotificationsCount:
          unseenNotificationsCount ?? this.unseenNotificationsCount,
      notificationsStatus: notificationsStatus ?? this.notificationsStatus,
      notificationsErrorMessage:
          notificationsErrorMessage ?? this.notificationsErrorMessage,
      homeActions: homeActions ?? this.homeActions,
      isCanceledByCopyShopLoading:
          isCanceledByCopyShopLoading ?? this.isCanceledByCopyShopLoading,
      remainingMinutes: remainingMinutes ?? this.remainingMinutes,
      isTheShoppingButtonBlocked: isTheShoppingButtonBlocked ?? this.isTheShoppingButtonBlocked,
      homeCanceledOrderStatus: homeCanceledOrderStatus ?? this.homeCanceledOrderStatus
    );
  }

  @override
  List<Object?> get props => [
    currentIndex,
    userEntity,
    homeLogOutStatus,
    messageError,
    activeOrder,
    homeOrderStatus,
    activeOrderProgress,
    activeOrderTimeLabel,
    unseenNotificationsCount,
    notificationsStatus,
    notificationsErrorMessage,
    homeActions,
    isCanceledByCopyShopLoading,
    remainingMinutes,
    isTheShoppingButtonBlocked,
    homeCanceledOrderStatus
  ];
}

final class HomeInitial extends HomeState {
  HomeInitial()
    : super(
        currentIndex: 0,
        userEntity: UserEntity.defaultValues,
        homeLogOutStatus: HomeLogOutStatus.initial,
        messageError: null,
        activeOrder: null,
        homeOrderStatus: HomeOrderStatus.idle,
        activeOrderProgress: 0.0,
        activeOrderTimeLabel: '',
        unseenNotificationsCount: 0,
        notificationsStatus: HomeNotificationsStatus.idle,
        notificationsErrorMessage: null,
        homeActions: HomeActions.none,
        isCanceledByCopyShopLoading: false,
        remainingMinutes: 0.0,
        isTheShoppingButtonBlocked: true,
        homeCanceledOrderStatus: HomeCanceledOrderStatus.idle
      );
}
