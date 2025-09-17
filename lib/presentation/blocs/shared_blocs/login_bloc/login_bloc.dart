import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:printfast_rebuild/domain/repositories/auth_repository.dart';
import 'package:printfast_rebuild/presentation/blocs/shared_blocs/message_error_warning_bloc/message_error_warning_bloc.dart';

import '../../../../domain/entities/entities.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository authRepository;
  String registration = "";
  String password = "";

  LoginBloc({required this.authRepository}) : super(LoginInitial()) {
    on<LoginViewPasswordEvent>((event, emit) {
      emit(state.copyWith(viewPassword: event.viewPassword));
    });
    on<LoginEnableButtonEvent>((event, emit) {
      emit(state.copyWith(enableButton: event.enableButton));
    });

    on<LoginChangeLoginStatusEvent>((event, emit) {
      emit(
        state.copyWith(
          loginStatus: event.loginStatus,
          messageError: event.messageError,
        ),
      );
    });

    on<LoginUpdateUserEntityEvent>((event, emit) {
      emit(state.copyWith(userEntity: event.userEntity));
    });
  }

  void registrationChanged(String value) {
    registration = value;
    willTheButtonBeEnabled();
  }

  void passwordChanged(String value) {
    password = value;
    willTheButtonBeEnabled();
  }

  void willTheButtonBeEnabled() {
    final bool condition = registration.length >= 7 && password.length >= 3;
    add(LoginEnableButtonEvent(enableButton: condition));
  }

  Future<void> signIn() async {

    add( LoginChangeLoginStatusEvent( loginStatus: LoginStatus.loading, messageError: null, ), );
    await Future.delayed(Duration(milliseconds: 1500));

    try {
      final UserEntity userEntity = await authRepository.signInAndGetUser( registration: registration, password: password, );
      add(LoginUpdateUserEntityEvent(userEntity: userEntity));
      add(LoginChangeLoginStatusEvent( loginStatus: LoginStatus.success, messageError: null, ), );
    } catch (e) {
      add( LoginChangeLoginStatusEvent( loginStatus: LoginStatus.failure, messageError: e.toString(), ), );
    }
  }

  void reset() {
    registration = "";
    password = "";
    add(LoginViewPasswordEvent(viewPassword: false));
    add(LoginEnableButtonEvent(enableButton: false));
  }
}
