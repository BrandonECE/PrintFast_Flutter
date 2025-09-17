import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:printfast_rebuild/domain/entities/entities.dart';
import 'package:printfast_rebuild/domain/repositories/auth_repository.dart';

part 'admin_home_event.dart';
part 'admin_home_state.dart';

class AdminHomeBloc extends Bloc<AdminHomeEvent, AdminHomeState> {
  final AuthRepository authRepository;
  AdminHomeBloc({required this.authRepository}) : super(AdminHomeInitial()) {
    on<AdminHomeChangeIndexBottomNavigationBarEvent>((event, emit) {
      emit(state.copyWith(currentIndex: event.currentIndex));
    });
    on<AdminHomeUpdateSelectedOrderEvent>((event, emit) {
      emit(state.copyWith(selectedOrder: event.selectedOrder));
    });
    on<AdminMonthOrderHistoryElementSelectedEvent>((event, emit) {
      emit(
        state.copyWith(
          monthOrderHistoryElementSelected:
              event.monthOrderHistoryElementSelected,
        ),
      );
    });
    on<AdminHomeUpdateHomeLogOutStatusEvent>((event, emit) {
      emit(state.copyWith(adminHomeLogOutStatus: event.adminHomeLogOutStatus));
    });
  }

  Future<void> signOut() async {
    add(
      AdminHomeUpdateHomeLogOutStatusEvent(
        adminHomeLogOutStatus: AdminHomeLogOutStatus.loading,
        messageError: null,
      ),
    );
    await Future.delayed(Duration(milliseconds: 1000));
    try {
      await authRepository.signOut();
      add(
        AdminHomeUpdateHomeLogOutStatusEvent(
          adminHomeLogOutStatus: AdminHomeLogOutStatus.success,
          messageError: null,
        ),
      );
      add(AdminHomeChangeIndexBottomNavigationBarEvent(currentIndex: 0));
    } catch (e) {
      add(
        AdminHomeUpdateHomeLogOutStatusEvent(
          adminHomeLogOutStatus: AdminHomeLogOutStatus.failure,
          messageError: e.toString(),
        ),
      );
    }
  }
}
