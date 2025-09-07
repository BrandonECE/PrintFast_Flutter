import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'admin_notifications_event.dart';
part 'admin_notifications_state.dart';

class AdminNotificationsBloc extends Bloc<AdminNotificationsEvent, AdminNotificationsState> {
  AdminNotificationsBloc() : super(AdminNotificationsInitial()) {
    on<AdminNotificationsEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
