
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
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20)),
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
    return Column(
      children: [
        _buildTitleRow(context, width),
        Expanded(child: _buildSectionContainer(context, width, callBack)),
      ],
    );
  }

  Widget _buildTitleRow(BuildContext context, double width) {
    final inverse = Theme.of(context).colorScheme.inverseSurface;
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: width * 0.83,
      child: Row(
        children: [
          Text(
            "Historial",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: inverse,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_drop_down, size: 25),
        ],
      ),
    );
  }

  Widget _buildSectionContainer(
    BuildContext context,
    double width,
    void Function(String, List<AorderEntity>) callBack,
  ) {
    final primary = Theme.of(context).colorScheme.primary;

    return BlocBuilder<AdminHomeBloc, AdminHomeState>(
      builder: (context, state) {
        final monthMap = state.monthOrderHistoryMap;

        if (monthMap.isEmpty) {
          return Center(
            child: Icon(
              Icons.hide_source,
              color: Colors.grey.shade300,
              size: 100,
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(bottom: 25),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: 2),
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          width: width * 0.83,
          child: ListView.separated(
            itemCount: monthMap.length,
            separatorBuilder: (_, __) => const SizedBox(height: 20),
            itemBuilder: (context, index) {
              final entry = monthMap.entries.elementAt(index);
              return _buildMonthSummary(
                context,
                primary,
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

  /// Tarjeta por MES: incluye el título + resumen + botón
  Widget _buildMonthSummary(
    BuildContext context,
    Color primary,
    String monthTitle,
    List<AorderEntity> orders,
    void Function(String, List<AorderEntity>) callBack,
  ) {
    final inverse = Theme.of(context).colorScheme.inverseSurface;

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
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade600),
            color: primary,
            borderRadius: BorderRadius.circular(10),
          ),
          width: double.infinity,
          child: Text(
            monthTitle,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Tarjeta con resumen de órdenes
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Columna con info de órdenes
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Ord. tot. ($total)",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: inverse,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.receipt_long, color: inverse, size: 18),
                    ],
                  ),
                  const SizedBox(height: 7),

                  // Completadas / Canceladas
                  Row(
                    children: [
                      Text(
                            "Est:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: inverse,
                              fontSize: 13,
                            ),
                          ),
                      const SizedBox(width: 17),
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 20,
                            color: Colors.greenAccent.shade400,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "$completed",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: inverse,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 22),
                          Icon(Icons.cancel, size: 20, color: Colors.redAccent),
                          const SizedBox(width: 6),
                          Text(
                            "$canceled",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: inverse,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              // Botón de "ver"
              ElevatedButton(
                onPressed: () => callBack.call(monthTitle, orders),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Icon(Icons.remove_red_eye),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
