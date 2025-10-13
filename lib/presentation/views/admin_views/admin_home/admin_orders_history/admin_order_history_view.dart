import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:printfast_rebuild/config/routes/routes.dart';
import 'package:printfast_rebuild/presentation/blocs/admin_blocs/admin_home_bloc/admin_home_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/shared_blocs/cloud_storage_pdf_bloc.dart/cloud_storage_pdf_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/shared_blocs/message_error_warning_bloc/message_error_warning_bloc.dart';
import 'package:printfast_rebuild/presentation/widgets/widgets.dart';
import 'package:printfast_rebuild/utils/utils.dart';

class MyAdminOrderHistoryView extends StatelessWidget {
  const MyAdminOrderHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // ignore: unused_local_variable
    final colorScheme = Theme.of(context).colorScheme;
    final messageErrorWarningBloc = context.read<MessageErrorWarningBloc>();
    final cloudStoragePdfViewBloc = context.read<CloudStoragePdfBloc>();

    void handleErrorToPrint(MessageErrorWarningBloc messageErrorWarningBloc, CloudStoragePdfBloc cloudStoragePdfViewBloc) {
      showSnackBar(context: context, title: "¡Error de impresión!", text: "No se pudo cargar el documento",);
      messageErrorWarningBloc.add(
        ShowMessageErrorWarningEvent(showMessageErrorWarning: true),
      );
      cloudStoragePdfViewBloc.add(
        ChangeStatusPdfFileFromCloudStorageToPrintEvent(
          cloudStoragePrintPdfStatus: CloudStoragePrintPdfStatus.initial,
        ),
      );
    }

    return BlocListener<CloudStoragePdfBloc, CloudStoragePdfState>(
      listener: (context, state) {
        if (state.cloudStoragePrintPdfStatus == CloudStoragePrintPdfStatus.failure) {
          handleErrorToPrint(messageErrorWarningBloc, cloudStoragePdfViewBloc);
        }
      },
      child: BlocBuilder<AdminHomeBloc, AdminHomeState>(
        builder: (context, state) {
          void viewThePdf() {
            cloudStoragePdfViewBloc.fileFromCloudStorage(state.selectedOrder.url);
            context.push(Routes.cloudStoragePdfView);
          }

          void printPdf() {
            cloudStoragePdfViewBloc.printPdf(state.selectedOrder.url );
          }

          return Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: _myBody(
                  context,
                  width,
                  state,
                  viewThePdf,
                  printPdf,
                ),
              ),
              MyMessageErrorWarning(
                voidCallback: () => messageErrorWarningBloc.add(
                  ShowMessageErrorWarningEvent(showMessageErrorWarning: false),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Scaffold _myBody(
    BuildContext context,
    double width,
    AdminHomeState state,
    void Function() viewThePdf,
    void Function() printPdf,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    
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
                child: _previewCard(
                  context,
                  width,
                  state,
                  viewThePdf,
                  printPdf,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Top card: lugar, usuario, archivo, estado y precio ----------
  Widget _topCard(BuildContext context, double width, AdminHomeState adminHomeState) {
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
                  "Orden #${adminHomeState.selectedOrder.orderCode}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.inverseSurface,
                  ),
                ),
                const SizedBox(height: 10),
                _infoRow(context,
                  icon: Icons.person_2_rounded,
                  text: adminHomeState.selectedOrder.userName,
                ),
                const SizedBox(height: 4),
                _infoRow(context,
                  icon: Icons.badge_rounded,
                  text: adminHomeState.selectedOrder.userRegistration,
                ),
              ],
            ),
          ),

          // Estado (completada / cancelada) + precio
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _statusChipHistory(adminHomeState.selectedOrder.hasItBeenCanceledByUser),
              const SizedBox(height: 8),
              Text(
                '\$${adminHomeState.selectedOrder.price.toStringAsFixed(2)}',
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

  Widget _infoRow(BuildContext context, {required IconData icon, required String text}) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Row(
      children: [
        Icon(icon, size: 16, color: colorScheme.inverseSurface.withOpacity(0.7)),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: colorScheme.inverseSurface.withOpacity(0.8),
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  // ---------- Card de fechas y detalles (sin botón Cambiar) ----------
  Widget _datesCard(BuildContext context, double width, AdminHomeState adminHomeState) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel(context, 'ORDENADO'),
          const SizedBox(height: 6),
          // Fecha y hora más juntas
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _dateItem(context, Icons.calendar_month_rounded, formatDateToYMD(adminHomeState.selectedOrder.initDate)),
              const SizedBox(width: 7),
              _dateItem(context, Icons.access_time_rounded, formatTimeToAmPm(adminHomeState.selectedOrder.initDate, uppercaseSuffix: false)),
            ],
          ),
          const SizedBox(height: 12),
          _sectionLabel(context, 'ENTREGA ESTIMADA'),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.calendar_month_rounded, color: colorScheme.primary, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      adminHomeState.selectedOrder.estimatedDeliveryTime != null
                          ? '${formatDateToYMD(adminHomeState.selectedOrder.estimatedDeliveryTime!)} • ${formatTimeToAmPm(adminHomeState.selectedOrder.estimatedDeliveryTime!, uppercaseSuffix: false)}'
                          : '-- • --',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              // Sin botón Cambiar en el historial
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
                    _detailChip(context, label: adminHomeState.selectedOrder.format),
                    _detailChip(context, label: adminHomeState.selectedOrder.isColor ? 'Color' : 'B/N'),
                    _detailChip(context, label: '${adminHomeState.selectedOrder.pages} pág'),
                  ],
                ),
              ),
              // Chip de método de pago a la derecha
              _paymentMethodChip(context, isCardPayment: true),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- Preview + botón Imprimir solamente ----------
  Widget _previewCard(
    BuildContext context,
    double width,
    AdminHomeState adminHomeState,
    VoidCallback viewThePdf,
    VoidCallback printPdf,
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
                  Icon(Icons.picture_as_pdf_rounded, size: 48, color: Colors.redAccent),
                  const SizedBox(height: 8),
                  Container(
                    constraints: BoxConstraints(maxWidth: width * 0.6),
                    child: Text(
                      adminHomeState.selectedOrder.pdfName,
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
                    '${adminHomeState.selectedOrder.pages} páginas',
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
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 2,
                    ),
                    child: const Text('Visualizar PDF', style: TextStyle(fontSize: 13)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Solo botón de Imprimir en el historial
          _printButtonHistory(context, printPdf),
        ],
      ),
    );
  }

  // ---------- Botón de imprimir para historial ----------
  Widget _printButtonHistory(BuildContext context, VoidCallback printPdf) {
    final colorScheme = Theme.of(context).colorScheme;
    final cloudStoragePdfState = context.watch<CloudStoragePdfBloc>().state;
    final isLoading = cloudStoragePdfState.cloudStoragePrintPdfStatus == CloudStoragePrintPdfStatus.loading;

    return ElevatedButton(
      onPressed: isLoading ? null : printPdf,
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 2,
        minimumSize: const Size(double.infinity, 48),
      ),
      child: isLoading
          ? MyLoadingIndicator(color: Colors.white, size: 24)
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.print_rounded, size: 18),
                SizedBox(width: 6),
                Text("Imprimir", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
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

  Widget _dateItem(BuildContext context, IconData icon, String text) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Row(
      children: [
        Icon(icon, color: colorScheme.inverseSurface.withOpacity(0.7), size: 16),
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

  Widget _paymentMethodChip(BuildContext context, {required bool isCardPayment}) {
    final paymentMethod = isCardPayment ? 'Tarjeta' : 'Efectivo';
    final icon = isCardPayment ? Icons.credit_card_rounded : Icons.money_rounded;
    final backgroundColor = isCardPayment ? Colors.blue : Colors.green;
    
    return Container(
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
    );
  }

  Widget _statusChipHistory(bool canceled) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: canceled ? Colors.red : Colors.green,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: canceled ? Colors.red.withOpacity(0.3) : Colors.green.withOpacity(0.3),
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