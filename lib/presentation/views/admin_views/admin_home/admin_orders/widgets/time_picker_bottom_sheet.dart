import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/admin_blocs/admin_home_bloc/admin_home_bloc.dart';

import '../../../../../../utils/utils.dart';
import '../../../../../widgets/widgets.dart';

class MyTimePickerBottomSheet extends StatelessWidget {
  const MyTimePickerBottomSheet({super.key, required this.deliveryTime});
  final DateTime deliveryTime;

  @override
  Widget build(BuildContext context) {
    final adminHomeBloc = context.read<AdminHomeBloc>();
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<AdminHomeBloc, AdminHomeState>(
      buildWhen: (prev, curr) =>
          prev.deliveryTime != curr.deliveryTime ||
          prev.showDeliveryTimeBottomSheet !=
              curr.showDeliveryTimeBottomSheet ||
          prev.changeDeliveryPendingOrderTimeStatus !=
              curr.changeDeliveryPendingOrderTimeStatus ||
          prev.changeDeliveryAcceptedOrderTimeStatus !=
              curr.changeDeliveryAcceptedOrderTimeStatus,
      builder: (context, state) {
        final showDeliveryTimeBottomSheet = state.showDeliveryTimeBottomSheet;
        final isChangeDeliveryPendingOrderTimeStatusLoading =
            state.changeDeliveryPendingOrderTimeStatus ==
            ChangeDeliveryPendingOrderTimeStatus.loading;
        final isChangeDeliveryAcceptedOrderTimeStatusLoading =
            state.changeDeliveryAcceptedOrderTimeStatus ==
            ChangeDeliveryAcceptedOrderTimeStatus.loading;
        final isButtonLoading = state.selectedOrder.hasItBeenAccepted == true
            ? isChangeDeliveryAcceptedOrderTimeStatusLoading
            : isChangeDeliveryPendingOrderTimeStatusLoading;

        return PopScope(
          onPopInvokedWithResult: (didPop, result) {
            adminHomeBloc.add(
              AdminHomeOrderShowChangeDeliveryTimeEvent(
                showDeliveryTimeBottomSheet: false,
              ),
            );
          },
          child: Stack(
            children: [
              // Fondo semi-transparente
              Align(
                alignment: Alignment.center,
                child: IgnorePointer(
                  ignoring: !showDeliveryTimeBottomSheet,
                  child: AnimatedOpacity(
                    opacity: showDeliveryTimeBottomSheet ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    child: Container(
                      color: showDeliveryTimeBottomSheet
                          ? colorScheme.inverseSurface.withOpacity(0.4)
                          : Colors.transparent,
                    ),
                  ),
                ),
              ),
              // Panel del selector de tiempo
              AnimatedPositioned(
                bottom: showDeliveryTimeBottomSheet
                    ? 0
                    : -MediaQuery.of(context).size.height * 0.335,
                left: 0,
                right: 0,
                top: showDeliveryTimeBottomSheet
                    ? MediaQuery.of(context).size.height * (1 - 0.335)
                    : MediaQuery.of(context).size.height,
                duration: const Duration(milliseconds: 875),
                curve: Curves.fastLinearToSlowEaseIn,
                child: Material(
                  color: colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  elevation: 8,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header con título y botón de cerrar
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
                                    Icons.edit_calendar_rounded,
                                    color: colorScheme.primary,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "Entrega estimada",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () => adminHomeBloc.add(
                                AdminHomeOrderShowChangeDeliveryTimeEvent(
                                  showDeliveryTimeBottomSheet: false,
                                ),
                              ),
                              icon: Icon(
                                Icons.close_rounded,
                                color: colorScheme.onSurface.withOpacity(0.7),
                                size: 22,
                              ),
                              style: IconButton.styleFrom(
                                minimumSize: const Size(44, 44),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        // Selector de tiempo Cupertino (sin fondo)
                        SizedBox(
                          height: 120, // Más compacto
                          child: CupertinoTheme(
                            data: CupertinoThemeData(
                              textTheme: CupertinoTextThemeData(
                                dateTimePickerTextStyle: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                            child: CupertinoDatePicker(
                              mode: CupertinoDatePickerMode.time,
                              minimumDate: DateTime.now(),
                              initialDateTime:
                                  deliveryTime.isAfter(DateTime.now())
                                  ? deliveryTime
                                  : DateTime.now(),
                              onDateTimeChanged: (DateTime value) {
                                adminHomeBloc.add(
                                  AdminHomeOrderUpdateDeliveryTimeEvent(
                                    deliveryTime: value,
                                  ),
                                );
                                print("ChangeDateTimeValue: $value");
                                // Lógica para cambiar la hora
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Botón de aceptar
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                isButtonLoading
                                ? () {}
                                : () {
                                    adminHomeBloc.add(
                                      AdminHomeUpdateAdminHomeActionsEvent( adminHomeActions: state .selectedOrder .hasItBeenAccepted == true ? AdminHomeActions .changeDeliveryAcceptedOrderTime : AdminHomeActions .changeDeliveryPendingOrderTime, ),
                                    );
                                    showSnackBar(
                                      context: context,
                                      title: "Actualizar H. Entrega",
                                      text:
                                          'Acepta para modificar la hora de entrega del pedido.',
                                      showCancelButton: true,
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 2,
                            ),

                            child: MyAnimatedContentSwitcherButton(
                              showLoad:isButtonLoading,
                              text: "Aceptar",
                              textSize: 15,
                              icon: Icons.edit_calendar_rounded,
                              iconSize: 18,
                              loadingIndicatorSize: 28,
                            ),
                          ),
                        ),
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
}
