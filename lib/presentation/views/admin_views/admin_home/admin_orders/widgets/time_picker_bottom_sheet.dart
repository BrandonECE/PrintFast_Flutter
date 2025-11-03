import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/admin_blocs/admin_order_change_delivery_time_bloc/admin_order_change_delivery_time_bloc.dart';

class MyTimePickerBottomSheet extends StatelessWidget {
  const MyTimePickerBottomSheet({super.key, required this.deliveryTime});
  final DateTime deliveryTime;
  
  @override
  Widget build(BuildContext context) {
    final adminOrderChangeDeliveryTimeBloc = context.read<AdminOrderChangeDeliveryTimeBloc>();
    final colorScheme = Theme.of(context).colorScheme;
    
    return BlocBuilder<AdminOrderChangeDeliveryTimeBloc, AdminOrderChangeDeliveryTimeState>(
      builder: (context, state) {
        final showDeliveryTimeBottomSheet = state.showDeliveryTimeBottomSheet;
        return PopScope(
          onPopInvokedWithResult: (didPop, result) {
            adminOrderChangeDeliveryTimeBloc.add(
              AdminOrderShowChangeDeliveryTimeEvent(showDeliveryTimeBottomSheet: false),
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
                top: showDeliveryTimeBottomSheet ? MediaQuery.of(context).size.height * (1 - 0.335) : MediaQuery.of(context).size.height ,
                duration: const Duration(milliseconds:875),
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
                                Icon(
                                  Icons.access_time_rounded,
                                  color: colorScheme.primary,
                                  size: 22,
                                ),
                                const SizedBox(width: 10),
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
                              onPressed: () => adminOrderChangeDeliveryTimeBloc.add(
                                AdminOrderShowChangeDeliveryTimeEvent(showDeliveryTimeBottomSheet: false),
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
                              initialDateTime: deliveryTime,
                              onDateTimeChanged: (DateTime value) {
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
                            onPressed: () => adminOrderChangeDeliveryTimeBloc.add(
                              AdminOrderShowChangeDeliveryTimeEvent(showDeliveryTimeBottomSheet: false),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
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