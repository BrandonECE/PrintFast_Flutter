import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/shared_blocs/message_error_warning_bloc/message_error_warning_bloc.dart';

void showSnackBar({
  required BuildContext context,
  String title = "",
  String text = "",
  bool showCancelButton = false,
}) {
  final messageErrorWarningBloc = context.read<MessageErrorWarningBloc>();
  messageErrorWarningBloc.add(
    ChangeTitleTextAndButtonEvent(
      title: title,
      text: text,
      showCancelButton: showCancelButton,
    ),
  );
  messageErrorWarningBloc.add(
    const ShowMessageErrorWarningEvent(showMessageErrorWarning: true),
  );
}
