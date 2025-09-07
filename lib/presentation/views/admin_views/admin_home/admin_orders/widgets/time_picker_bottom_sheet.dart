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
                    duration: const Duration(milliseconds: 275),
                    child: Container(
                      color: showDeliveryTimeBottomSheet
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
                bottom: showDeliveryTimeBottomSheet
                    ? 0
                    : -MediaQuery.of(context).size.height * 0.35,
                left: 0,
                right: 0,
                top: showDeliveryTimeBottomSheet
                    ? MediaQuery.of(context).size.height * 0.65
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
                      _myBottomSheetTop(context, adminOrderChangeDeliveryTimeBloc),
                      // Cambisr la hora de de entrega estimada
                      // DateRangePickerDialog(firstDate: DateTime.now(), lastDate: DateTime.now().add(Duration(minutes: 50))),
                      _myTimeBottomSheet(deliveryTime),
                      // Botón aceptar
                      _myButtonWarning(context, adminOrderChangeDeliveryTimeBloc),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
Widget _myTimeBottomSheet(DateTime initialDateTime) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: SizedBox(
      height: 100,
      child: CupertinoTheme(
        
        data: const CupertinoThemeData(
          // Ajusta el tamaño del texto para modificar la curva percibida
          textTheme: CupertinoTextThemeData(
            dateTimePickerTextStyle: TextStyle(
              fontSize: 22, // 👈 Más grande = efecto 3D más notorio
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.time,
          minimumDate: DateTime.now(),
          initialDateTime: initialDateTime,
          onDateTimeChanged: (DateTime value) {},
        ),
      ),
    ),
  );
}

  Row _myBottomSheetTop(
    BuildContext context,
    AdminOrderChangeDeliveryTimeBloc adminOrderChangeDeliveryTimeBloc
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              "Entrega estimada",
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              Icons.access_time_filled_rounded,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
          ],
        ),
        IconButton(
          onPressed: () => adminOrderChangeDeliveryTimeBloc.add(AdminOrderShowChangeDeliveryTimeEvent(showDeliveryTimeBottomSheet: false),
          ),
          icon: Icon(Icons.close, color: Theme.of(context).colorScheme.primary),
        ),
      ],
    );
  }

  Widget _myButtonWarning(
    BuildContext context, AdminOrderChangeDeliveryTimeBloc adminOrderChangeDeliveryTimeBloc
  ) {
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
        onPressed: () => adminOrderChangeDeliveryTimeBloc.add(AdminOrderShowChangeDeliveryTimeEvent(showDeliveryTimeBottomSheet: false)),
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

