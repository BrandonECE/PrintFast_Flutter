import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/admin_blocs/admin_change_report_date_range_bloc/admin_change_report_date_range_bloc.dart';

class MyAdminReportsView extends StatelessWidget {
  const MyAdminReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final colorScheme = Theme.of(context).colorScheme;
    
    return SafeArea(
      child: Center(
        child: Container(
          alignment: Alignment.topCenter,
          width: width * 0.95,
          padding: const EdgeInsets.all(20),
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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleRow(context, width, colorScheme),
                const SizedBox(height: 20),
                _buildGrid(
                  context,
                  items: [
                    _GridItem(title: "Ganancias", value: "\$1,250", icon: Icons.attach_money_rounded, color: Colors.green),
                    _GridItem(title: "Órdenes Totales", value: "128", icon: Icons.receipt_long_rounded, color: colorScheme.primary),
                    _GridItem(title: "Órdenes Completadas", value: "95", icon: Icons.check_circle_rounded, color: Colors.green),
                    _GridItem(title: "Órdenes Canceladas", value: "15", icon: Icons.cancel_rounded, color: Colors.redAccent),
                    _GridItem(title: "Hojas Usadas", value: "2,430", icon: Icons.description_rounded, color: colorScheme.primary),
                    _GridItem(title: "Tiempo Prom.", value: "7 min", icon: Icons.access_time_rounded, color: Colors.orange),
                  ],
                  crossAxisCount: 2,
                  spacing: 14,
                ),
                const SizedBox(height: 20),
                _buildSimpleChartPlaceholder(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleRow(BuildContext context, double width, ColorScheme colorScheme) {
    const demoRange = "01/09 - 07/09";
    final adminChangeReportDateRangeBloc = context.read<AdminChangeReportDateRangeBloc>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Título
        Row(
          children: [
            Text(
              "Reportes",
              style: TextStyle(
                color: colorScheme.inverseSurface,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_drop_down, size: 24, color: colorScheme.inverseSurface),
          ],
        ),
        
        // Selector de fecha optimizado
        GestureDetector(
          onTap: () => adminChangeReportDateRangeBloc.add(
            AdminShowChangeReportDateRangeEvent(showChangeReportDateRangeBottomSheet: true)
          ),
          child: Container(
            constraints: BoxConstraints(maxWidth: width * 0.46),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12.5),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colorScheme.primary.withOpacity(0.25), width: 1.2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Icon(Icons.calendar_month_rounded, size: 16, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Última semana',
                        style: TextStyle(
                          color: colorScheme.inverseSurface,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 1,
                      ),
                      Text(
                        demoRange,
                        style: TextStyle(
                          color: colorScheme.inverseSurface.withOpacity(0.7),
                          fontSize: 11,
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_drop_down, size: 18, color: colorScheme.primary),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildGrid(
    BuildContext context, {
    required List<_GridItem> items,
    int crossAxisCount = 2,
    double spacing = 14,
  }) {
    return LayoutBuilder(builder: (context, constraints) {
      final totalSpacing = spacing * (crossAxisCount - 1);
      final itemWidth = (constraints.maxWidth - totalSpacing) / crossAxisCount;

      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: items.map((it) {
          return SizedBox(
            width: itemWidth,
            child: _gridCard(context, it),
          );
        }).toList(),
      );
    });
  }

  Widget _gridCard(BuildContext context, _GridItem item) {
    final colorScheme = Theme.of(context).colorScheme;

    final bg = item.color.withOpacity(0.09);
    final borderColor = item.color.withOpacity(0.25);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: item.color.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: item.color,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: item.color.withOpacity(0.25),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Icon(item.icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            item.title,
            style: TextStyle(
              color: colorScheme.inverseSurface.withOpacity(0.8),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.value,
            style: TextStyle(
              color: item.color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleChartPlaceholder(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.18),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.stacked_bar_chart_rounded,
              size: 50,
              color: colorScheme.primary.withOpacity(0.6),
            ),
            const SizedBox(height: 10),
            Text(
              "Gráfica de rendimiento",
              style: TextStyle(
                color: colorScheme.inverseSurface.withOpacity(0.6),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridItem {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  const _GridItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}