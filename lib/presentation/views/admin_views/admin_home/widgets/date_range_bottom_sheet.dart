import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/admin_blocs/admin_change_report_date_range_bloc/admin_change_report_date_range_bloc.dart';

class MyDateRangeBottomSheet extends StatelessWidget {
  const MyDateRangeBottomSheet({super.key});
  
  @override
  Widget build(BuildContext context) {
    final adminChangeReportDateRangeBloc = context.read<AdminChangeReportDateRangeBloc>();
    final colorScheme = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return BlocBuilder<AdminChangeReportDateRangeBloc, AdminChangeReportDateRangeState>(
      builder: (context, state) {
        final showChangeReportDateRangeBottomSheet = state.showChangeReportDateRangeBottomSheet;
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
                          ? colorScheme.inverseSurface.withOpacity(0.4)
                          : Colors.transparent,
                    ),
                  ),
                ),
              ),
              // Panel del selector de fechas
              AnimatedPositioned(
                bottom: showChangeReportDateRangeBottomSheet ? 0 : -screenHeight * (1-0.48),
                left: 0,
                right: 0,
                top: showChangeReportDateRangeBottomSheet ? screenHeight * 0.48 : screenHeight,
                duration: const Duration(milliseconds: 1100),
                curve: Curves.fastLinearToSlowEaseIn,
                child: Material(
                  color: colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  elevation: 8,
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: screenHeight * 0.7, // Máximo 70% de la pantalla
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: SingleChildScrollView( // Permite scroll si es necesario
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
                                    Icons.calendar_month_rounded,
                                    color: colorScheme.primary,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "Rango de fechas",
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                onPressed: () => adminChangeReportDateRangeBloc.add(
                                  AdminShowChangeReportDateRangeEvent(
                                    showChangeReportDateRangeBottomSheet: false,
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
                          
                          const SizedBox(height: 12),
                          
                          // Selector de rango de fechas (más compacto)
                          _myDateRangeBottomSheet(context),
                          
                          const SizedBox(height: 16),
                          
                          // Botón de aceptar
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => adminChangeReportDateRangeBloc.add(
                                AdminShowChangeReportDateRangeEvent(
                                  showChangeReportDateRangeBottomSheet: false,
                                ),
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
    
    return Container(
      height: 280, // Reducido de 300 a 280
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: CalendarDatePicker2(
        config: CalendarDatePicker2Config(
          calendarType: CalendarDatePicker2Type.range,
          firstDate: minDate,
          lastDate: maxDate,
          selectedDayHighlightColor: primaryColor,
          weekdayLabels: const ["L", "M", "M", "J", "V", "S", "D"],
          weekdayLabelTextStyle: TextStyle(
            fontSize: 12, // Reducido de 12 a 11
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          dayTextStyle: TextStyle(
            fontSize: 14, // Reducido de 14 a 13
            color: Theme.of(context).colorScheme.onSurface,
          ),
          daySplashColor: Colors.transparent,
          selectedDayTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14, // Reducido de 14 a 13
          ),
          controlsTextStyle: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 14, // Reducido de 14 a 13
          ),
          centerAlignModePicker: true,
          customModePickerIcon: const SizedBox(),
          yearTextStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 14, // Reducido de 14 a 13
          ),
        ),
        value: [],
        onValueChanged: (dates) {},
      ),
    );
  }
}