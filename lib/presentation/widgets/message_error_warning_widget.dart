import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/shared_blocs/message_error_warning_bloc/message_error_warning_bloc.dart';

class MyMessageErrorWarning extends StatelessWidget {
  const MyMessageErrorWarning({super.key, required this.voidCallback});
  final VoidCallback voidCallback;

  @override
  Widget build(BuildContext context) {
    final messageErrorWarningBloc = context.read<MessageErrorWarningBloc>();
    final colorScheme = Theme.of(context).colorScheme;
    
    return BlocBuilder<MessageErrorWarningBloc, MessageErrorWarningState>(
      builder: (context, state) {
        return PopScope(
          onPopInvokedWithResult: (didPop, result) {
            messageErrorWarningBloc.add(
              ShowMessageErrorWarningEvent(showMessageErrorWarning: false),
            );
          },
          child: Stack(
            children: [
              // Fondo semi-transparente
              Align(
                alignment: Alignment.center,
                child: IgnorePointer(
                  ignoring: !state.showMessageErrorWarning,
                  child: AnimatedOpacity(
                    opacity: state.showMessageErrorWarning ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 275),
                    child: Container(
                      color: state.showMessageErrorWarning
                          ? colorScheme.inverseSurface.withOpacity(0.4)
                          : Colors.transparent,
                    ),
                  ),
                ),
              ),
              // Panel de advertencia
              AnimatedPositioned(
                bottom: state.showMessageErrorWarning
                    ? 0
                    : -MediaQuery.of(context).size.height * 0.29,
                left: 0,
                right: 0,
                top: state.showMessageErrorWarning
                    ? MediaQuery.of(context).size.height * 0.71
                    : MediaQuery.of(context).size.height,
                curve: Curves.fastLinearToSlowEaseIn,
                duration: const Duration(milliseconds: 900),
                child: Material(
                  color: colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(25),
                  ),
                  elevation: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Título y icono de cierre
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_rounded,
                                  color: colorScheme.primary,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  messageErrorWarningBloc.title,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () => messageErrorWarningBloc.add(
                                ShowMessageErrorWarningEvent(
                                  showMessageErrorWarning: false,
                                ),
                              ),
                              icon: Icon(
                                Icons.close_rounded,
                                color: colorScheme.onSurface.withOpacity(0.7),
                                size: 24,
                              ),
                              style: IconButton.styleFrom(
                                minimumSize: const Size(48, 48),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Mensaje de advertencia
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: colorScheme.primary.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: colorScheme.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Text(
                                    messageErrorWarningBloc.message,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Botón aceptar
                        _myButtonWarning(context, voidCallback),
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

  Widget _myButtonWarning(BuildContext context, VoidCallback voidCallBack) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: voidCallBack,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
        child: const Text(
          'Aceptar',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}