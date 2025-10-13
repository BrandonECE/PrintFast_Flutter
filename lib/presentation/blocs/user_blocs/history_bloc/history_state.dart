// lib/presentation/blocs/user_blocs/history_bloc/history_state.dart
part of 'history_bloc.dart';

enum HistoryStatus { loading, success, failure }

class HistoryState extends Equatable {
  final HistoryStatus status;
  final List<HorderEntity> historyOrders;
  final HorderEntity selectedOrder;
  final String? errorMessage;

  const HistoryState({
    required this.status,
    required this.historyOrders,
    required this.selectedOrder,
    required this.errorMessage,
  });

  HistoryState copyWith({
    HistoryStatus? status,
    List<HorderEntity>? historyOrders,
    HorderEntity? selectedOrder,
    String? errorMessage,
  }) {
    return HistoryState(
      status: status ?? this.status,
      historyOrders: historyOrders ?? this.historyOrders,
      selectedOrder: selectedOrder ?? this.selectedOrder,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, historyOrders, selectedOrder, errorMessage];
}

class HistoryInitial extends HistoryState {
  HistoryInitial() : super(
    status: HistoryStatus.loading,
    historyOrders: const [],
    selectedOrder: HorderEntity.empty,
    errorMessage: null,
  );
}