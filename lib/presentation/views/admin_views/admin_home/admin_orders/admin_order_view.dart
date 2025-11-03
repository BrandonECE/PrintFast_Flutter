import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:printfast_rebuild/config/routes/routes.dart';
import 'package:printfast_rebuild/presentation/blocs/admin_blocs/admin_home_bloc/admin_home_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/admin_blocs/admin_order_change_delivery_time_bloc/admin_order_change_delivery_time_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/shared_blocs/cloud_storage_pdf_bloc.dart/cloud_storage_pdf_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/shared_blocs/message_error_warning_bloc/message_error_warning_bloc.dart';
import 'package:printfast_rebuild/presentation/views/admin_views/admin_home/admin_orders/widgets/time_picker_bottom_sheet.dart';
import 'package:printfast_rebuild/presentation/widgets/widgets.dart';
import 'package:printfast_rebuild/utils/utils.dart';

class MyAdminOrderView extends StatelessWidget {
  const MyAdminOrderView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // ignore: unused_local_variable
    final colorScheme = Theme.of(context).colorScheme;
    final adminHomeBloc = context.read<AdminHomeBloc>();
    final cloudStoragePdfViewBloc = context.read<CloudStoragePdfBloc>();
    final messageErrorWarningBloc = context.read<MessageErrorWarningBloc>();

    void thereWasAnError(BuildContext context, String errorMessage) {
      showSnackBar(
        context: context,
        title: "¡Error inesperado!",
        text: errorMessage,
      );
    }

    return BlocConsumer<AdminHomeBloc, AdminHomeState>(
      listenWhen: (prev, curr) =>
          prev.pendingOrderStatus != curr.pendingOrderStatus,
      listener: (context, adminHomeState) {
        if (adminHomeState.pendingOrderStatus != PendingOrderStatus.loading) {
          if (adminHomeState.pendingOrderStatus == PendingOrderStatus.failure) {
            thereWasAnError(
              context,
              adminHomeState.pendingOrderErrorMessage ?? "",
            );
          } else if (adminHomeState.pendingOrderStatus ==
              PendingOrderStatus.success) {
            context.pop();
          }
          adminHomeBloc.add(
            AdminHomeUpdatePendingOrderDecisionEvent(
              pendingOrderDecision: PendingOrderDecision.none,
            ),
          );
        }
      },
      builder: (context, adminHomeState) {
        void viewThePdf() {
          cloudStoragePdfViewBloc.fileFromCloudStorage(
            adminHomeState.selectedOrder.url,
          );
          context.push(Routes.cloudStoragePdfView);
        }

        void printPdfHandle() {
          final selectedOrder = adminHomeState.selectedOrder;
          final userEntity = adminHomeState.userEntity;
          cloudStoragePdfViewBloc.printPdf(
            cloudStorageURL: selectedOrder.url,
            userRegistration: userEntity.registration,
            copyShopEmail: selectedOrder.copyShopEmail,
            orderCode: selectedOrder.orderCode,
            printDate: selectedOrder.printDate,
          );
        }

        void printPdf() {
          adminHomeBloc.add(
            AdminHomeUpdateAdminHomeActionsEvent(
              adminHomeActions: AdminHomeActions.printPDF,
            ),
          );
          if (adminHomeState.selectedOrder.printDate == null) {
            showSnackBar(
              context: context,
              title: 'Confirmar Impresión',
              text:
                  'Al aceptar, se registrará el inicio del proceso automáticamente.',
              showCancelButton: true,
            );
          } else {
            printPdfHandle();
          }
        }

        return PopScope(
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: _myBody(
                  context,
                  width,
                  adminHomeState,
                  viewThePdf,
                  printPdf,
                ),
              ),
              MyTimePickerBottomSheet(
                deliveryTime:
                    adminHomeState.selectedOrder.estimatedDeliveryTime!,
              ),
              BlocBuilder<CloudStoragePdfBloc, CloudStoragePdfState>(
                buildWhen: (prev, curr) =>
                    prev.cloudStoragePrintPdfStatus !=
                    curr.cloudStoragePrintPdfStatus,
                builder: (context, cloudStoragePdfState) {
                  return MyMessageErrorWarning(
                    voidCallback: () {
                      if (adminHomeState.adminHomeActions ==
                              AdminHomeActions.printPDF &&
                          cloudStoragePdfState.cloudStoragePrintPdfStatus ==
                              CloudStoragePrintPdfStatus.initial) {
                        printPdfHandle();
                      } else if (adminHomeState.adminHomeActions ==
                              AdminHomeActions.makePendingOrderDecision &&
                          adminHomeState.pendingOrderStatus ==
                              PendingOrderStatus.idle &&
                          adminHomeState.pendingOrderDecision !=
                              PendingOrderDecision.none) {
                        adminHomeBloc.add(
                          AdminHomeMakePendingOrderDecisionEvent(),
                        );
                      }
                      messageErrorWarningBloc.add(
                        ShowMessageErrorWarningEvent(
                          showMessageErrorWarning: false,
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
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
  Widget _topCard(
    BuildContext context,
    double width,
    AdminHomeState adminHomeState,
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info principal
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Orden #${adminHomeState.selectedOrder.orderCode}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.inverseSurface,
                      ),
                    ),
                    //  const SizedBox(width: 12),
                    //         Icon(
                    //           Icons.local_print_shop_rounded,
                    //           size: 24,
                    //           color: colorScheme.primary,
                    //         ),
                  ],
                ),
                const SizedBox(height: 10),
                _infoRow(
                  context,
                  icon: Icons.person_2_rounded,
                  text: adminHomeState.selectedOrder.userName,
                ),
                const SizedBox(height: 4),
                _infoRow(
                  context,
                  icon: Icons.badge_rounded,
                  text: adminHomeState.selectedOrder.userRegistration,
                ),
              ],
            ),
          ),

          // Estado (aceptada / pendiente / cancelada) + precio
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _statusChip(
                adminHomeState.selectedOrder.hasItBeenAccepted ?? false,
                adminHomeState.selectedOrder.hasItBeenCanceledByUser,
              ),
              const SizedBox(height: 8),
              Text(
                '\$${adminHomeState.selectedOrder.price.toStringAsFixed(2)}',
                style: TextStyle(
                  color: colorScheme.inverseSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              //    Row(
              //      children: [
              //       Text(
              //   'Imp.',
              //   style: TextStyle(
              //     color: colorScheme.inverseSurface,
              //     fontWeight: FontWeight.bold,
              //     fontSize: 12,
              //   ),
              // ),
              //        const SizedBox(width: 8),
              //                   Icon(
              //                     Icons.local_print_shop_rounded,
              //                     size: 22,
              //                     color: colorScheme.primary,
              //                   ),
              //      ],
              //    ),
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

  // ---------- Card de fechas y detalles ----------
  Widget _datesCard(
    BuildContext context,
    double width,
    AdminHomeState adminHomeState,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final adminOrderChangeDeliveryTimeBloc = context
        .read<AdminOrderChangeDeliveryTimeBloc>();

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
              _dateItem(
                context,
                Icons.calendar_month_rounded,
                formatDateToYMD(adminHomeState.selectedOrder.initDate),
              ),
              const SizedBox(width: 7), // Espacio reducido entre fecha y hora
              _dateItem(
                context,
                Icons.access_time_rounded,
                formatTimeToAmPm(
                  adminHomeState.selectedOrder.initDate,
                  uppercaseSuffix: false,
                ),
              ),
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
                    Icon(
                      Icons.calendar_month_rounded,
                      color: colorScheme.primary,
                      size: 18,
                    ),
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
              _changeTimeButton(context, adminOrderChangeDeliveryTimeBloc),
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
                    _detailChip(
                      context,
                      label: adminHomeState.selectedOrder.format,
                    ),
                    _detailChip(
                      context,
                      label: adminHomeState.selectedOrder.isColor
                          ? 'Color'
                          : 'B/N',
                    ),
                    _detailChip(
                      context,
                      label: '${adminHomeState.selectedOrder.pages} pág',
                    ),
                  ],
                ),
              ),
              // Chip de método de pago a la derecha
              _paymentMethodChip(
                context,
                isCardPayment: !adminHomeState.selectedOrder.paymentMethod
                    .contains('cash'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _changeTimeButton(
    BuildContext context,
    AdminOrderChangeDeliveryTimeBloc bloc,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextButton.icon(
      onPressed: () => bloc.add(
        AdminOrderShowChangeDeliveryTimeEvent(
          showDeliveryTimeBottomSheet: true,
        ),
      ),
      icon: Icon(Icons.edit_calendar_rounded, size: 16),
      label: const Text('Cambiar', style: TextStyle(fontSize: 12)),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        backgroundColor: colorScheme.primary.withOpacity(0.1),
        foregroundColor: colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // ---------- Preview + botones ----------
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
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
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 1000),
                switchInCurve: Curves.fastLinearToSlowEaseIn,
                switchOutCurve: Curves.fastEaseInToSlowEaseOut,
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: adminHomeState.selectedOrder.printDate != null
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            key: ValueKey(
                              "printDate ${adminHomeState.selectedOrder.printDate}",
                            ),
                            'Imp.',
                            style: TextStyle(
                              color: colorScheme.inverseSurface,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.local_print_shop_rounded,
                            size: 18, // 18 en lugar de 20 para mejor proporción
                            color: colorScheme.primary,
                          ),
                        ],
                      )
                    : SizedBox.shrink(key: ValueKey("empty")),
              ),
            ],
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
          adminHomeState.selectedOrder.hasItBeenAccepted == false ||
                  adminHomeState.selectedOrder.hasItBeenAccepted == null
              ? _actionButtons(context, adminHomeState)
              : _deliveryAndPrintButtons(context, printPdf),
        ],
      ),
    );
  }

  void _decisionButtonHandle({
    required BuildContext context,
    required PendingOrderDecision pendingOrderDecision,
    required String title,
    required String message,
  }) {
    final adminHomeBloc = context.read<AdminHomeBloc>();
    adminHomeBloc.add(
      AdminHomeUpdateAdminHomeActionsEvent(
        adminHomeActions: AdminHomeActions.makePendingOrderDecision,
      ),
    );
    adminHomeBloc.add(
      AdminHomeUpdatePendingOrderDecisionEvent(
        pendingOrderDecision: pendingOrderDecision,
      ),
    );
    showSnackBar(
      context: context,
      title: title,
      text: message,
      showCancelButton: true,
    );
  }

  // ---------- Botones Aceptar / Rechazar ----------
  Widget _actionButtons(BuildContext context, AdminHomeState adminHomeState) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed:
                adminHomeState.pendingOrderStatus == PendingOrderStatus.loading
                ? () {}
                : () => _decisionButtonHandle(
                    context: context,
                    pendingOrderDecision: PendingOrderDecision.accept,
                    title: "Aceptar orden",
                    message: "¿Quieres aceptar esta orden?",
                  ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 2,
            ),
            child: MyAnimatedContentSwitcherButton(
              showLoad:
                  adminHomeState.pendingOrderStatus ==
                      PendingOrderStatus.loading &&
                  adminHomeState.pendingOrderDecision ==
                      PendingOrderDecision.accept,
              text: "Aceptar",
              textSize: 13,
              icon: Icons.check_rounded,
              iconSize: 18,
              loadingIndicatorSize: 24,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed:
                adminHomeState.pendingOrderStatus == PendingOrderStatus.loading
                ? () {}
                : () => _decisionButtonHandle(
                    context: context,
                    pendingOrderDecision: PendingOrderDecision.reject,
                    title: "Rechazar orden",
                    message: "¿Quieres rechazar esta orden?",
                  ),

            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 2,
            ),

            child: MyAnimatedContentSwitcherButton(
              showLoad:
                  adminHomeState.pendingOrderStatus ==
                      PendingOrderStatus.loading &&
                  adminHomeState.pendingOrderDecision ==
                      PendingOrderDecision.reject,
              text: "Rechazar",
              textSize: 13,
              icon: Icons.close_rounded,
              iconSize: 18,
              loadingIndicatorSize: 24,
            ),
          ),
        ),
      ],
    );
  }

  // ---------- Botones Entregar e Imprimir (cuando la orden está aceptada) ----------
  Widget _deliveryAndPrintButtons(BuildContext context, VoidCallback printPdf) {
    final colorScheme = Theme.of(context).colorScheme;
    final cloudStoragePdfState = context.watch<CloudStoragePdfBloc>().state;
    final isLoading =
        cloudStoragePdfState.cloudStoragePrintPdfStatus ==
        CloudStoragePrintPdfStatus.loading;

    return Row(
      children: [
        // Botón Entregar

        // Botón Imprimir
        Expanded(
          child: ElevatedButton(
            onPressed: isLoading ? () {} : printPdf,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 2,
            ),
            child: isLoading
                ? MyLoadingIndicator(color: Colors.white, size: 24)
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.print_rounded, size: 18),
                      SizedBox(width: 6),
                      Text(
                        "Imprimir",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: () => context.push(Routes.adminCodeValidationView),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 2,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.outbox, size: 18),
                SizedBox(width: 6),
                Text(
                  "Entregar",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ],
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
    onTap: () => context.push(Routes.adminSeeUserPaymentMethod),
    child: Container(

      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: backgroundColor.withOpacity(0.3)),
      ),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min, // Importante para que se ajuste al contenido
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  ),
                  child: child,
                );
              },
              child: Icon(
                icon,
                key: ValueKey<bool>(isCardPayment),
                size: 12,
                color: backgroundColor,
              ),
            ),
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
    ),
  );
}

  Widget _statusChip(bool accepted, bool hasItBeenCanceledByUser) {
  final bg = hasItBeenCanceledByUser
      ? Colors.red
      : accepted
          ? Colors.green
          : Colors.orange;

  final statusName = hasItBeenCanceledByUser
      ? 'Cancelada'
      : accepted
          ? 'Aceptada'
          : 'En revisión';

  final statusIcon = hasItBeenCanceledByUser
      ? Icons.cancel_rounded 
      : accepted
          ? Icons.check_circle_rounded 
          : Icons.access_time_rounded;

  return AnimatedContainer(
    duration: const Duration(milliseconds: 450),
    curve: Curves.easeInOut,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: bg.withOpacity(0.3),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ],
    ),
    child: AnimatedSize(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOut,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                ),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: Icon(
              statusIcon,
              key: ValueKey<String>(statusName),
              size: 12,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 4),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SizeTransition(
                  sizeFactor: animation,
                  axis: Axis.horizontal,
                  child: child,
                ),
              );
            },
            child: Text(
              statusName,
              key: ValueKey<String>(statusName),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}
