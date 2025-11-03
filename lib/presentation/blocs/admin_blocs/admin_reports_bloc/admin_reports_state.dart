part of 'admin_reports_bloc.dart';

enum AdminReportsStatus { loading, success, failure }

class AdminReportsState extends Equatable {
  final AdminReportsStatus status;
  final ReportEntity report;
  final String? errorMessage;

  const AdminReportsState({
    required this.status,
    required this.report,
    required this.errorMessage,
  });

  AdminReportsState copyWith({
    AdminReportsStatus? status,
    ReportEntity? report,
    String? errorMessage,
  }) {
    return AdminReportsState(
      status: status ?? this.status,
      report: report ?? this.report,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, report, errorMessage];
}

class AdminReportsInitial extends AdminReportsState {
  AdminReportsInitial()
      : super(
          status: AdminReportsStatus.loading,
          report: ReportEntity.empty(),
          errorMessage: null,
        );
}