import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_pin_code_fields/flutter_pin_code_fields.dart';
import 'package:flutter/services.dart';
import 'package:printfast_rebuild/presentation/blocs/admin_blocs/admin_home_bloc/admin_home_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/shared_blocs/message_error_warning_bloc/message_error_warning_bloc.dart';
import 'package:printfast_rebuild/presentation/widgets/widgets.dart';

class MyAdminCodeValidationView extends StatelessWidget {
  const MyAdminCodeValidationView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final adminHomeBloc = context.read<AdminHomeBloc>();
    final messageErrorWarningBloc = context.read<MessageErrorWarningBloc>();

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          adminHomeBloc.add(AdminHomeUpdateEnteredPinEvent(enteredPin: ''));
        }
      },
      child: BlocConsumer<AdminHomeBloc, AdminHomeState>(
        listenWhen: (prev, curr) => prev.archivingAcceptedOrderAfterBeingaCancelledByTheUserStatus != curr.archivingAcceptedOrderAfterBeingaCancelledByTheUserStatus || prev.selectedOrder.hasItBeenCanceledByUser != curr.selectedOrder.hasItBeenCanceledByUser || prev.codeValidationStatus != curr.codeValidationStatus,
        listener: (context, state) {

           final codeValidationStatus = state.codeValidationStatus;

          if(codeValidationStatus == CodeValidationStatus.validating){
            if(context.canPop()){
                context.pop();
            }
          }
          
          
          if (state.selectedOrder.hasItBeenCanceledByUser == true &&
              state.archivingAcceptedOrderAfterBeingaCancelledByTheUserStatus ==
                  ArchivingAcceptedOrderAfterBeingCanceledByTheUserStatus
                      .idle) {
            FocusScope.of(context).unfocus();
            if(context.canPop()){
              context.pop();
            }
          }

          
        },
        builder: (context, state) {
          
          return Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: _myAdminCodeValidationViewScreen(colorScheme, context, height, width, state)),
              BlocBuilder<AdminHomeBloc, AdminHomeState>(
                builder: (context, adminHomeState) {
                  return MyMessageErrorWarning(
              
                    voidCallbackByPopScope: () {
                      if ((state.codeValidationStatus == CodeValidationStatus.failure || state.codeValidationStatus == CodeValidationStatus.invalid) && state.adminHomeActions == AdminHomeActions.validateCode) {
                        adminHomeBloc.add(
                          AdminHomeUpdateCodeValidationStatusEvent(
                            codeValidationStatus: CodeValidationStatus.idle
                          ),
                        );
                      }

                      messageErrorWarningBloc.add(
                        ShowMessageErrorWarningEvent(
                          showMessageErrorWarning: false,
                        ),
                      );            
                    },
              
                    voidCallbackByCloseIcon: () {
                      if ((state.codeValidationStatus == CodeValidationStatus.failure || state.codeValidationStatus == CodeValidationStatus.invalid) && state.adminHomeActions == AdminHomeActions.validateCode) {
                        adminHomeBloc.add(
                          AdminHomeUpdateCodeValidationStatusEvent(
                            codeValidationStatus: CodeValidationStatus.idle
                          ),
                        );
                      }

                      messageErrorWarningBloc.add(
                        ShowMessageErrorWarningEvent(
                          showMessageErrorWarning: false,
                        ),
                      );         
                    },
              
                    voidCallback: () {
                      if ((state.codeValidationStatus == CodeValidationStatus.failure || state.codeValidationStatus == CodeValidationStatus.invalid) && state.adminHomeActions == AdminHomeActions.validateCode) {
                        adminHomeBloc.add(
                          AdminHomeUpdateCodeValidationStatusEvent(
                            codeValidationStatus: CodeValidationStatus.idle
                          ),
                        );
                      }

                      messageErrorWarningBloc.add(
                        ShowMessageErrorWarningEvent(
                          showMessageErrorWarning: false,
                        ),
                      );     
                              
                  },);
                },
              )
            ],
          );
        },
      ),
    );
  }

  Scaffold _myAdminCodeValidationViewScreen(ColorScheme colorScheme, BuildContext context, double height, double width, AdminHomeState state) {
    return Scaffold(
          backgroundColor: colorScheme.primary,
          appBar: _myAppBar(context),
          body: SingleChildScrollView(
            child: ConstrainedBox(
              // Forzamos una altura mínima igual al viewport disponible
              constraints: BoxConstraints(
                minHeight:
                    height -
                    MediaQuery.of(context).padding.top -
                    kToolbarHeight,
              ),
              child: IntrinsicHeight(
                child: Center(
                  // <-- asegura centrado horizontal
                  child: Padding(
                    padding: EdgeInsets.only(bottom: width * 0.025),
                    child: Container(
                      width: width * 0.95,
                      // Importante: height infinity para que rellene el espacio mínimo
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          // Distribuye espacio entre la sección superior y el botón inferior
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment
                                  .center, // centra horizontalmente
                              children: [
                                _headerSection(colorScheme),
                                const SizedBox(height: 28),
                                _codeInputSection(context, state),
                                const SizedBox(height: 28),
                                _instructionsSection(colorScheme),
                              ],
                            ),
                            Column(
                              children: [
                                const SizedBox(height: 28),
                                _actionButton(context, state),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
  }

  MyAppBarWidget _myAppBar(BuildContext context) {
    return MyAppBarWidget(
      title: "Validar código",
      leadingIcon: Icons.verified_user_rounded,
      leadingIconSize: 24,
      actionIcon: Icons.close_rounded,
      actionIconSize: 22,
      onAction: () => context.canPop() ? context.pop() : null,
    );
  }

  Widget _headerSection(ColorScheme colorScheme) {
    return Column(
      children: [
        Icon(
          Icons.qr_code_scanner_rounded,
          size: 44,
          color: colorScheme.primary,
        ),
        const SizedBox(height: 14),
        Text(
          "Validación de código",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: colorScheme.inverseSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Ingresa el código de 5 dígitos del usuario",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: colorScheme.inverseSurface.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _codeInputSection(BuildContext context, AdminHomeState state) {
    final colorScheme = Theme.of(context).colorScheme;
    final adminHomeBloc = context.read<AdminHomeBloc>();

    return Column(
      children: [
        Text(
          "Ingresa el código de verificación",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colorScheme.inverseSurface.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 16),

        // PinCodeFields con controller y focusNode (centrado)
        Center(
          child: PinCodeFields(
            length: 5,
            fieldBorderStyle: FieldBorderStyle.square,
            responsive: false,
            fieldHeight: 60.0,
            fieldWidth: 50.0,
            borderWidth: 1.5,
            activeBorderColor: colorScheme.primary,
            activeBackgroundColor: Colors.grey[50]!,
            borderRadius: BorderRadius.circular(10.0),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            autoHideKeyboard: false,
            fieldBackgroundColor: Colors.grey[50]!,
            borderColor: colorScheme.primary.withOpacity(0.3),
            textStyle: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),

            autofocus: false, // ya manejamos el requestFocus manualmente
            onComplete: (pin) {
              adminHomeBloc.add(
                AdminHomeUpdateEnteredPinEvent(enteredPin: pin),
              );
              FocusScope.of(context).unfocus();
            },
            onChange: (pin) {
              adminHomeBloc.add(
                AdminHomeUpdateEnteredPinEvent(enteredPin: pin),
              );
            },
            margin: const EdgeInsets.only(right: 6),
          ),
        ),

        const SizedBox(height: 14),
        Text(
          "El código se completará automáticamente",
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.inverseSurface.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _instructionsSection(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                "Instrucciones para validación",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.inverseSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _instructionItem(
            icon: Icons.numbers_rounded,
            text:
                "Ingresa los 5 dígitos del código proporcionado por el usuario",
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 6),
          _instructionItem(
            icon: Icons.verified_user_rounded,
            text: "Verifica la identidad del usuario antes de validar",
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 6),
          _instructionItem(
            icon: Icons.timer_rounded,
            text: "El código expira después de 5 minutos de ser generado",
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }

  Widget _instructionItem({
    required IconData icon,
    required String text,
    required ColorScheme colorScheme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: colorScheme.primary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.inverseSurface.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionButton(BuildContext context, AdminHomeState state) {
    // ignore: unused_local_variable
    final colorScheme = Theme.of(context).colorScheme;
    final isEnabled = state.enteredPin.length == 5;
    final adminHomeBloc = context.read<AdminHomeBloc>();
    final isReadyButtonLoading = state.codeValidationStatus == CodeValidationStatus.loading || state.codeValidationStatus == CodeValidationStatus.validating;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled
            ? isReadyButtonLoading  ? () {} : () {
                // adminHomeBloc.add(AdminHomeUpdateAdminHomeActionsEvent(adminHomeActions: AdminHomeActions.validateCode));
                adminHomeBloc.add(AdminHomeConfirmCodeValidationStatusEvent());
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 3,
        ),

        child: MyAnimatedContentSwitcherButton(
          showLoad: isReadyButtonLoading ,
          text: "Validar y entregar",
          textSize: 14,
          icon: Icons.verified_rounded,
          iconSize: 18,
          loadingIndicatorSize: 26,
        ),
      ),
    );
  }
}
