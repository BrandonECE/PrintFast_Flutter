import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:printfast_rebuild/config/routes/routes.dart';
import 'package:printfast_rebuild/presentation/blocs/user_blocs/home_bloc/home_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/shared_blocs/login_bloc/login_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/shared_blocs/message_error_warning_bloc/message_error_warning_bloc.dart';
import 'package:printfast_rebuild/presentation/widgets/widgets.dart';

class MyLoginView extends StatelessWidget {
  const MyLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;
    final loginBloc = context.read<LoginBloc>();
    final homeBloc = context.read<HomeBloc>();
    final messageErrorWarningBloc = context.read<MessageErrorWarningBloc>();

    void goToRegisterScreen() {
      if (loginBloc.state.loginStatus != LoginStatus.loading &&
          loginBloc.state.loginStatus != LoginStatus.success) {
        FocusManager.instance.primaryFocus?.unfocus();
        context.go(Routes.register);
        loginBloc.reset();
      }
    }

    void signIn() async {
      if (loginBloc.state.loginStatus != LoginStatus.loading &&
          loginBloc.state.loginStatus != LoginStatus.success) {
        FocusManager.instance.primaryFocus?.unfocus();
        await loginBloc.signIn();
      }
    }

    void goToHomeScreen(
      HomeBloc homeBloc,
      LoginState state,
      BuildContext context,
      LoginBloc loginBloc,
    ) {
      homeBloc.add(HomeUpdateUserEntityEvent(userEntity: state.userEntity!));
      context.go(Routes.home);
      loginBloc.reset();
      loginBloc.add(
        LoginChangeLoginStatusEvent(
          loginStatus: LoginStatus.initial,
          messageError: null,
        ),
      );
    }

    void thereWasAnError(
      MessageErrorWarningBloc messageErrorWarningBloc,
      LoginState state,
      LoginBloc loginBloc,
    ) {
      messageErrorWarningBloc.updateMessageErrorWarning(
        "¡Error inesperado!",
        state.messageError ?? "",
      );
      messageErrorWarningBloc.add(
        ShowMessageErrorWarningEvent(showMessageErrorWarning: true),
      );
      loginBloc.add(
        LoginChangeLoginStatusEvent(
          loginStatus: LoginStatus.initial,
          messageError: null,
        ),
      );
    }

    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.loginStatus == LoginStatus.success) {
          goToHomeScreen(homeBloc, state, context, loginBloc);
        }

        if (state.loginStatus == LoginStatus.failure) {
          thereWasAnError(messageErrorWarningBloc, state, loginBloc);
        }
      },
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          return Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: myLoginScreen(
                  context,
                  primaryColor,
                  loginBloc,
                  state,
                  signIn,
                  onPrimaryColor,
                  goToRegisterScreen,
                ),
              ),
              MyMessageErrorWarning(voidCallback: () => messageErrorWarningBloc.add(
              ShowMessageErrorWarningEvent(showMessageErrorWarning: false),),),
            ],
          );
        },
      ),
    );
  }

  Scaffold myLoginScreen(
    BuildContext context,
    Color primaryColor,
    LoginBloc loginBloc,
    LoginState state,
    void Function() goToHomeScreen,
    Color onPrimaryColor,
    void Function() goToRegisterScreen,
  ) {
    return Scaffold(
      appBar: _appBar(context),
      backgroundColor: primaryColor,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(height: 40),
              Column(
                children: [
                  _buildLogoSection(),
                  const SizedBox(height: 40),
                  _buildWelcomeRow(),
                  const SizedBox(height: 30),

                  // Campos de texto
                  _buildTextField(
                    context: context,
                    hintText: 'Matrícula',
                    prefixIcon: Icons.lock,
                    keyboardType: TextInputType.number,
                    onChanged: (value) => loginBloc.registrationChanged(value),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    context: context,
                    hintText: 'Contraseña',
                    prefixIcon: Icons.person,
                    suffixIcon: !state.viewPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                    obscureText: !state.viewPassword,
                    keyboardType: TextInputType.text,
                    onPressedSufix: () => loginBloc.add(
                      LoginViewPasswordEvent(viewPassword: !state.viewPassword),
                    ),
                    onChanged: (value) => loginBloc.passwordChanged(value),
                  ),
                  const SizedBox(height: 48),

                  // Botones
                  _buildButton(
                    context: context,
                    widget: _animatedSwitcherButton(state, primaryColor),
                    onPressed: state.enableButton
                        ? () => goToHomeScreen()
                        : null,
                    backgroundColor: Colors.white,
                    textColor: primaryColor,
                    borderRadius: 40,
                  ),
                  const SizedBox(height: 10),
                  _buildButton(
                    context: context,
                    widget: Text(
                      'Registrarse',
                      style: TextStyle(
                        color: onPrimaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    onPressed: () => goToRegisterScreen(),
                    backgroundColor: primaryColor,
                    textColor: onPrimaryColor,
                    borderRadius: 10,
                  ),
                  const SizedBox(height: 60),
                ],
              ),
              const SizedBox(height: 29),
              _buildBottom(context),
            ],
          ),
        ),
      ),
    );
  }

  AnimatedSwitcher _animatedSwitcherButton(
    LoginState state,
    Color primaryColor,
  ) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      transitionBuilder: (child, animation) {
        // Fade + tiny scale for a snappy feeling
        final fade = FadeTransition(opacity: animation, child: child);
        final scale = ScaleTransition(
          scale: Tween<double>(
            begin: 0.97,
            end: 1.0,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: fade,
        );
        return scale;
      },
      child: state.loginStatus != LoginStatus.loading
          ? Text(
              'Iniciar sesión',
              key: const ValueKey('login_text'),
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            )
          : SizedBox(
              key: const ValueKey('login_loader'),
              child: MyLoadingIndicator(
                size: 65,
                key: ValueKey('login_loader'),
              ),
            ),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      actions: [
        IconButton(
          onPressed: null,
          icon: Icon(Icons.help_outline, color: Colors.white),
        ),
      ],
    );
  }

  // Widget para el logo y nombre
  Widget _buildLogoSection() {
    return Column(
      children: [
        SizedBox(
          width: 90,
          height: 90,
          child: Image.asset('assets/images/printfast_logoLogin.png'),
        ),
        const SizedBox(height: 8),
        const Text(
          'PrintFast',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
      ],
    );
  }

  // Widget para el texto de bienvenida
  Widget _buildWelcomeRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Text(
          'BIENVENIDO',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        SizedBox(width: 8),
        Icon(Icons.waving_hand_rounded, color: Colors.white),
      ],
    );
  }

  // Widget para el TextField personalizado
  Widget _buildTextField({
    required BuildContext context,
    required String hintText,
    IconData? prefixIcon,
    IconData? suffixIcon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    void Function(String value)? onChanged,
    void Function()? onPressedSufix,
  }) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: TextField(
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 16,
          ),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: primaryColor)
              : null,
          suffixIcon: suffixIcon != null
              ? IconButton(
                  onPressed: onPressedSufix,
                  icon: Icon(suffixIcon, color: primaryColor),
                )
              : null,
          hintText: hintText,
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }

  // Widget para botones
  Widget _buildButton({
    required BuildContext context,
    required Widget widget,
    required VoidCallback? onPressed,
    required Color backgroundColor,
    required Color textColor,
    double borderRadius = 40,
    double height = 56,
  }) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          disabledBackgroundColor: backgroundColor.withOpacity(0.71),
          foregroundColor: textColor.withOpacity(0.71),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          backgroundColor: backgroundColor,
        ),
        child: widget,
      ),
    );
  }

  Widget _buildBottom(BuildContext context) {
    return Column(
      children: [
        Text(
          'Universidad Autónoma de Nuevo León',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        SizedBox(height: 30),
      ],
    );
  }
}
