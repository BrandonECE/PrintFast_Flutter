import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:printfast_rebuild/config/routes/routes.dart';
import 'package:printfast_rebuild/presentation/blocs/shared_blocs/cloud_storage_pdf_bloc.dart/cloud_storage_pdf_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/user_blocs/home_bloc/home_bloc.dart';
import 'package:printfast_rebuild/presentation/widgets/widgets.dart';
import 'package:printfast_rebuild/utils/utils.dart';

class MyActiveOrderView extends StatelessWidget {
  const MyActiveOrderView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final colorScheme = Theme.of(context).colorScheme;

    final cloudStoragePdfViewBloc = context.read<CloudStoragePdfBloc>();

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        void viewThePdf() {
          cloudStoragePdfViewBloc.fileFromCloudStorage(state.activeOrder == null ? "" : state.activeOrder!.url);
          context.push(Routes.cloudStoragePdfView);
        }

        return Scaffold(
          backgroundColor: colorScheme.primary,
          appBar: MyAppBarWidget(
            title: 'Detalle de orden',
            leadingIcon: Icons.receipt_long_rounded,
            leadingIconSize: 24,
            actionIcon: Icons.close_rounded,
            actionIconSize: 25,
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
  Widget _topCard(BuildContext context, double width, HomeState homeState) {
    final colorScheme = Theme.of(context).colorScheme;

     final status = homeState.activeOrder!.hasItBeenAccepted == null
            ? "En revisión"
            : "Activa";
        final isActive = homeState.activeOrder!.hasItBeenAccepted == null
            ? false
            : true;

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
                  "Orden #${homeState.activeOrder!.orderCode}",
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
                  text: homeState.activeOrder!.copyShopName,
                ),
                const SizedBox(height: 4),
                _infoRow(
                  context,
                  icon: Icons.picture_as_pdf_rounded,
                  text: homeState.activeOrder!.pdfName,
                ),
              ],
            ),
          ),

          // Estado + precio
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _statusChip(context, isActive: isActive, status: status),
              const SizedBox(height: 8),
              Text(
                '\$${homeState.activeOrder!.price.toStringAsFixed(2)}',
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
  Widget _datesCard(BuildContext context, double width, HomeState homeState) {
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
          // Fecha y hora más juntas (sin color primary)
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _dateItem(
                context,
                Icons.calendar_month_rounded,
                formatDateToYMD(homeState.activeOrder!.initDate),
              ),
              const SizedBox(width: 7),
              _dateItem(
                context,
                Icons.access_time_rounded,
                formatTimeToAmPm(
                  homeState.activeOrder!.initDate,
                  uppercaseSuffix: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _sectionLabel(context, 'ENTREGA ESTIMADA'),
          const SizedBox(height: 6),
          // Entrega estimada con color primary
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _dateItemPrimary(
                context,
                Icons.calendar_month_rounded,
                formatDateToYMD(homeState.activeOrder!.estimatedDeliveryTime!),
              ),
              const SizedBox(width: 7),
              _dateItemPrimary(
                context,
                Icons.access_time_rounded,
                formatTimeToAmPm(
                  homeState.activeOrder!.estimatedDeliveryTime!,
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
                    _detailChip(context, label: homeState.activeOrder!.format),
                    _detailChip(
                      context,
                      label: homeState.activeOrder!.isColor ? 'Color' : 'B/N',
                    ),
                    _detailChip(
                      context,
                      label: '${homeState.activeOrder!.pages} pág',
                    ),
                  ],
                ),
              ),
              // Chip de método de pago a la derecha
              _paymentMethodChip(context, isCardPayment: !homeState.activeOrder!.paymentMethod.contains("cash")),
            ],
          ),
        ],
      ),
    );
  }

  // Widget para fecha/hora normal (sin color primary)
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

  // Widget para fecha/hora con color primary
  Widget _dateItemPrimary(BuildContext context, IconData icon, String text) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, color: colorScheme.primary, size: 16),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  // ---------- Preview + botón de seguimiento ----------
  Widget _previewCard(
    BuildContext context,
    double width,
    HomeState homeState,
    VoidCallback viewThePdf,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool showCodeButton = homeState.activeOrder!.hasItBeenCanceledByUser;

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
                  SingleChildScrollView(
                     scrollDirection: Axis.horizontal,
                    child: Text(
                      homeState.activeOrder!.pdfName,
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
                    '${homeState.activeOrder!.pages} páginas',
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
          const SizedBox(height: 16),
          _actionButtonsRow(context, showCodeButton),
        ],
      ),
    );
  }

  // ---------- Fila de botones de acción ----------
  Widget _actionButtonsRow(BuildContext context, bool showCodeButton) {
    return Row(
      children: [
        // Botón de seguimiento (expandido para ocupar espacio disponible)
        Expanded(
          flex: 1, // Proporción 2:1
          child: _liveTrackingButton(context),
        ),

        const SizedBox(width: 12),

        // Botón de ver código
        Expanded(
          flex: 1, // Proporción 2:1
          child: _viewCodeButton(context),
        ),
      ],
    );
  }

  // ---------- Botón de seguimiento en vivo ----------
  Widget _liveTrackingButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ElevatedButton.icon(
      onPressed: () => context.push(Routes.liveTracking),
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 2,
      ),
      icon: const Icon(Icons.directions_rounded, size: 18),
      label: const Text(
        'Ver Seg.', //Ver Seguimiento
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }

  // ---------- Botón de ver código ----------
  Widget _viewCodeButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => context.push(Routes.codeView),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 2,
      ),
      icon: const Icon(Icons.qr_code_rounded, size: 18),
      label: const Text(
        'Ver Código',
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
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
  }) {
    final paymentMethod = isCardPayment ? 'Tarjeta' : 'Efectivo';
    final icon = isCardPayment
        ? Icons.credit_card_rounded
        : Icons.money_rounded;
    final backgroundColor = isCardPayment ? Colors.blue : Colors.orange;

    return GestureDetector(
      onTap: () => context.push(Routes.changePaymentMethod),
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

 Widget _statusChip(
    BuildContext context, {
    required bool isActive,
    required String status,
  }) {
    final baseGreen = Colors.green;
    final baseOrange = Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ), // Reducido
      decoration: BoxDecoration(
        
        color: isActive
            ? baseGreen
            : baseOrange,
        borderRadius: BorderRadius.circular(16), // Reducido
         boxShadow: [
          BoxShadow(
            color: isActive
                ? baseGreen.withOpacity(0.3)
                : baseOrange.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.pending,
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: 5), // Reducido
          Text(
            status,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 11, // Reducido
            ),
          ),
        ],
      ),
    );
  }



}
