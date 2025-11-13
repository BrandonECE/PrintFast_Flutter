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

    return BlocConsumer<HomeBloc, HomeState>(
      listenWhen: (prev, curr) => prev.homeOrderStatus != curr.homeOrderStatus,
      listener: (context, state) {
        if (state.homeOrderStatus == HomeOrderStatus.orderCompleted &&
            state.activeOrder?.hasItBeenCompleted == true &&
            !state.isLoadingTheOrderBeingArchivedAndCompleted) {
          context.go(Routes.home);
        }
      },
      builder: (context, state) {
        void viewThePdf() {
          cloudStoragePdfViewBloc.fileFromCloudStorage(
            state.activeOrder == null ? "" : state.activeOrder!.url,
          );
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

    final isActive = homeState.activeOrder!.hasItBeenAccepted == null
        ? false
        : true;
    final hasItBeenCanceledByUser =
        homeState.activeOrder!.hasItBeenCanceledByUser;

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
              _statusChip(isActive, hasItBeenCanceledByUser),
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
    final isReady = homeState.activeOrderProgress == 1.0;
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _dateItemPrimary(
                    context,
                    // homeState.activeOrderProgress == 1.0 ? Colors.green.shade500 : colorScheme.primary,
                    colorScheme.primary,
                    Icons.calendar_month_rounded,
                    formatDateToYMD(
                      homeState.activeOrder!.estimatedDeliveryTime!,
                    ),
                  ),
                  const SizedBox(width: 7),
                  _dateItemPrimary(
                    context,
                    // homeState.activeOrderProgress == 1.0 ? Colors.green.shade500 : colorScheme.primary,
                    colorScheme.primary,
                    Icons.access_time_rounded,
                    formatTimeToAmPm(
                      homeState.activeOrder!.estimatedDeliveryTime!,
                      uppercaseSuffix: false,
                    ),
                  ),
                ],
              ),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 275),
                switchInCurve: Curves.easeOutQuart,
                switchOutCurve: Curves.easeInSine,
                transitionBuilder: (child, animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(-0.3, 0), // Entra desde arriba
                      end: Offset.zero,
                    ).animate(animation),
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: isReady
                    ? Padding(
                        key: const ValueKey('ready_status'),
                        padding: const EdgeInsets.only(right: 3.5),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 16,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '¡Listo!',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(key: ValueKey('empty_status')),
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
              _paymentMethodChip(
                context,
                isCardPayment: !homeState.activeOrder!.paymentMethod.contains(
                  "cash",
                ),
              ),
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
  Widget _dateItemPrimary(
    BuildContext context,
    Color color,
    IconData icon,
    String text,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: color,
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
                child: homeState.activeOrder?.printDate != null
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            key: ValueKey(
                              "printDate ${homeState.activeOrder?.printDate}",
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
          _actionButtonsRow(context, showCodeButton, homeState),
        ],
      ),
    );
  }

  // ---------- Fila de botones de acción ----------
  Widget _actionButtonsRow(
    BuildContext context,
    bool showCodeButton,
    HomeState homeState,
  ) {
    final isReady = homeState.activeOrderProgress == 1.0;
    final isOrderPendingOrRejected =
        homeState.activeOrder?.hasItBeenAccepted == null ||
        homeState.activeOrder?.hasItBeenAccepted == false;

    return Column(
      children: [
        if (!isOrderPendingOrRejected) const SizedBox(height: 16),
        AnimatedSize(
          duration: const Duration(milliseconds: 275),
          curve: Curves.easeOutQuart,
          alignment: Alignment.topCenter,
          child: isOrderPendingOrRejected
              ? const SizedBox.shrink() // Desaparece completamente
              : AnimatedSwitcher(
                  duration: const Duration(milliseconds: 275),
                  switchInCurve: Curves.easeOutQuart,
                  switchOutCurve: Curves.easeInSine,
                  transitionBuilder: (child, animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.5, 0.0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: isReady
                      ? Row(
                          key: const ValueKey('with_code'),
                          children: [
                            Expanded(
                              flex: 1,
                              child: _liveTrackingButton(context, isReady),
                            ),
                            const SizedBox(width: 12),
                            Expanded(flex: 1, child: _viewCodeButton(context)),
                          ],
                        )
                      : Row(
                          key: const ValueKey('without_code'),
                          children: [
                            Expanded(
                              child: _liveTrackingButton(context, isReady),
                            ),
                          ],
                        ),
                ),
        ),
      ],
    );
  }

  // ---------- Botón de seguimiento en vivo ----------
  Widget _liveTrackingButton(BuildContext context, bool isReady) {
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
      label: Text(
        isReady ? 'Ver Seg.' : "Ver seguimiento", //Ver Seguimiento
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
        child: AnimatedSize(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize:
                MainAxisSize.min, // Importante para que se ajuste al contenido
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
                  child: FadeTransition(opacity: animation, child: child),
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
