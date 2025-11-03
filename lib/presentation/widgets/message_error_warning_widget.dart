
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/shared_blocs/message_error_warning_bloc/message_error_warning_bloc.dart';

class MyMessageErrorWarning extends StatelessWidget {
  const MyMessageErrorWarning({super.key, required this.voidCallback, this.voidCallbackByCloseIcon});
  final VoidCallback voidCallback;
  final VoidCallback? voidCallbackByCloseIcon;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessageErrorWarningBloc, MessageErrorWarningState>(
      builder: (context, state) {
        final messageErrorWarningBloc = context.read<MessageErrorWarningBloc>();
        final colorScheme = Theme.of(context).colorScheme;
        final title = state.title.toLowerCase();

      final IconData snackBarIcon = switch (title) {
          String s when s.contains("error") => Icons.error,
          String s when s.contains("cambiar") => Icons.swap_horiz_rounded,
          String s when s.contains("guardar") => Icons.save_rounded,
          String s when s.contains("pago") => Icons.payment_rounded,
          String s when s.contains("pendiente") => Icons.pending,
          String s when s.contains("cancelar")  || s.contains("rechazar") || s.contains("rechazada") => Icons.cancel_rounded,
          String s when s.contains("impresión") => Icons.print,
          String s when s.contains("confirmar") || s.contains("aceptar") => Icons.check_circle,
          String s when s.contains("pausar recepción") => Icons.pause_circle,
          String s when s.contains("reanudar recepción") => Icons.check_circle,
          _ => Icons.circle_outlined,
        };

        return PopScope(
          onPopInvokedWithResult: (didPop, result) {
            if (state.showMessageErrorWarning) {
              messageErrorWarningBloc.add(
                ShowMessageErrorWarningEvent(showMessageErrorWarning: false),
              );
            }
          },
          child: Stack(
            children: [
              // Fondo semi-transparente
              IgnorePointer(
                ignoring: !state.showMessageErrorWarning,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 225),
                  opacity: state.showMessageErrorWarning ? 1.0 : 0.0,
                  child: Container(
                    color: colorScheme.inverseSurface.withOpacity(0.4),
                  ),
                ),
              ),

              // Panel que aparece desde arriba
              AnimatedPositioned(
                curve: Curves.fastLinearToSlowEaseIn,
                duration: const Duration(milliseconds: 850),
                bottom: state.showMessageErrorWarning
                    ? 0
                    : -MediaQuery.of(context).size.height * 0.278,
                left: 0,
                right: 0,
                top: state.showMessageErrorWarning
                    ? MediaQuery.of(context).size.height * (1 - 0.278)
                    : MediaQuery.of(context).size.height,

                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  elevation: 8,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header con icono y título
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    snackBarIcon,
                                    color: colorScheme.primary,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  state.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.inverseSurface,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: voidCallbackByCloseIcon == null ? () => messageErrorWarningBloc.add(
                                ShowMessageErrorWarningEvent(
                                  showMessageErrorWarning: false,
                                ),
                              ) : () => voidCallbackByCloseIcon?.call(),
                              icon: Icon(
                                Icons.close_rounded,
                                color: colorScheme.inverseSurface.withOpacity(
                                  0.6,
                                ),
                                size: 22,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 40,
                                minHeight: 40,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Mensaje de contenido
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: colorScheme.primary.withOpacity(0.15),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Text(
                                    state.text,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: colorScheme.inverseSurface
                                          .withOpacity(0.8),
                                      fontWeight: FontWeight.w500,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Botones de acción
                        _myActionButtons(context, voidCallback, state),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _myActionButtons(BuildContext context, VoidCallback voidCallBack, MessageErrorWarningState state) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        
        
        // Botón Aceptar
        Expanded(
          child: ElevatedButton(
            onPressed: voidCallBack,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: const Text(
              'Aceptar',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        if(state.showCancelButton)
        Expanded(
          child: Row(
            children: [
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context.read<MessageErrorWarningBloc>().add(
                      ShowMessageErrorWarningEvent(showMessageErrorWarning: false),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.inverseSurface.withOpacity(0.7),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(
                      color: colorScheme.inverseSurface.withOpacity(0.2),
                      width: 1.2,
                    ),
                  ),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
      ],
    );
  }
}