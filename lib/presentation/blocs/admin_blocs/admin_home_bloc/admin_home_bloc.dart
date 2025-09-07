import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:printfast_rebuild/domain/entities/entities.dart';

part 'admin_home_event.dart';
part 'admin_home_state.dart';

class AdminHomeBloc extends Bloc<AdminHomeEvent, AdminHomeState> {
  AdminHomeBloc() : super(AdminHomeInitial()) {
    on<AdminHomeChangeIndexBottomNavigationBarEvent>((event, emit) {
      emit(state.copyWith(currentIndex: event.currentIndex));
    });
   on<AdminHomeUpdateSelectedOrderEvent>((event, emit) {
      emit(state.copyWith(selectedOrder: event.selectedOrder));
    });
   on<AdminMonthOrderHistoryElementSelectedEvent>((event, emit) {
      emit(state.copyWith(monthOrderHistoryElementSelected: event.monthOrderHistoryElementSelected));
    });
  }
}
