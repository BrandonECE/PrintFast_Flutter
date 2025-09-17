import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:printfast_rebuild/config/routes/routes.dart';
import 'package:printfast_rebuild/domain/entities/entities.dart';
import 'package:printfast_rebuild/presentation/blocs/admin_blocs/admin_home_bloc/admin_home_bloc.dart';

class MyAdminOrdersHistoryView extends StatelessWidget {
  const MyAdminOrdersHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final adminHomeBloc = context.read<AdminHomeBloc>();
    
    void monthOrderHistoryElementSelect(
      String month,
      List<AorderEntity> monthOrders,
    ) {
      adminHomeBloc.add(
        AdminMonthOrderHistoryElementSelectedEvent(
          monthOrderHistoryElementSelected: {month: monthOrders},
        ),
      );
      context.push(Routes.adminMonthOrdersHistorySelectedView);
    }

    return Center(
      child: Container(
        width: width * 0.95,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: _buildBody(context, width, monthOrderHistoryElementSelect),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    double width,
    void Function(String, List<AorderEntity>) callBack,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildTitleRow(context, width),
          const SizedBox(height: 16),
          Expanded(child: _buildSectionContainer(context, width, callBack)),
        ],
      ),
    );
  }

  Widget _buildTitleRow(BuildContext context, double width) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      width: width * 0.83,
      child: Row(
        children: [
          Text(
            "Historial",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: colorScheme.inverseSurface,
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.arrow_drop_down, 
               size: 25, 
               color: colorScheme.inverseSurface),
        ],
      ),
    );
  }

  Widget _buildSectionContainer(
    BuildContext context,
    double width,
    void Function(String, List<AorderEntity>) callBack,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<AdminHomeBloc, AdminHomeState>(
      builder: (context, state) {
        final monthMap = state.monthOrderHistoryMap;

        if (monthMap.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history_rounded,
                  color: Colors.grey.shade300,
                  size: 80,
                ),
                const SizedBox(height: 16),
                Text(
                  "No hay historial disponible",
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
          ),
          width: width * 0.83,
          child: ListView.separated(
            itemCount: monthMap.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final entry = monthMap.entries.elementAt(index);
              return _buildMonthSummary(
                context,
                colorScheme,
                entry.key,
                entry.value,
                callBack,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMonthSummary(
    BuildContext context,
    ColorScheme colorScheme,
    String monthTitle,
    List<AorderEntity> orders,
    void Function(String, List<AorderEntity>) callBack,
  ) {
    // Calcular datos básicos
    final total = orders.length;
    final completed = orders
        .where((o) => o.hasItBeenAccepted && !o.hasItBeenCanceledByUser)
        .length;
    final canceled = orders.where((o) => o.hasItBeenCanceledByUser).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Banner con el nombre del mes
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          width: double.infinity,
          child: Text(
            monthTitle,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Tarjeta con resumen de órdenes
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Columna con info de órdenes
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Total de órdenes
                    Row(
                      children: [
                        Icon(
                          Icons.receipt_long_rounded,
                          size: 18,
                          color: colorScheme.inverseSurface,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Total: $total órdenes",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.inverseSurface,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Estadísticas: Completadas y Canceladas
                    Row(
                      children: [
                        // Completadas
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 18,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "$completed",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.inverseSurface,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        
                        // Canceladas
                        Row(
                          children: [
                            Icon(
                              Icons.cancel_rounded,
                              size: 18,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "$canceled",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.inverseSurface,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Botón de "ver"
              ElevatedButton(
                onPressed: () => callBack.call(monthTitle, orders),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: colorScheme.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  shadowColor: colorScheme.primary.withOpacity(0.3),
                ),
                child: const Icon(Icons.remove_red_eye, size: 20),
              ),
            ],
          ),
        ),
      ],
    );
  }
}