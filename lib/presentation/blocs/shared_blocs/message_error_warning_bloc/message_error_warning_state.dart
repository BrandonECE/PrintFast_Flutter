part of 'message_error_warning_bloc.dart';

final class MessageErrorWarningState extends Equatable {
  const MessageErrorWarningState({required this.showMessageErrorWarning});
  final bool showMessageErrorWarning;

  MessageErrorWarningState copyWith({bool? showMessageErrorWarning}) {
    return MessageErrorWarningState(
      showMessageErrorWarning:
          showMessageErrorWarning ?? this.showMessageErrorWarning,
    );
  }

  @override
  List<Object> get props => [showMessageErrorWarning];
}

final class MessageErrorWarningInitial extends MessageErrorWarningState {
  const MessageErrorWarningInitial() : super(showMessageErrorWarning: false);
}
