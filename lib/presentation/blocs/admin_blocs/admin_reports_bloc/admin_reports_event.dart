part of 'admin_reports_bloc.dart';

abstract class AdminReportsEvent extends Equatable {
  const AdminReportsEvent();

  @override
  List<Object> get props => [];
}

class LoadAdminReports extends AdminReportsEvent {
  final DateTime startDate;
  final DateTime endDate;

  const LoadAdminReports({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object> get props => [startDate, endDate];
}

class UpdateAdminReportsDateRange extends AdminReportsEvent {
  final DateTime startDate;
  final DateTime endDate;

  const UpdateAdminReportsDateRange({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object> get props => [startDate, endDate];
}