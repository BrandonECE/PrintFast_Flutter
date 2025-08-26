import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/message_error_warning_bloc/message_error_warning_bloc.dart';

class MyErrorWarning extends StatelessWidget {
  const MyErrorWarning({super.key});

  @override
  Widget build(BuildContext context) {
    final messageErrorWarningBloc = context.read<MessageErrorWarningBloc>();
    return BlocBuilder<MessageErrorWarningBloc, MessageErrorWarningState>(
      builder: (context, state) {
        return Stack(
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
                        ? Theme.of(
                            context,
                          ).colorScheme.inverseSurface.withOpacity(0.4)
                        : Colors.transparent,
                  ),
                ),
              ),
            ),
            // Panel de error
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
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(25),
                  ),
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
                            Text(
                              messageErrorWarningBloc.title,
                              style: Theme.of(context).textTheme.titleLarge!
                                  .copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            const SizedBox(width: 10),
                            Icon(
                              Icons.error,
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.3),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => messageErrorWarningBloc.add(ShowMessageErrorWarningEvent(showMessageErrorWarning: false)),
                          icon: Icon(
                            Icons.close,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    // Mensaje de advertencia
                    Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height,
                            width: 6,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text(
                                  messageErrorWarningBloc.message,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Botón aceptar
                    _myButtonWarning(context, messageErrorWarningBloc),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _myButtonWarning(BuildContext context, MessageErrorWarningBloc messageErrorWarningBloc) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22.5),
          ),
          fixedSize: Size(MediaQuery.of(context).size.width, 65),
        ),
        onPressed: () => messageErrorWarningBloc.add(ShowMessageErrorWarningEvent(showMessageErrorWarning: false)),
        child: Text(
          'Aceptar',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSecondary,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
