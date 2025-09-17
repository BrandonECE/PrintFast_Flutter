part of 'admin_home_bloc.dart';

enum AdminHomeLogOutStatus { initial, loading, success, failure }

class AdminHomeState extends Equatable {
  const AdminHomeState({
    required this.currentIndex,
    required this.adminHomeLogOutStatus,
    required this.messageError,
    required this.adminRegistration,
    required this.acceptedOrders,
    required this.pendingOrders,
    required this.monthOrderHistoryMap,
    required this.monthOrderHistoryElementSelected,
    required this.selectedOrder,
  });
  final int currentIndex;
  final AdminHomeLogOutStatus adminHomeLogOutStatus;
  final String? messageError;
  final String adminRegistration;
  final List<AorderEntity> acceptedOrders;
  final List<AorderEntity> pendingOrders;
  final Map<String, List<AorderEntity>> monthOrderHistoryMap;
  final Map<String, List<AorderEntity>> monthOrderHistoryElementSelected;
  final AorderEntity selectedOrder;

  AdminHomeState copyWith({
    int? currentIndex,
    AdminHomeLogOutStatus? adminHomeLogOutStatus,
    String? messageError,
    String? adminRegistration,
    List<AorderEntity>? acceptedOrders,
    List<AorderEntity>? pendingOrders,
    Map<String, List<AorderEntity>>? monthOrderHistoryMap,
    Map<String, List<AorderEntity>>? monthOrderHistoryElementSelected,
    AorderEntity? selectedOrder,
  }) {
    return AdminHomeState(
      currentIndex: currentIndex ?? this.currentIndex,
      adminHomeLogOutStatus: adminHomeLogOutStatus ?? this.adminHomeLogOutStatus,
      messageError: messageError ?? this.messageError,
      adminRegistration: adminRegistration ?? this.adminRegistration,
      acceptedOrders: acceptedOrders ?? this.acceptedOrders,
      pendingOrders: pendingOrders ?? this.pendingOrders,
      monthOrderHistoryMap: monthOrderHistoryMap ?? this.monthOrderHistoryMap,
      selectedOrder: selectedOrder ?? this.selectedOrder,
      monthOrderHistoryElementSelected:
          monthOrderHistoryElementSelected ??
          this.monthOrderHistoryElementSelected,
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
    monthOrderHistoryMap,
    selectedOrder,
    monthOrderHistoryElementSelected,
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
        monthOrderHistoryElementSelected: {'Empty': []},
        monthOrderHistoryMap: {
          'Enero - 2025': [AorderEntity.historyOrders[0]],
          'Febrero - 2025': [AorderEntity.historyOrders[1]],
          'Marzo - 2025': [AorderEntity.historyOrders[2]],
        },
        selectedOrder: AorderEntity.aorderEntityExample,
      );
}
