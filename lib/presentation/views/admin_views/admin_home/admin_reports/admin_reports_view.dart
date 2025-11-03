import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printfast_rebuild/domain/entities/entities.dart';
import 'package:printfast_rebuild/presentation/blocs/admin_blocs/admin_change_report_date_range_bloc/admin_change_report_date_range_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/admin_blocs/admin_reports_bloc/admin_reports_bloc.dart';
import 'package:printfast_rebuild/presentation/widgets/widgets.dart';

class MyAdminReportsView extends StatelessWidget {
  const MyAdminReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final colorScheme = Theme.of(context).colorScheme;

    return _AdminReportsViewContent(width: width, colorScheme: colorScheme);
  }
}

class _AdminReportsViewContent extends StatelessWidget {
  final double width;
  final ColorScheme colorScheme;

  const _AdminReportsViewContent({
    required this.width,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return _myBody(context);
  }

  SafeArea _myBody(BuildContext context) {
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
          child: Column(
            children: [
              _buildTitleRow(context, width, colorScheme),
              Expanded(child: Stack(children: [_buildGrid(context)])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleRow(
    BuildContext context,
    double width,
    ColorScheme colorScheme,
  ) {
    return BlocBuilder<AdminReportsBloc, AdminReportsState>(
      builder: (context, state) {
        final adminChangeReportDateRangeBloc = context
            .read<AdminChangeReportDateRangeBloc>();
        final report = state.report;
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
                Icon(
                  Icons.arrow_drop_down,
                  size: 24,
                  color: colorScheme.inverseSurface,
                ),
              ],
            ),

            // Selector de fecha optimizado
            AbsorbPointer(
              absorbing: state.status != AdminReportsStatus.success,
              child: GestureDetector(
                onTap: () => adminChangeReportDateRangeBloc.add(
                  AdminShowChangeReportDateRangeEvent(
                    showChangeReportDateRangeBottomSheet: true,
                  ),
                ),
                child: Container(
                  constraints: BoxConstraints(maxWidth: width * 0.46),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12.5,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.25),
                      width: 1.2,
                    ),
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
                        child: Icon(
                          Icons.calendar_month_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              report.dateRangeText,
                              style: TextStyle(
                                color: colorScheme.inverseSurface,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                overflow: TextOverflow.ellipsis,
                              ),
                              maxLines: 1,
                            ),
                            Text(
                              report.formattedDateRange,
                              style: TextStyle(
                                color: colorScheme.inverseSurface.withOpacity(
                                  0.7,
                                ),
                                fontSize: 11,
                                overflow: TextOverflow.ellipsis,
                              ),
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_drop_down,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGrid(BuildContext context) {
    return BlocBuilder<AdminReportsBloc, AdminReportsState>(
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 225),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: _chooseContent(context, state),
        );
      },
    );
  }

  Widget _chooseContent(BuildContext context, AdminReportsState state) {
    switch (state.status) {
      case AdminReportsStatus.loading:
        return _buildLoading(context);
      case AdminReportsStatus.failure:
        return _buildFailure(context, state.errorMessage!);
      case AdminReportsStatus.success:
        return _buildSuccessGrid(context, state.report);
    }
  }

  Widget _buildSuccessGrid(BuildContext context, ReportEntity report) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildGridContent(
              context,
              items: [
                _GridItem(
                  title: "Ganancias",
                  value: "\$${report.earnings.toStringAsFixed(2)}",
                  icon: Icons.attach_money_rounded,
                  color: Colors.green,
                ),
                _GridItem(
                  title: "Órdenes Totales",
                  value: "${report.totalOrders}",
                  icon: Icons.receipt_long_rounded,
                  color: colorScheme.primary,
                ),
                _GridItem(
                  title: "Órdenes Completadas",
                  value: "${report.completedOrders}",
                  icon: Icons.check_circle_rounded,
                  color: Colors.green,
                ),
                _GridItem(
                  title: "Órdenes Canceladas",
                  value: "${report.canceledOrders}",
                  icon: Icons.cancel_rounded,
                  color: Colors.redAccent,
                ),
                _GridItem(
                  title: "Hojas Usadas",
                  value: "${report.pagesUsed}",
                  icon: Icons.description_rounded,
                  color: colorScheme.primary,
                ),
                _GridItem(
                  title: "Tiempo Prom.",
                  value: "${report.averageTime.toStringAsFixed(0)} min",
                  icon: Icons.access_time_rounded,
                  color: Colors.orange,
                ),
              ],
              crossAxisCount: 2,
              spacing: 14,
            ),
            const SizedBox(height: 20),
             ReportBarChart(report: report, colorScheme: Theme.of(context).colorScheme)
          ],
        ),
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: MyLoadingIndicator(),
      ),
    );
  }

  Widget _buildFailure(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.12),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 36,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No se pudieron cargar los reportes',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message.isNotEmpty
                  ? message
                  : 'Revisa tu conexión e inténtalo de nuevo más tarde.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.75),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridContent(
    BuildContext context, {
    required List<_GridItem> items,
    int crossAxisCount = 2,
    double spacing = 14,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalSpacing = spacing * (crossAxisCount - 1);
        final itemWidth =
            (constraints.maxWidth - totalSpacing) / crossAxisCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: items.map((it) {
            return SizedBox(width: itemWidth, child: _gridCard(context, it));
          }).toList(),
        );
      },
    );
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

class ReportBarChart extends StatelessWidget {
  final ReportEntity report;
  final ColorScheme colorScheme;

  const ReportBarChart({
    Key? key,
    required this.report,
    required this.colorScheme,
  }) : super(key: key);

  String _formatValue(String label, double value) {
    switch (label) {
      case 'Ganancias':
        return '\$${value.toStringAsFixed(value == value.toInt() ? 0 : 2)}';
      case 'Tiempo prom.':
        return '${value.toStringAsFixed(0)}m';
      default:
        return value.toInt().toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final metrics = [
      {
        'label': 'Ganancias',
        'value': report.earnings.toDouble(), // Ejemplo hardcodeado
        'color': Colors.green
      },
      {
        'label': 'Órdenes',
        'value': report.totalOrders.toDouble(),
        'color': colorScheme.primary
      },
      {
        'label': 'Completadas',
        'value': report.completedOrders.toDouble(),
        'color': Colors.green
      },
      {
        'label': 'Canceladas',
        'value': report.canceledOrders.toDouble(),
        'color': Colors.redAccent
      },
      {
        'label': 'Hojas',
        'value': report.pagesUsed.toDouble(),
        'color': colorScheme.primary
      },
      {
        'label': 'Tiempo prom.',
        'value': report.averageTime.toDouble(),
        'color': Colors.orange
      },
    ];

    // Calcular el máximo basado en los valores reales que se muestran
    final maxVal = metrics
        .map<double>((m) => m['value'] as double)
        .reduce((a, b) => a > b ? a : b);

    // Si el máximo es 0, usar 1 para evitar división por cero
    final double effectiveMaxVal = maxVal > 0 ? maxVal : 1.0;

    return Container(
      height: 170,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: metrics.map((metric) {
          final label = metric['label'] as String;
          final value = metric['value'] as double;
          final color = metric['color'] as Color;
          final formattedValue = _formatValue(label, value);

          // Calcular altura proporcional al máximo real
          final barHeight = (value / effectiveMaxVal) * 90;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$label: $formattedValue'),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Valor sobre la barra
                    Text(
                      formattedValue,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Barra
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOut,
                      height: barHeight > 0 ? barHeight : 2,
                      width: 18,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.2),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Etiqueta
                    Text(
                      label.split(' ').first,
                      style: TextStyle(
                        fontSize: 10,
                        color: colorScheme.onSurface.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}