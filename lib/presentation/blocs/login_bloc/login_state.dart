part of 'login_bloc.dart';

enum LoginStatus { initial, loading, success, failure }

final class LoginState extends Equatable {
  const LoginState({required this.viewPassword, required this.enableButton, required this.loginStatus, required this.messageError, required this.userEntity});
  final LoginStatus loginStatus;
  final bool viewPassword;
  final bool enableButton;
  final String? messageError;
  final UserEntity? userEntity;

  LoginState copyWith({bool? viewPassword, bool? enableButton, LoginStatus? loginStatus, String? messageError, UserEntity? userEntity}) {
    return LoginState(
      viewPassword: viewPassword ?? this.viewPassword,
      enableButton: enableButton ?? this.enableButton,
      loginStatus: loginStatus ?? this.loginStatus,
      messageError:  messageError ?? this.messageError,
      userEntity:  userEntity ?? this. userEntity
    );
  }

  @override
  List<Object?> get props => [viewPassword, enableButton, loginStatus, messageError,  userEntity];
}

final class LoginInitial extends LoginState {
  const LoginInitial() : super(viewPassword: false, enableButton: false, loginStatus: LoginStatus.initial, messageError: null, userEntity: null);
}
