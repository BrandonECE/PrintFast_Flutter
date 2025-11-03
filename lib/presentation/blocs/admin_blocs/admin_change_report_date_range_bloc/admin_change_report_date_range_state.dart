part of 'admin_change_report_date_range_bloc.dart';

class AdminChangeReportDateRangeState extends Equatable {
  final bool showChangeReportDateRangeBottomSheet;
  final List<DateTime?> selectedDateRange;

  const AdminChangeReportDateRangeState({
    required this.showChangeReportDateRangeBottomSheet,
    required this.selectedDateRange,
  });

  AdminChangeReportDateRangeState copyWith({
    bool? showChangeReportDateRangeBottomSheet,
    List<DateTime?>? selectedDateRange,
  }) {
    return AdminChangeReportDateRangeState(
      showChangeReportDateRangeBottomSheet:
          showChangeReportDateRangeBottomSheet ?? this.showChangeReportDateRangeBottomSheet,
      selectedDateRange: selectedDateRange ?? this.selectedDateRange,
    );
  }

  @override
  List<Object> get props => [showChangeReportDateRangeBottomSheet, selectedDateRange];
}

class AdminChangeReportDateRangeInitial extends AdminChangeReportDateRangeState {
  AdminChangeReportDateRangeInitial()
      : super(
          showChangeReportDateRangeBottomSheet: false,
          selectedDateRange: [],
        );
}