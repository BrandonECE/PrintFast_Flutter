part of 'message_error_warning_bloc.dart';

final class MessageErrorWarningState extends Equatable {
  const MessageErrorWarningState({
    required this.showMessageErrorWarning,
    required this.title,
    required this.text,
    required this.showCancelButton
  });
  final bool showMessageErrorWarning;
  final String title;
  final String text;
  final bool showCancelButton;

  MessageErrorWarningState copyWith({
    bool? showMessageErrorWarning,
    String? title,
    String? text,
    bool? showCancelButton
  }) {
    return MessageErrorWarningState(
      showMessageErrorWarning:
          showMessageErrorWarning ?? this.showMessageErrorWarning,
      title: title ?? this.title,
      text: text ?? this.text,
      showCancelButton: showCancelButton ?? this.showCancelButton

    );
  }

  @override
  List<Object> get props => [showMessageErrorWarning, title, text, showCancelButton];
}

final class MessageErrorWarningInitial extends MessageErrorWarningState {
  const MessageErrorWarningInitial()
    : super(showMessageErrorWarning: false, title: "SnackBar", text: "message", showCancelButton: false);
}
