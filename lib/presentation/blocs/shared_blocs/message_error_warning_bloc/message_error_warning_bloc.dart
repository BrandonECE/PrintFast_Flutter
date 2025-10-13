import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'message_error_warning_event.dart';
part 'message_error_warning_state.dart';

class MessageErrorWarningBloc
    extends Bloc<MessageErrorWarningEvent, MessageErrorWarningState> {
  MessageErrorWarningBloc() : super(MessageErrorWarningInitial()) {
    on<ShowMessageErrorWarningEvent>((event, emit) {
      emit(
        state.copyWith(showMessageErrorWarning: event.showMessageErrorWarning),
      );
    });

    on<ChangeTitleTextAndButtonEvent>((event, emit) {
      emit(
        state.copyWith(
          title: event.title,
          text: event.text,
          showCancelButton: event.showCancelButton,
        ),
      );
    });
  }
}
