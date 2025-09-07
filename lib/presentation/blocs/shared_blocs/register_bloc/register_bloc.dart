import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:printfast_rebuild/domain/entities/entities.dart';
import 'package:printfast_rebuild/domain/repositories/auth_repository.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  String nameAndSurname = "";
  String registration = "";
  String email = "";
  String phone = "";
  String firstPassword = "";
  String secondPassword = "";
  final AuthRepository authRepository;

  RegisterBloc({required this.authRepository}) : super(RegisterInitial()) {
    on<RegisterViewFirstPasswordEvent>((event, emit) {
      emit(state.copyWith(viewFirstPassword: event.viewFirstPassword));
    });

    on<RegisterViewSecondPasswordEvent>((event, emit) {
      emit(state.copyWith(viewSecondPassword: event.viewSecondPassword));
    });

    on<RegisterEnableButtonEvent>((event, emit) {
      emit(state.copyWith(enableButton: event.enableButton));
    });

    on<RegisterChangeRegisterStatusEvent>((event, emit) {
      emit(
        state.copyWith(
          registerStatus: event.registerStatus,
          messageError: event.messageError,
        ),
      );
    });
  }

  void nameAndSurnameChanged(String value) {
    nameAndSurname = value;
    willTheButtonBeEnabled();
  }

  void registrationChanged(String value) {
    registration = value;
    willTheButtonBeEnabled();
  }

  void emailChanged(String value) {
    email = value;
    willTheButtonBeEnabled();
  }

  void phoneChanged(String value) {
    phone = value;
    willTheButtonBeEnabled();
  }

  void firstPasswordChanged(String value) {
    firstPassword = value;
    willTheButtonBeEnabled();
  }

  void secondPasswordChanged(String value) {
    secondPassword = value;
    willTheButtonBeEnabled();
  }

  void willTheButtonBeEnabled() {
    // 1) Nombre y apellido (al menos 2 palabras). Normalizamos espacios y capitalizamos.
    final rawName = nameAndSurname.trim();
    final parts = rawName
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .toList();

    bool validName = false;
    if (parts.length >= 2) {
      // Formatear a Title Case: "brandon cantu" -> "Brandon Cantu"
      final formatted = parts
          .map(
            (p) =>
                p.substring(0, 1).toUpperCase() + p.substring(1).toLowerCase(),
          )
          .join(' ');
      // Reasignamos la variable con la versión formateada
      nameAndSurname = formatted;
      validName = true;
    }

    // 2) Registration: mínimo 7 caracteres (sin espacios al inicio/fin)
    final validRegistration = registration.trim().length >= 7;

    // 3) Email: contiene @gmail.com (insensible a mayúsculas)
    final validEmail = email.trim().toLowerCase().contains('@gmail.com');

    // 4) Phone: contar solo dígitos; mínimo definido (ej. 10)
    final phoneDigits = phone.replaceAll(RegExp(r'\D'), '');
    const int minPhoneDigits = 10; // cambia si quieres otro mínimo
    final validPhone = phoneDigits.length >= minPhoneDigits;

    // 5) Passwords: > 3 caracteres y coinciden
    final validPasswords =
        firstPassword.length >= 3 && firstPassword == secondPassword;

    // Condición final
    final bool condition =
        validName &&
        validRegistration &&
        validEmail &&
        validPhone &&
        validPasswords;

    add(RegisterEnableButtonEvent(enableButton: condition));
  }

  Future<void> register() async {
    add(
      RegisterChangeRegisterStatusEvent(
        registerStatus: RegisterStatus.loading,
        messageError: null,
      ),
    );

    await Future.delayed(Duration(milliseconds: 1500));

    try {
      await authRepository.register(
        UserEntity(
          email: email,
          name: nameAndSurname,
          phone: phone,
          registration: registration,
          password: firstPassword
        ),
      );

      add(
        RegisterChangeRegisterStatusEvent(
          registerStatus: RegisterStatus.success,
          messageError: null,
        ),
      );
    } catch (e) {
      print(e);
      add(
        RegisterChangeRegisterStatusEvent(
          registerStatus: RegisterStatus.failure,
          messageError: e.toString(),
        ),
      );
    }
  }

  void reset() {
    nameAndSurname = "";
    registration = "";
    email = "";
    phone = "";
    firstPassword = "";
    secondPassword = "";
    add(RegisterViewFirstPasswordEvent(viewFirstPassword: false));
    add(RegisterViewSecondPasswordEvent(viewSecondPassword: false));
    add(RegisterEnableButtonEvent(enableButton: false));
  }
}
