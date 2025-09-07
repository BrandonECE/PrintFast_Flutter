part of 'admin_change_report_date_range_bloc.dart';

final class AdminChangeReportDateRangeState extends Equatable {
  const AdminChangeReportDateRangeState({
    required this.showChangeReportDateRangeBottomSheet,
  });
  final bool showChangeReportDateRangeBottomSheet;

  AdminChangeReportDateRangeState copyWith({bool? showChangeReportDateRangeBottomSheet,}) {
    return AdminChangeReportDateRangeState(
      showChangeReportDateRangeBottomSheet:
         showChangeReportDateRangeBottomSheet ?? this.showChangeReportDateRangeBottomSheet,
    );
  }

  @override
  List<Object> get props => [showChangeReportDateRangeBottomSheet];
}

final class AdminChangeReportDateRangeInitial extends AdminChangeReportDateRangeState {
      const AdminChangeReportDateRangeInitial() : super(showChangeReportDateRangeBottomSheet: false);
}
