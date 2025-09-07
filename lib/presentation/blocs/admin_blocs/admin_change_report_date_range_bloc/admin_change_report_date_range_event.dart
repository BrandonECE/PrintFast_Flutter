part of 'admin_change_report_date_range_bloc.dart';

sealed class AdminChangeReportDateRangeEvent extends Equatable {
  const AdminChangeReportDateRangeEvent();

  @override
  List<Object> get props => [];
}


final class AdminShowChangeReportDateRangeEvent extends AdminChangeReportDateRangeEvent{
 const AdminShowChangeReportDateRangeEvent({
    required this.showChangeReportDateRangeBottomSheet,
  });
  final bool showChangeReportDateRangeBottomSheet;

  @override
  List<Object> get props => [showChangeReportDateRangeBottomSheet];
}