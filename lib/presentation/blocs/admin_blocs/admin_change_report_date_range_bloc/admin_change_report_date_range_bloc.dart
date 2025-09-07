import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'admin_change_report_date_range_event.dart';
part 'admin_change_report_date_range_state.dart';

class AdminChangeReportDateRangeBloc extends Bloc<AdminChangeReportDateRangeEvent, AdminChangeReportDateRangeState> {
  AdminChangeReportDateRangeBloc() : super(AdminChangeReportDateRangeInitial()) {
    on<AdminShowChangeReportDateRangeEvent>((event, emit) {
      emit(
        state.copyWith(
          showChangeReportDateRangeBottomSheet: event.showChangeReportDateRangeBottomSheet
        ),
      );
    });
  }
}
