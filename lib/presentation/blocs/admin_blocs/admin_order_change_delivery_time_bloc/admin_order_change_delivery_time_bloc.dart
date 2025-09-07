import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'admin_order_change_delivery_time_event.dart';
part 'admin_order_change_delivery_time_state.dart';

class AdminOrderChangeDeliveryTimeBloc
    extends
        Bloc<
          AdminOrderChangeDeliveryTimeEvent,
          AdminOrderChangeDeliveryTimeState
        > {
  AdminOrderChangeDeliveryTimeBloc()
    : super(AdminOrderChangeDeliveryTimeInitial()) {
    on<AdminOrderShowChangeDeliveryTimeEvent>((event, emit) {
      emit(
        state.copyWith(
          showDeliveryTimeBottomSheet: event.showDeliveryTimeBottomSheet
        ),
      );
    });
  }
}
