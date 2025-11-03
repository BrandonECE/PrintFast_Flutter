part of 'admin_home_bloc.dart';

enum AdminHomeLogOutStatus { initial, loading, success, failure }

enum AdminAordersStatus { initial, loading, success, failure }

enum AdminCountNotificationsStatus { idle, loading, success, failure }

enum AdminReceptionStatus { initial, loading, success, requestFailure, connectionFailure, }
enum PendingOrderDecision { none, accept, reject }

enum PendingOrderStatus { idle, loading, success, failure }

enum AdminHomeActions {
  none,
  accessPendingOrder, // Para acceder a una orden pendiente
  togglePauseReception, // Para cambiar el valor de pauseReceptionValue
  makePendingOrderDecision, // Para aceptar o rechazar una orden pendiente

  accessAcceptedOrder, // Para acceder a una orden aceptada
  printPDF,
}

class AdminHomeState extends Equatable {
  const AdminHomeState({
    required this.currentIndex,
    required this.adminHomeLogOutStatus,
    required this.messageError,
    required this.adminRegistration,
    required this.acceptedOrders,
    required this.pendingOrders,
    required this.selectedOrder,
    required this.selectedPendingOrderCode,
    required this.userEntity,
    required this.copyShopEntity,
    required this.adminAordersStatus,
    required this.unseenNotificationsCount,
    required this.notificationsStatus,
    required this.notificationsErrorMessage,
    required this.receptionStatus,
    required this.receptionErrorMessage,
    required this.pendingOrderDecision,
    required this.pendingOrderStatus,
    required this.pendingOrderErrorMessage,
    required this.adminHomeActions
  });

  final int currentIndex;
  final AdminHomeLogOutStatus adminHomeLogOutStatus;
  final String? messageError;
  final String adminRegistration;
  final List<AorderEntity> acceptedOrders;
  final List<AorderEntity> pendingOrders;
  final AorderEntity selectedOrder;
  final String selectedPendingOrderCode;
  final UserEntity userEntity;
  final CopyShopEntity copyShopEntity;
  final AdminAordersStatus adminAordersStatus;
  final int unseenNotificationsCount;
  final AdminCountNotificationsStatus notificationsStatus;
  final String? notificationsErrorMessage;
  final AdminReceptionStatus receptionStatus;
  final String? receptionErrorMessage;
  final PendingOrderDecision pendingOrderDecision;
  final PendingOrderStatus pendingOrderStatus;
  final String? pendingOrderErrorMessage;
  final AdminHomeActions adminHomeActions;

  AdminHomeState copyWith({
    int? currentIndex,
    AdminHomeLogOutStatus? adminHomeLogOutStatus,
    String? messageError,
    String? adminRegistration,
    List<AorderEntity>? acceptedOrders,
    List<AorderEntity>? pendingOrders,
    AorderEntity? selectedOrder,
    String? selectedPendingOrderCode,
    UserEntity? userEntity,
    CopyShopEntity? copyShopEntity,
    AdminAordersStatus? adminAordersStatus,
    int? unseenNotificationsCount,
    AdminCountNotificationsStatus? notificationsStatus,
    String? notificationsErrorMessage,
    AdminReceptionStatus? receptionStatus,
    String? receptionErrorMessage,
    PendingOrderDecision? pendingOrderDecision,
    PendingOrderStatus? pendingOrderStatus,
    String? pendingOrderErrorMessage,
    AdminHomeActions? adminHomeActions
  }) {
    return AdminHomeState(
      currentIndex: currentIndex ?? this.currentIndex,
      adminHomeLogOutStatus:
          adminHomeLogOutStatus ?? this.adminHomeLogOutStatus,
      messageError: messageError ?? this.messageError,
      adminRegistration: adminRegistration ?? this.adminRegistration,
      acceptedOrders: acceptedOrders ?? this.acceptedOrders,
      pendingOrders: pendingOrders ?? this.pendingOrders,
      selectedOrder: selectedOrder ?? this.selectedOrder,
      selectedPendingOrderCode:
          selectedPendingOrderCode ?? this.selectedPendingOrderCode,
      userEntity: userEntity ?? this.userEntity,
      copyShopEntity: copyShopEntity ?? this.copyShopEntity,
      adminAordersStatus: adminAordersStatus ?? this.adminAordersStatus,
      unseenNotificationsCount:
          unseenNotificationsCount ?? this.unseenNotificationsCount,
      notificationsStatus: notificationsStatus ?? this.notificationsStatus,
      notificationsErrorMessage:
          notificationsErrorMessage ?? this.notificationsErrorMessage,
      receptionStatus: receptionStatus ?? this.receptionStatus,
      receptionErrorMessage:
          receptionErrorMessage ?? this.receptionErrorMessage,
      pendingOrderDecision: pendingOrderDecision ?? this.pendingOrderDecision,
      pendingOrderStatus: pendingOrderStatus ?? this.pendingOrderStatus,
      pendingOrderErrorMessage:
          pendingOrderErrorMessage ?? this.pendingOrderErrorMessage,
      adminHomeActions: adminHomeActions ?? this.adminHomeActions
    );
  }

  @override
  List<Object?> get props => [
    currentIndex,
    adminHomeLogOutStatus,
    messageError,
    adminRegistration,
    acceptedOrders,
    pendingOrders,
    selectedOrder,
    selectedPendingOrderCode,
    userEntity,
    copyShopEntity,
    adminAordersStatus,
    unseenNotificationsCount,
    notificationsStatus,
    notificationsErrorMessage,
    receptionStatus,
    receptionErrorMessage,
    pendingOrderDecision,
    pendingOrderStatus,
    pendingOrderErrorMessage,
    adminHomeActions
  ];
}

final class AdminHomeInitial extends AdminHomeState {
  AdminHomeInitial()
    : super(
        currentIndex: 0,
        adminHomeLogOutStatus: AdminHomeLogOutStatus.initial,
        messageError: null,
        adminRegistration: "-------",
        acceptedOrders: AorderEntity.acceptedOrdersExample,
        pendingOrders: AorderEntity.pendingOrders,
        selectedOrder: AorderEntity.aorderEntityEmpty,
        selectedPendingOrderCode: AorderEntity.aorderEntityEmpty.orderCode,
        userEntity: UserEntity.defaultAdminValues,
        copyShopEntity: CopyShopEntity.defaultCopyShopValues,
        adminAordersStatus: AdminAordersStatus.initial,
        unseenNotificationsCount: 0,
        notificationsStatus: AdminCountNotificationsStatus.idle,
        notificationsErrorMessage: null,
        receptionStatus: AdminReceptionStatus.initial,
        receptionErrorMessage: null,
        pendingOrderDecision: PendingOrderDecision.none,
        pendingOrderStatus: PendingOrderStatus.idle,
        pendingOrderErrorMessage: null,
        adminHomeActions: AdminHomeActions.none
      );
}
