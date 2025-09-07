import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:printfast_rebuild/config/routes/routes.dart';
import 'package:printfast_rebuild/presentation/blocs/shared_blocs/message_error_warning_bloc/message_error_warning_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/shared_blocs/register_bloc/register_bloc.dart';
import 'package:printfast_rebuild/presentation/widgets/widgets.dart';

class MyRegisterView extends StatelessWidget {
  const MyRegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final registerBloc = context.read<RegisterBloc>();
    final messageErrorWarningBloc = context.read<MessageErrorWarningBloc>();

    // final onPrimary = Theme.of(context).colorScheme.onPrimary;

    void register() async {
      if (registerBloc.state.registerStatus != RegisterStatus.loading &&
          registerBloc.state.registerStatus != RegisterStatus.success) {
        FocusManager.instance.primaryFocus?.unfocus();
        await registerBloc.register();
      }
    }

    void goToLoginScreen(BuildContext context, RegisterBloc registerBloc) {
      context.go(Routes.login);
      registerBloc.reset();
      registerBloc.add(
        RegisterChangeRegisterStatusEvent(
          registerStatus: RegisterStatus.initial,
          messageError: null,
        ),
      );
    }

    void thereWasAnError(
      MessageErrorWarningBloc messageErrorWarningBloc,
      RegisterState state,
      RegisterBloc registerBloc,
    ) {
      messageErrorWarningBloc.updateMessageErrorWarning(
        "¡Error inesperado!",
        state.messageError ?? "",
      );
      messageErrorWarningBloc.add(
        ShowMessageErrorWarningEvent(showMessageErrorWarning: true),
      );
      registerBloc.add(
        RegisterChangeRegisterStatusEvent(
          registerStatus: RegisterStatus.initial,
          messageError: null,
        ),
      );
    }

    return BlocListener<RegisterBloc, RegisterState>(
      listener: (context, state) {
        if (state.registerStatus == RegisterStatus.success) {
          goToLoginScreen(context, registerBloc);
        }

        if (state.registerStatus == RegisterStatus.failure) {
          thereWasAnError(messageErrorWarningBloc, state, registerBloc);
        }
      },
      child: BlocBuilder<RegisterBloc, RegisterState>(
        builder: (context, state) {
          return Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: myRegisterScreen(
                  context,
                  primary,
                  state,
                  register,
                  registerBloc,
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

  Scaffold myRegisterScreen(
    BuildContext context,
    Color primary,
    RegisterState state,
    VoidCallback callBack,
    RegisterBloc registerBloc,
  ) {
    return Scaffold(
      appBar: _appBar(context),
      backgroundColor: primary,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Campos del formulario (estructura; sin controllers)
                Column(
                  children: [
                    SizedBox(height: 40),
                    _buildHeader(context),

                    const SizedBox(height: 35),

                    _buildTextField(
                      context: context,
                      hintText: 'Nombre y Apellido',
                      prefixIcon: Icons.person,
                      keyboardType: TextInputType.text,
                      onChanged: (value) =>
                          registerBloc.nameAndSurnameChanged(value),
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      context: context,
                      hintText: 'Matrícula',
                      prefixIcon: Icons.badge_outlined,
                      keyboardType: TextInputType.number,
                      onChanged: (value) =>
                          registerBloc.registrationChanged(value),
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      context: context,
                      hintText: 'E-mail',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) => registerBloc.emailChanged(value),
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      context: context,
                      hintText: 'Teléfono',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      onChanged: (value) => registerBloc.phoneChanged(value),
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      context: context,
                      hintText: 'Contraseña',
                      prefixIcon: Icons.lock_outline,
                      suffixIcon: !state.viewFirstPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      obscureText: !state.viewFirstPassword,
                      onChanged: (value) =>
                          registerBloc.firstPasswordChanged(value),
                      onPressedSufix: () => registerBloc.add(
                        RegisterViewFirstPasswordEvent(
                          viewFirstPassword: !state.viewFirstPassword,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      context: context,
                      hintText: 'Repetir contraseña',
                      prefixIcon: Icons.lock_outline,
                      suffixIcon: !state.viewSecondPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      obscureText: !state.viewSecondPassword,
                      onChanged: (value) =>
                          registerBloc.secondPasswordChanged(value),
                      onPressedSufix: () => registerBloc.add(
                        RegisterViewSecondPasswordEvent(
                          viewSecondPassword: !state.viewSecondPassword,
                        ),
                      ),
                    ),

                    const SizedBox(height: 41),
                    // Botón principal: Registrarse (sin lógica)
                    _buildButton(
                      state: state,
                      context: context,
                      text: 'Registrarse',
                      onPressed: state.enableButton ? callBack : null,
                      backgroundColor: Colors.white,
                      textColor: primary,
                      borderRadius: 40,
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                _buildBottom(context),
                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // AppBar simple
  AppBar _appBar(BuildContext context) {
    final registerBloc = context.read<RegisterBloc>();

    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      elevation: 0,
      iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
      actions: [
        IconButton(
          onPressed: () {
            if (registerBloc.state.registerStatus != RegisterStatus.loading &&
                registerBloc.state.registerStatus != RegisterStatus.success) {
              FocusManager.instance.primaryFocus?.unfocus();
              context.go(Routes.login);
              registerBloc.reset();
            }
          },
          icon: Icon(
            Icons.close,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ],
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

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Text(
          'REGISTRO',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        SizedBox(width: 8),
        Icon(Icons.assignment_ind_rounded, color: Colors.white),
      ],
    );
  }

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
    final primary = Theme.of(context).colorScheme.primary;

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
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 16,
          ),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: primary)
              : null,
          suffixIcon: suffixIcon != null
              ? IconButton(
                  onPressed: onPressedSufix,
                  icon: Icon(suffixIcon, color: primary),
                )
              : null,
          hintText: hintText,
          hintStyle: TextStyle(color: primary, fontWeight: FontWeight.bold),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: primary.withOpacity(0.25)),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required RegisterState state,
    required String text,
    required VoidCallback? onPressed,
    required Color backgroundColor,
    required Color textColor,
    double borderRadius = 40,
    double height = 56,
    bool outlined = false,
  }) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: height,
      child: outlined
          ? OutlinedButton(
              onPressed: onPressed,

              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.onPrimary.withOpacity(0.12),
                ),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                disabledBackgroundColor: backgroundColor.withOpacity(0.71),
                foregroundColor: textColor.withOpacity(0.71),
                backgroundColor: backgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
              child: _animatedSwitcherButton(
                state,
                Theme.of(context).colorScheme.primary,
              ),
            ),
    );
  }
}

AnimatedSwitcher _animatedSwitcherButton(
  RegisterState state,
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
    child: state.registerStatus != RegisterStatus.loading
        ? Text(
            'Registrarse',
            key: const ValueKey('register_text'),
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          )
        : MyLoadingIndicator(size: 65, key: ValueKey('register_loader')),
  );
}

// AppBar alternativo (si prefieres separarlo)
class MyAppBarRegister extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onClose;
  const MyAppBarRegister({super.key, this.onClose});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      elevation: 0,
      actions: [
        IconButton(
          onPressed: onClose,
          icon: Icon(
            Icons.close_sharp,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
