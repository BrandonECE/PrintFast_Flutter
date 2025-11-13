import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/admin_blocs/admin_home_bloc/admin_home_bloc.dart';
import 'package:printfast_rebuild/presentation/widgets/widgets.dart';

class MyMessageArchiveCanceledOrderByUser extends StatelessWidget {
  const MyMessageArchiveCanceledOrderByUser({
    super.key,
    required this.voidCallback,
    this.voidCallbackByCloseIcon,
    this.voidCallbackByPopScope,
  });
  final VoidCallback voidCallback;
  final VoidCallback? voidCallbackByCloseIcon;
  final VoidCallback? voidCallbackByPopScope;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminHomeBloc, AdminHomeState>(
      builder: (context, state) {
        final adminHomeBloc = context.read<AdminHomeBloc>();
        final colorScheme = Theme.of(context).colorScheme;
        final title = "Orden ACPT. Cancelada";
        final text =
            "En ${AdminHomeBloc.definedCountdownTime} segundos... Esta orden se archivará automáticamente en el historial.";

        return PopScope(
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              if (state.showMessageArchiveCanceledOrderByUser) {
                voidCallbackByPopScope == null
                    ? adminHomeBloc.add(
                        AdminHomeShowMessageArchiveCanceledOrderByUserEvent(
                          showMessageArchiveCanceledOrderByUser: false,
                        ),
                      )
                    : voidCallbackByPopScope?.call();
              }
            }
          },
          child: Stack(
            children: [
              // Fondo semi-transparente
              IgnorePointer(
                ignoring: !state.showMessageArchiveCanceledOrderByUser,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 225),
                  opacity: state.showMessageArchiveCanceledOrderByUser
                      ? 1.0
                      : 0.0,
                  child: Container(
                    color: colorScheme.inverseSurface.withOpacity(0.4),
                  ),
                ),
              ),

              // Panel que aparece desde arriba
              AnimatedPositioned(
                curve: Curves.fastLinearToSlowEaseIn,
                duration: const Duration(milliseconds: 850),
                bottom: state.showMessageArchiveCanceledOrderByUser
                    ? 0
                    : -MediaQuery.of(context).size.height * 0.278,
                left: 0,
                right: 0,
                top: state.showMessageArchiveCanceledOrderByUser
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
                                    Icons.cancel_rounded,
                                    color: colorScheme.primary,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.inverseSurface,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: voidCallbackByCloseIcon == null
                                  ? () => adminHomeBloc.add(
                                      AdminHomeShowMessageArchiveCanceledOrderByUserEvent(
                                        showMessageArchiveCanceledOrderByUser:
                                            false,
                                      ),
                                    )
                                  : () => voidCallbackByCloseIcon?.call(),
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
                                    text,
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

  Widget _myActionButtons(
    BuildContext context,
    VoidCallback voidCallBack,
    AdminHomeState state,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final showLoadingButton =
        state.archivingAcceptedOrderAfterBeingaCancelledByTheUserStatus ==
            ArchivingAcceptedOrderAfterBeingCanceledByTheUserStatus.loading &&
        state.archivingCountdown == 0;

    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: showLoadingButton ? (){} : voidCallBack,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
            child: MyAnimatedContentSwitcherButton(
              showLoad: showLoadingButton,
              text: "Aceptar (${state.archivingCountdown} seg)",
              textSize: 15,
              icon: Icons.receipt_long_rounded,
              iconSize: 18,
              loadingIndicatorSize: 28,
            ),
          ),
        ),
      ],
    );
  }
}
