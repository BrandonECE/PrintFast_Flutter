part of 'login_bloc.dart';

sealed class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

final class LoginViewPasswordEvent extends LoginEvent {
  final bool viewPassword;
  const LoginViewPasswordEvent({required this.viewPassword});

  @override
  List<Object> get props => [viewPassword];
}

final class LoginEnableButtonEvent extends LoginEvent {
  final bool enableButton;
  const LoginEnableButtonEvent({required this.enableButton});

  @override
  List<Object> get props => [enableButton];
}

final class LoginChangeLoginStatusEvent extends LoginEvent {
  final LoginStatus loginStatus;
  final String? messageError;
  const LoginChangeLoginStatusEvent({required this.loginStatus, required this.messageError});

  @override
  List<Object?> get props => [loginStatus, messageError];
}



final class LoginUpdateUserEntityEvent extends LoginEvent {
  const LoginUpdateUserEntityEvent({required this.userEntity});
  final UserEntity userEntity;

  @override
  List<Object> get props => [userEntity];
}
