import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'message_error_warning_event.dart';
part 'message_error_warning_state.dart';

class MessageErrorWarningBloc
    extends Bloc<MessageErrorWarningEvent, MessageErrorWarningState> {
  String title = "¡Error inesperado!";
  String message = "Aquí va tu mensaje de error";

  MessageErrorWarningBloc() : super(MessageErrorWarningInitial()) {
    on<ShowMessageErrorWarningEvent>((event, emit) {
      emit(
        state.copyWith(showMessageErrorWarning: event.showMessageErrorWarning),
      );
    });
  }

  void updateMessageErrorWarning(String newTitle, String newMessage) {
    title = newTitle;
    message = newMessage;
  }
}
