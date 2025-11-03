part of 'admin_history_bloc.dart';

abstract class AdminHistoryEvent extends Equatable {
  const AdminHistoryEvent();

  @override
  List<Object> get props => [];
}

class LoadAdminHistory extends AdminHistoryEvent {}

class SelectAdminHistoryOrder extends AdminHistoryEvent {
  final HorderEntity order;
  const SelectAdminHistoryOrder({required this.order});

  @override
  List<Object> get props => [order];
}

class ClearSelectedAdminHistoryOrder extends AdminHistoryEvent {}

class AdminMonthOrderHistoryElementSelectedEvent extends AdminHistoryEvent {
  const AdminMonthOrderHistoryElementSelectedEvent({required this.monthOrderHistoryElementSelected});
  final Map<String, List<HorderEntity>> monthOrderHistoryElementSelected;

  @override
  List<Object> get props => [monthOrderHistoryElementSelected];
}