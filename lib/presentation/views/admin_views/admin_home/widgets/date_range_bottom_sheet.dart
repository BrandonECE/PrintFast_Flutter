import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/admin_blocs/admin_change_report_date_range_bloc/admin_change_report_date_range_bloc.dart';

class MyDateRangeBottomSheet extends StatelessWidget {
  const MyDateRangeBottomSheet({super.key});
  @override
  Widget build(BuildContext context) {
    final adminChangeReportDateRangeBloc = context
        .read<AdminChangeReportDateRangeBloc>();
    return BlocBuilder<
      AdminChangeReportDateRangeBloc,
      AdminChangeReportDateRangeState
    >(
      builder: (context, state) {
        final showChangeReportDateRangeBottomSheet =
            state.showChangeReportDateRangeBottomSheet;
        return PopScope(
          onPopInvokedWithResult: (didPop, result) {
            adminChangeReportDateRangeBloc.add(
              AdminShowChangeReportDateRangeEvent(
                showChangeReportDateRangeBottomSheet: false,
              ),
            );
          },
          child: Stack(
            children: [
              // Fondo semi-transparente
              Align(
                alignment: Alignment.center,
                child: IgnorePointer(
                  ignoring: !showChangeReportDateRangeBottomSheet,
                  child: AnimatedOpacity(
                    opacity: showChangeReportDateRangeBottomSheet ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 275),
                    child: Container(
                      color: showChangeReportDateRangeBottomSheet
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
                bottom: showChangeReportDateRangeBottomSheet
                    ? 0
                    : -MediaQuery.of(context).size.height * 0.58,
                left: 0,
                right: 0,
                top: showChangeReportDateRangeBottomSheet
                    ? MediaQuery.of(context).size.height * 0.42
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
                      Column(
                        children: [
                          _myBottomSheetTop(
                            context,
                            adminChangeReportDateRangeBloc,
                          ),
                          // Cambisr la hora de de entrega estimada
                          // DateRangePickerDialog(firstDate: DateTime.now(), lastDate: DateTime.now().add(Duration(minutes: 50))),
                          _myDateRangeBottomSheet(context),
                        ],
                      ),
                      // Botón aceptar
                      _myButtonWarning(context, adminChangeReportDateRangeBloc),
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

  Widget _myDateRangeBottomSheet(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final today = DateTime.now();
    final minDate = DateTime(2025, 1, 1);
    final maxDate = DateTime(today.year, today.month, today.day);
    return Material(
      child: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: SizedBox(
          height: 330,
          child: CalendarDatePicker2(
            config: CalendarDatePicker2Config(
              
              calendarType: CalendarDatePicker2Type.range, // 👈 Rango de fechas
              firstDate: minDate, // 👈 No deja ir antes del 1 enero 2025
              lastDate: maxDate, // 👈 No deja ir más allá de hoy
              selectedDayHighlightColor: primaryColor, // Color de selección
              weekdayLabels: const ["L", "M", "M", "J", "V", "S", "D"],
              dayTextStyle: const TextStyle(fontSize: 16),
              daySplashColor: Colors.transparent,
              selectedDayTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              controlsTextStyle: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            value: [],
            onValueChanged: (dates) {},
          ),
        ),
      ),
    );
  }

  Row _myBottomSheetTop(
    BuildContext context,
    AdminChangeReportDateRangeBloc adminChangeReportDateRangeBloc,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              "Rango de fechas",
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              Icons.calendar_month,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
          ],
        ),
        IconButton(
          onPressed: () => adminChangeReportDateRangeBloc.add(
            AdminShowChangeReportDateRangeEvent(
              showChangeReportDateRangeBottomSheet: false,
            ),
          ),
          icon: Icon(Icons.close, color: Theme.of(context).colorScheme.primary),
        ),
      ],
    );
  }

  Widget _myButtonWarning(
    BuildContext context,
    AdminChangeReportDateRangeBloc adminChangeReportDateRangeBloc,
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
        onPressed: () => adminChangeReportDateRangeBloc.add(
          AdminShowChangeReportDateRangeEvent(
            showChangeReportDateRangeBottomSheet: false,
          ),
        ),
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
