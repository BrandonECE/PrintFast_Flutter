part of 'message_error_warning_bloc.dart';

sealed class MessageErrorWarningEvent extends Equatable {
  const MessageErrorWarningEvent();

  @override
  List<Object> get props => [];
}


final class ShowMessageErrorWarningEvent extends MessageErrorWarningEvent {
  const ShowMessageErrorWarningEvent({required this.showMessageErrorWarning});
  final bool showMessageErrorWarning;

  @override
  List<Object> get props => [showMessageErrorWarning];
}