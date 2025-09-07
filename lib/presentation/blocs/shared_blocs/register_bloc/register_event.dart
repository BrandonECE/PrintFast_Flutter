part of 'register_bloc.dart';

sealed class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object?> get props => [];
}

final class RegisterViewFirstPasswordEvent extends RegisterEvent {
  final bool viewFirstPassword;
  const RegisterViewFirstPasswordEvent({required this.viewFirstPassword});

  @override
  List<Object> get props => [viewFirstPassword];
}

final class RegisterViewSecondPasswordEvent extends RegisterEvent {
  final bool viewSecondPassword;
  const RegisterViewSecondPasswordEvent({required this.viewSecondPassword});

  @override
  List<Object> get props => [viewSecondPassword];
}

final class RegisterEnableButtonEvent extends RegisterEvent {
  final bool enableButton;
  const RegisterEnableButtonEvent({required this.enableButton});

  @override
  List<Object> get props => [enableButton];
}

final class RegisterChangeRegisterStatusEvent extends RegisterEvent {
  final RegisterStatus registerStatus;
  final String? messageError;
  const RegisterChangeRegisterStatusEvent({
    required this.registerStatus,
    required this.messageError,
  });

  @override
  List<Object?> get props => [registerStatus, messageError];
}
