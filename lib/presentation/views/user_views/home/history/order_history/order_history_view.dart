import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:printfast_rebuild/config/routes/routes.dart';
import 'package:printfast_rebuild/presentation/blocs/shared_blocs/cloud_storage_pdf_bloc.dart/cloud_storage_pdf_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/user_blocs/history_bloc/history_bloc.dart';
import 'package:printfast_rebuild/presentation/widgets/appbar_widget.dart';
import 'package:printfast_rebuild/utils/format_date_to_ymd.dart';
import 'package:printfast_rebuild/utils/format_time_to_am_pm.dart';

class MyOrderHistoryView extends StatelessWidget {
  const MyOrderHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final colorScheme = Theme.of(context).colorScheme;

    final cloudStoragePdfViewBloc = context.read<CloudStoragePdfBloc>();

    return BlocBuilder<HistoryBloc, HistoryState>(
      builder: (context, state) {
        void viewThePdf() {
          cloudStoragePdfViewBloc.fileFromCloudStorage(state.selectedOrder.url);
          context.push(Routes.cloudStoragePdfView);
        }

        return Scaffold(
          backgroundColor: colorScheme.primary,
          appBar: MyAppBarWidget(
            title: 'Detalle de orden',
            leadingIcon: Icons.receipt_long_rounded,
            leadingIconSize: 24,
            actionIcon: Icons.close_rounded,
            actionIconSize: 22,
            onAction: () => context.canPop() ? context.pop() : null,
          ),
          body: Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: width * 0.025),
              child: Column(
                children: [
                  _topCard(context, width, state),
                  const SizedBox(height: 12),
                  _datesCard(context, width, state),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _previewCard(context, width, state, viewThePdf),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------- Top card: lugar, usuario, archivo, estado y precio ----------
  Widget _topCard(BuildContext context, double width, HistoryState historyState) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: width * 0.95,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info principal
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Orden #${historyState.selectedOrder.orderCode}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.inverseSurface,
                  ),
                ),
                const SizedBox(height: 10),
                _infoRow(
                  context,
                  icon: Icons.location_on_rounded,
                  text: historyState.selectedOrder.copyShopName,
                ),
                const SizedBox(height: 4),
                _infoRow(
                  context,
                  icon: Icons.picture_as_pdf_rounded,
                  text: historyState.selectedOrder.pdfName,
                ),
              ],
            ),
          ),

          // Estado + precio
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _statusChip(historyState.selectedOrder.hasItBeenCanceled),
              const SizedBox(height: 8),
              Text(
                '\$${historyState.selectedOrder.price.toStringAsFixed(2)}',
                style: TextStyle(
                  color: colorScheme.inverseSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: colorScheme.inverseSurface.withOpacity(0.7),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: colorScheme.inverseSurface.withOpacity(0.8),
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ---------- Card de fechas y detalles ----------
  Widget _datesCard(BuildContext context, double width, HistoryState historyState) {
    // final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: width * 0.95,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel(context, 'ORDENADO'),
          const SizedBox(height: 6),
          // Fecha y hora más juntas (color normal)
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _dateItem(
                context,
                Icons.calendar_month_rounded,
                formatDateToYMD(historyState.selectedOrder.initDate),
              ),
              const SizedBox(width: 7),
              _dateItem(
                context,
                Icons.access_time_rounded,
                formatTimeToAmPm(
                  historyState.selectedOrder.initDate,
                  uppercaseSuffix: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _sectionLabel(context, 'ENTREGA ESTIMADA'),
          const SizedBox(height: 6),
          // Entrega estimada también en color normal
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _dateItem(
                context,
                Icons.calendar_month_rounded,
                formatDateToYMD(historyState.selectedOrder.finalDate)
              ),
              const SizedBox(width: 7),
              _dateItem(
                context,
                Icons.access_time_rounded,
                formatTimeToAmPm(
                  historyState.selectedOrder.finalDate,
                  uppercaseSuffix: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _sectionLabel(context, 'DETALLES'),
          const SizedBox(height: 6),
          Row(
            children: [
              // Chips de la izquierda (formato, color, páginas)
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _detailChip(context, label: historyState.selectedOrder.format),
                    _detailChip(
                      context,
                      label: historyState.selectedOrder.isColor ? 'Color' : 'B/N',
                    ),
                    _detailChip(
                      context,
                      label: '${historyState.selectedOrder.pages} pág',
                    ),
                  ],
                ),
              ),
              // Chip de método de pago a la derecha
              _paymentMethodChip(context, isCardPayment: (historyState.selectedOrder.paymentMethod! is! String), paymentMethodObject: historyState.selectedOrder.paymentMethod!),
            ],
          ),
        ],
      ),
    );
  }

  // Widget para fecha/hora normal
  Widget _dateItem(BuildContext context, IconData icon, String text) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(
          icon,
          color: colorScheme.inverseSurface.withOpacity(0.7),
          size: 16,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: colorScheme.inverseSurface,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  // ---------- Preview (sin botón de seguimiento) ----------
  Widget _previewCard(
    BuildContext context,
    double width,
    HistoryState historyState,
    VoidCallback viewThePdf,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: width * 0.95,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Previsualización',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: colorScheme.inverseSurface,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.picture_as_pdf_rounded,
                    size: 48,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    constraints: BoxConstraints(maxWidth: width * 0.6),
                    child: Text(
                      historyState.selectedOrder.pdfName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.inverseSurface,
                        fontSize: 13,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${historyState.selectedOrder.pages} páginas',
                    style: TextStyle(
                      color: colorScheme.inverseSurface.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: viewThePdf,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Visualizar PDF',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;

    return Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: colorScheme.inverseSurface.withOpacity(0.8),
      ),
    );
  }

  Widget _detailChip(BuildContext context, {required String label}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _paymentMethodChip(
    BuildContext context, {
    required bool isCardPayment,
    required Object? paymentMethodObject,
  }) {
    final paymentMethod = isCardPayment ? 'Tarjeta' : 'Efectivo';
    final icon = isCardPayment
        ? Icons.credit_card_rounded
        : Icons.money_rounded;
    final backgroundColor = isCardPayment ? Colors.blue : Colors.orange;

    return GestureDetector(
      onTap: () => context.push(Routes.paymentMethodHistory, extra: paymentMethodObject),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: backgroundColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: backgroundColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: backgroundColor),
            const SizedBox(width: 4),
            Text(
              paymentMethod,
              style: TextStyle(
                color: backgroundColor,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(bool canceled) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: canceled ? Colors.red : Colors.green,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: canceled
                ? Colors.red.withOpacity(0.3)
                : Colors.green.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            canceled ? Icons.cancel_rounded : Icons.check_circle_rounded,
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            canceled ? 'Cancelada' : 'Completada',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
