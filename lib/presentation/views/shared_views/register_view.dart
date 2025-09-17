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
    final colorScheme = Theme.of(context).colorScheme;
    final registerBloc = context.read<RegisterBloc>();
    final messageErrorWarningBloc = context.read<MessageErrorWarningBloc>();

    // spacing tokens consistentes con el login
    const double gapXs = 6;
    const double gapSm = 10;
    const double gapMd = 16;
    const double gapLg = 22;
    const double outerPadding = 20;

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
              Scaffold(
                backgroundColor: colorScheme.primary,
                body: SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: outerPadding,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Logo consistente con el login
                            _buildLogo(colorScheme),
                            const SizedBox(height: gapLg),

                            // Card de registro (mismo estilo que login)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 18,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.10),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // ---------- HEADER ----------
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Crear cuenta',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700,
                                                color:
                                                    colorScheme.inverseSurface,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Completa tus datos para registrarte.',
                                              style: TextStyle(
                                                fontSize: 12,
                                                height: 1.3,
                                                color: colorScheme
                                                    .inverseSurface
                                                    .withOpacity(0.66),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: gapSm),
                                      // Info icon
                                      Tooltip(
                                        message:
                                            'Todos los campos son obligatorios',
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            onTap: () {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).hideCurrentSnackBar();
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  backgroundColor: Colors.transparent,
                                                  duration: Duration(seconds: 2),
                                                  elevation: 0,
                                                  content: MySnackBarContentWidget(
                                                    message:
                                                        'Completa todos los campos para registrarte.',
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: Colors.orange
                                                    .withOpacity(0.12),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Icon(
                                                Icons.info_outline,
                                                size: 16,
                                                color: Colors.orange,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: gapMd),

                                  // ---------- FORM FIELDS ----------
                                  Column(
                                    children: [
                                      _buildFormField(
                                        context: context,
                                        hintText: 'Nombre y Apellido',
                                        prefixIcon: Icons.person_outline,
                                        keyboardType: TextInputType.text,
                                        onChanged: (value) => registerBloc
                                            .nameAndSurnameChanged(value),
                                      ),
                                      const SizedBox(height: 12),
                                      _buildFormField(
                                        context: context,
                                        hintText: 'Matrícula',
                                        prefixIcon: Icons.badge_outlined,
                                        keyboardType: TextInputType.number,
                                        onChanged: (value) => registerBloc
                                            .registrationChanged(value),
                                      ),
                                      const SizedBox(height: 12),
                                      _buildFormField(
                                        context: context,
                                        hintText: 'E-mail',
                                        prefixIcon: Icons.email_outlined,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        onChanged: (value) =>
                                            registerBloc.emailChanged(value),
                                      ),
                                      const SizedBox(height: 12),
                                      _buildFormField(
                                        context: context,
                                        hintText: 'Teléfono',
                                        prefixIcon: Icons.phone_outlined,
                                        keyboardType: TextInputType.phone,
                                        onChanged: (value) =>
                                            registerBloc.phoneChanged(value),
                                      ),
                                      const SizedBox(height: 12),
                                      _buildFormField(
                                        context: context,
                                        hintText: 'Contraseña',
                                        prefixIcon: Icons.lock_outline,
                                        suffixIcon: !state.viewFirstPassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        obscureText: !state.viewFirstPassword,
                                        onChanged: (value) => registerBloc
                                            .firstPasswordChanged(value),
                                        onPressedSuffix: () => registerBloc.add(
                                          RegisterViewFirstPasswordEvent(
                                            viewFirstPassword:
                                                !state.viewFirstPassword,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      _buildFormField(
                                        context: context,
                                        hintText: 'Repetir contraseña',
                                        prefixIcon: Icons.lock_outline,
                                        suffixIcon: !state.viewSecondPassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        obscureText: !state.viewSecondPassword,
                                        onChanged: (value) => registerBloc
                                            .secondPasswordChanged(value),
                                        onPressedSuffix: () => registerBloc.add(
                                          RegisterViewSecondPasswordEvent(
                                            viewSecondPassword:
                                                !state.viewSecondPassword,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: gapSm),
                                  Divider(
                                    color: Colors.grey.shade200,
                                    height: 1,
                                  ),
                                  const SizedBox(height: gapSm),

                                  // ---------- BOTONES ----------
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      // Botón principal de registro
                                      _buildGradientRegisterButton(
                                        context,
                                        state,
                                        onPressed: register,
                                      ),

                                      const SizedBox(height: gapSm),

                                      // Botón para volver al login
                                      SizedBox(
                                        height: 42,
                                        child: OutlinedButton.icon(
                                          onPressed: () {
                                            if (registerBloc
                                                    .state
                                                    .registerStatus !=
                                                RegisterStatus.loading) {
                                              FocusManager.instance.primaryFocus
                                                  ?.unfocus();
                                              context.go(Routes.login);
                                              registerBloc.reset();
                                            }
                                          },
                                          icon: Icon(
                                            Icons.arrow_back_rounded,
                                            size: 16,
                                            color: colorScheme.primary,
                                          ),
                                          label: Text(
                                            'Volver al login',
                                            style: TextStyle(
                                              color: colorScheme.primary,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            side: BorderSide(
                                              color: colorScheme.primary
                                                  .withOpacity(0.14),
                                            ),
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: gapXs),

                                      // Términos y condiciones
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          'Al registrarte aceptas los términos y condiciones de PrintFast.',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.black.withOpacity(
                                              0.55,
                                            ),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: gapLg),

                            // Footer consistente
                            Text(
                              'Universidad Autónoma de Nuevo León',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              MyMessageErrorWarning(
                voidCallback: () => messageErrorWarningBloc.add(
                  ShowMessageErrorWarningEvent(showMessageErrorWarning: false),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Logo consistente con el login
  Widget _buildLogo(ColorScheme colorScheme) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.person_add_rounded,
                  size: 36,
                  color: colorScheme.primary,
                ),
              ),
            ),
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ],
        ),
        // const SizedBox(height: 12),
        // Text(
        //   'PrintFast',
        //   style: TextStyle(
        //     color: Colors.white,
        //     fontWeight: FontWeight.w700,
        //     fontSize: 22,
        //   ),
        // ),
        // const SizedBox(height: 4),
        // Text(
        //   'Crear nueva cuenta',
        //   style: TextStyle(
        //     color: Colors.blue[100],
        //     fontSize: 11,
        //     fontWeight: FontWeight.w500,
        //   ),
        // ),
      ],
    );
  }

  // Campos de formulario (mismo estilo que login)
  Widget _buildFormField({
    required BuildContext context,
    required String hintText,
    required IconData prefixIcon,
    IconData? suffixIcon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    void Function(String value)? onChanged,
    void Function()? onPressedSuffix,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderRadius = 10.0;
    final fillColor = Colors.grey[100];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: fillColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          prefixIcon: Icon(prefixIcon, color: colorScheme.primary, size: 18),
          suffixIcon: suffixIcon != null
              ? IconButton(
                  onPressed: onPressedSuffix,
                  icon: Icon(
                    suffixIcon,
                    color: colorScheme.primary.withOpacity(0.7),
                    size: 18,
                  ),
                  splashRadius: 16,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
              : null,
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.black38,
            fontWeight: FontWeight.w500,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.2),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }

  // Botón de registro con animación switcher
  Widget _buildGradientRegisterButton(
    BuildContext context,
    RegisterState state, {
    required VoidCallback onPressed,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isEnabled = state.enableButton;

    return SizedBox(
      height: 46,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style:
            ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              elevation: isEnabled ? 0 : 1,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ).copyWith(
              backgroundColor: WidgetStateProperty.resolveWith<Color>((
                Set<WidgetState> states,
              ) {
                if (states.contains(WidgetState.disabled)) {
                  return Colors.grey.shade300;
                }
                return Colors.transparent;
              }),
              shadowColor: WidgetStateProperty.all(Colors.transparent),
            ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: isEnabled
                ? LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withOpacity(0.85),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [Colors.grey.shade200, Colors.grey.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.20),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.10),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Container(
            alignment: Alignment.center,
            child: _animatedSwitcherButton(
              state,
              isEnabled,
              colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }

  // Animación switcher para el botón
  AnimatedSwitcher _animatedSwitcherButton(
    RegisterState state,
    bool isEnabled,
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
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isEnabled ? Colors.white : Colors.grey.shade600,
              ),
            )
          : MyLoadingIndicator(
              size: 27,
              color: isEnabled ? Colors.white : Colors.grey.shade400,
              key: const ValueKey('register_loader'),
            ),
    );
  }
}
