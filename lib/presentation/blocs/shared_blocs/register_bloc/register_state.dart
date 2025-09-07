part of 'register_bloc.dart';

enum RegisterStatus { initial, loading, success, failure }

final class RegisterState extends Equatable {
  const RegisterState({
    required this.viewFirstPassword,
    required this.viewSecondPassword,
    required this.enableButton,
    required this.registerStatus,
    required this.messageError
  });
  final bool viewFirstPassword;
  final bool viewSecondPassword;
  final bool enableButton;
  final RegisterStatus registerStatus;
  final String? messageError;

  RegisterState copyWith({
    bool? viewFirstPassword,
    bool? viewSecondPassword,
    bool? enableButton,
    RegisterStatus? registerStatus,
    String? messageError
  }) {
    return RegisterState(
      viewFirstPassword: viewFirstPassword ?? this.viewFirstPassword,
      viewSecondPassword: viewSecondPassword ?? this.viewSecondPassword,
      enableButton: enableButton ?? this.enableButton,
      registerStatus: registerStatus ?? this.registerStatus,
      messageError: messageError ?? this.messageError
    );
  }

  @override
  List<Object?> get props => [
    viewFirstPassword,
    viewSecondPassword,
    enableButton,
    registerStatus,
    messageError
  ];
}

final class RegisterInitial extends RegisterState {
  const RegisterInitial()
    : super(
        viewFirstPassword: false,
        viewSecondPassword: false,
        enableButton: false,
        registerStatus: RegisterStatus.initial,
        messageError: null
      );
}
