part of 'admin_history_bloc.dart';

enum AdminHistoryStatus { loading, success, failure }

class AdminHistoryState extends Equatable {
  final AdminHistoryStatus status;
  final List<HorderEntity> historyOrders;
  final HorderEntity selectedOrder;
  final String? errorMessage;
  final Map<String, List<HorderEntity>> monthOrderHistoryMap;
  final Map<String, List<HorderEntity>> monthOrderHistoryElementSelected;

  const AdminHistoryState({
    required this.status,
    required this.historyOrders,
    required this.selectedOrder,
    required this.errorMessage,
    required this.monthOrderHistoryMap,
    required this.monthOrderHistoryElementSelected,
  });

  AdminHistoryState copyWith({
    AdminHistoryStatus? status,
    List<HorderEntity>? historyOrders,
    HorderEntity? selectedOrder,
    String? errorMessage,
    Map<String, List<HorderEntity>>? monthOrderHistoryMap,
    Map<String, List<HorderEntity>>? monthOrderHistoryElementSelected,
  }) {
    return AdminHistoryState(
      status: status ?? this.status,
      historyOrders: historyOrders ?? this.historyOrders,
      selectedOrder: selectedOrder ?? this.selectedOrder,
      errorMessage: errorMessage ?? this.errorMessage,
      monthOrderHistoryMap: monthOrderHistoryMap ?? this.monthOrderHistoryMap,
      monthOrderHistoryElementSelected: monthOrderHistoryElementSelected ?? this.monthOrderHistoryElementSelected,
    );
  }

  @override
  List<Object?> get props => [
    status, 
    historyOrders, 
    selectedOrder, 
    errorMessage, 
    monthOrderHistoryMap,
    monthOrderHistoryElementSelected,
  ];
}

class AdminHistoryInitial extends AdminHistoryState {
  AdminHistoryInitial()
      : super(
          status: AdminHistoryStatus.loading,
          historyOrders: const [],
          selectedOrder: HorderEntity.empty,
          errorMessage: null,
          monthOrderHistoryMap: {},
          monthOrderHistoryElementSelected: {},
        );
}