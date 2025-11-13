part of 'admin_home_bloc.dart';

enum AdminHomeLogOutStatus { initial, loading, success, failure }

enum AdminAordersStatus { initial, loading, success, failure }

enum AdminCountNotificationsStatus { idle, loading, success, failure }

enum AdminReceptionStatus {
  initial,
  loading,
  success,
  requestFailure,
  connectionFailure,
}

enum PendingOrderDecision { none, accept, reject }

enum PendingOrderStatus { idle, loading, success, failure }

enum AdminHomeActions {
  none,
  accessPendingOrder, // Para acceder a una orden pendiente
  togglePauseReception, // Para cambiar el valor de pauseReceptionValue
  makePendingOrderDecision, // Para aceptar o rechazar una orden pendiente
  changeDeliveryPendingOrderTime,
  pendingOrderCanceledByUser,

  acceptedOrderCanceledByUser,
  changeDeliveryAcceptedOrderTime,
  accessAcceptedOrder, // Para acceder a una orden aceptada
  printPDF,

  validateCode,
}

enum ArchivingAcceptedOrderAfterBeingCanceledByTheUserStatus {
  idle,
  loading,
  failure,
  success,
}

enum ChangeDeliveryPendingOrderTimeStatus { idle, loading, failure, success }

enum ChangeDeliveryAcceptedOrderTimeStatus { idle, loading, failure, success }

enum CodeValidationStatus {
  idle,
  loading,
  validating,
  failure,
  success,
  invalid,
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
    required this.selectedAceptedOrderCode,
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
    required this.adminHomeActions,
    required this.showDeliveryTimeBottomSheet,
    required this.deliveryTime,
    required this.changeDeliveryPendingOrderTimeStatus,
    required this.changeDeliveryAcceptedOrderTimeStatus,
    required this.archivingAcceptedOrderAfterBeingaCancelledByTheUserStatus,
    required this.wasPendingOrderRejected,
    required this.archivingCountdown,
    required this.showMessageArchiveCanceledOrderByUser,
    required this.enteredPin,
    required this.codeValidationStatus,
    // NUEVOS CAMPOS
    required this.hasActiveOrders,
    required this.progressTick,
  });

  final int currentIndex;
  final AdminHomeLogOutStatus adminHomeLogOutStatus;
  final String? messageError;
  final String adminRegistration;
  final List<AorderEntity> acceptedOrders;
  final List<AorderEntity> pendingOrders;
  final AorderEntity selectedOrder;
  final String selectedPendingOrderCode;
  final String selectedAceptedOrderCode;
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

  final bool showDeliveryTimeBottomSheet;
  final DateTime deliveryTime;
  final ArchivingAcceptedOrderAfterBeingCanceledByTheUserStatus
  archivingAcceptedOrderAfterBeingaCancelledByTheUserStatus;
  final ChangeDeliveryPendingOrderTimeStatus
  changeDeliveryPendingOrderTimeStatus;
  final ChangeDeliveryAcceptedOrderTimeStatus
  changeDeliveryAcceptedOrderTimeStatus;
  final bool wasPendingOrderRejected;
  final int archivingCountdown;
  final bool showMessageArchiveCanceledOrderByUser;
  final CodeValidationStatus codeValidationStatus;
  final String enteredPin;

  // NUEVOS CAMPOS
  final bool hasActiveOrders;
  final int progressTick;

  AdminHomeState copyWith({
    int? currentIndex,
    AdminHomeLogOutStatus? adminHomeLogOutStatus,
    String? messageError,
    String? adminRegistration,
    List<AorderEntity>? acceptedOrders,
    List<AorderEntity>? pendingOrders,
    AorderEntity? selectedOrder,
    String? selectedPendingOrderCode,
    String? selectedAceptedOrderCode,
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
    AdminHomeActions? adminHomeActions,
    bool? showDeliveryTimeBottomSheet,
    DateTime? deliveryTime,
    ChangeDeliveryPendingOrderTimeStatus? changeDeliveryPendingOrderTimeStatus,
    ChangeDeliveryAcceptedOrderTimeStatus?
    changeDeliveryAcceptedOrderTimeStatus,
    ArchivingAcceptedOrderAfterBeingCanceledByTheUserStatus?
    archivingAcceptedOrderAfterBeingaCancelledByTheUserStatus,
    bool? wasPendingOrderRejected,
    int? archivingCountdown,
    bool? showMessageArchiveCanceledOrderByUser,
    String? enteredPin,
    CodeValidationStatus? codeValidationStatus,
    // NUEVOS CAMPOS
    bool? hasActiveOrders,
    int? progressTick,
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
      selectedAceptedOrderCode:
          selectedAceptedOrderCode ?? this.selectedAceptedOrderCode,
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
      adminHomeActions: adminHomeActions ?? this.adminHomeActions,
      showDeliveryTimeBottomSheet:
          showDeliveryTimeBottomSheet ?? this.showDeliveryTimeBottomSheet,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      changeDeliveryPendingOrderTimeStatus:
          changeDeliveryPendingOrderTimeStatus ??
          this.changeDeliveryPendingOrderTimeStatus,
      changeDeliveryAcceptedOrderTimeStatus:
          changeDeliveryAcceptedOrderTimeStatus ??
          this.changeDeliveryAcceptedOrderTimeStatus,
      archivingAcceptedOrderAfterBeingaCancelledByTheUserStatus:
          archivingAcceptedOrderAfterBeingaCancelledByTheUserStatus ??
          this.archivingAcceptedOrderAfterBeingaCancelledByTheUserStatus,
      wasPendingOrderRejected:
          wasPendingOrderRejected ?? this.wasPendingOrderRejected,
      archivingCountdown: archivingCountdown ?? this.archivingCountdown,
      showMessageArchiveCanceledOrderByUser:
          showMessageArchiveCanceledOrderByUser ??
          this.showMessageArchiveCanceledOrderByUser,
      codeValidationStatus: codeValidationStatus ?? this.codeValidationStatus,
      enteredPin: enteredPin ?? this.enteredPin,
      // NUEVOS CAMPOS
      hasActiveOrders: hasActiveOrders ?? this.hasActiveOrders,
      progressTick: progressTick ?? this.progressTick,
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
    selectedAceptedOrderCode,
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
    adminHomeActions,
    showDeliveryTimeBottomSheet,
    deliveryTime,
    changeDeliveryPendingOrderTimeStatus,
    changeDeliveryAcceptedOrderTimeStatus,
    archivingAcceptedOrderAfterBeingaCancelledByTheUserStatus,
    wasPendingOrderRejected,
    archivingCountdown,
    showMessageArchiveCanceledOrderByUser,
    codeValidationStatus,
    enteredPin,
    // NUEVOS CAMPOS
    hasActiveOrders,
    progressTick,
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
        pendingOrders: [],
        selectedOrder: AorderEntity.aorderEntityEmpty,
        selectedPendingOrderCode: AorderEntity.aorderEntityEmpty.orderCode,
        selectedAceptedOrderCode: AorderEntity.aorderEntityEmpty.orderCode,
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
        adminHomeActions: AdminHomeActions.none,
        showDeliveryTimeBottomSheet: false,
        deliveryTime: DateTime.now(),
        changeDeliveryPendingOrderTimeStatus:
            ChangeDeliveryPendingOrderTimeStatus.idle,
        changeDeliveryAcceptedOrderTimeStatus:
            ChangeDeliveryAcceptedOrderTimeStatus.idle,
        archivingAcceptedOrderAfterBeingaCancelledByTheUserStatus:
            ArchivingAcceptedOrderAfterBeingCanceledByTheUserStatus.idle,
        wasPendingOrderRejected: false,
        archivingCountdown: 0,
        showMessageArchiveCanceledOrderByUser: false,
        codeValidationStatus: CodeValidationStatus.idle,
        enteredPin: '',
        // NUEVOS CAMPOS
        hasActiveOrders: false,
        progressTick: 0,
      );
}