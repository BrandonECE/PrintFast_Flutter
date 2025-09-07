import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:printfast_rebuild/config/routes/routes.dart';
import 'package:printfast_rebuild/presentation/blocs/shared_blocs/cloud_storage_pdf_bloc.dart/cloud_storage_pdf_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/user_blocs/home_bloc/home_bloc.dart';
import 'package:printfast_rebuild/presentation/widgets/appbar_widget.dart';
import 'package:printfast_rebuild/utils/format_date_to_ymd.dart';
import 'package:printfast_rebuild/utils/format_time_to_am_pm.dart';

/// MyHistoryOrderPureDesign
/// Solo DISEÑO: StatelessWidget, sin parámetros, sin lógica.
/// Variables internas con ejemplo de orderHistoryInfo y productos.
/// Métodos privados para construir cada bloque (igual estructura del original).
class MyOrderHistoryView extends StatelessWidget {
  const MyOrderHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final primary = Theme.of(context).colorScheme.primary;

    final cloudStoragePdfViewBloc = context.read<CloudStoragePdfBloc>();

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        void viewThePdf() {
          cloudStoragePdfViewBloc.fileFromCloudStorage(
            "1974238",
            "ModeloMatematicoCom.pdf",
          );
          context.push(Routes.cloudStoragePdfView);
        }

        return Scaffold(
          backgroundColor: primary,
          appBar: MyAppBarWidget(
            title: 'Detalle de orden',
            leadingIcon: Icons.receipt_long,
            leadingIconSize: 24,
            actionIcon: Icons.close_sharp,
            actionIconSize: 22,
            onAction: () => context.canPop() ? context.pop() : null,
          ),
          body: Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: width * 0.025),
              child: Column(
                children: [
                  _topCard(context, width, state),
                  SizedBox(height: width * 0.03),
                  _datesCard(context, width, state),
                  SizedBox(height: width * 0.03),
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
    final inverse = Theme.of(context).colorScheme.inverseSurface;

    return Container(
      width: width * 0.95,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
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
                  "Orden #${homeState.selectedOrder.orderCode}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: inverse,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_sharp,
                      size: 18,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      homeState.selectedOrder.place,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.picture_as_pdf_outlined,
                      size: 18,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text(
                          homeState.selectedOrder.pdfName,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Estado (aceptada / pendiente) + precio
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _statusChip(homeState.selectedOrder.hasItBeenCanceledByUser),
              const SizedBox(height: 8.5),
              Text(
                '\$ ${homeState.selectedOrder.price.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inverseSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- Card de fechas y detalles ----------
  Widget _datesCard(BuildContext context, double width, HomeState homeState) {
    // final borderAndShadow = !hasItBeenAccepted
    //     ? BoxDecoration(
    //         color: Colors.white,
    //         borderRadius: const BorderRadius.all(Radius.circular(16)),
    //         border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.9), width: 1.2),
    //         boxShadow: [
    //           BoxShadow(
    //             color: Theme.of(context).colorScheme.primary.withOpacity(0.06),
    //             blurRadius: 6,
    //             offset: const Offset(0, 2),
    //           ),
    //         ],
    //       )
    //     : const BoxDecoration(
    //         color: Colors.white,
    //         borderRadius: BorderRadius.all(Radius.circular(16)),
    //       );

    final borderAndShadow = const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(16)),
    );

    return Container(
      width: width * 0.95,
      padding: const EdgeInsets.all(16),
      decoration: borderAndShadow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel(context, 'ORDENADO'),
          const SizedBox(height: 8),
          _dateRow(
            context,
            Icons.calendar_month,
            formatDateToYMD(homeState.selectedOrder.initDate),
            Icons.access_time_outlined,
            formatTimeToAmPm(
              homeState.selectedOrder.initDate,
              uppercaseSuffix: false,
            ),
          ),
          const SizedBox(height: 16),
          _sectionLabel(context, 'ENTREGA ESTIMADA'),
          const SizedBox(height: 12),
          _dateRow(
            context,
            Icons.calendar_month,
            formatDateToYMD(homeState.selectedOrder.estimatedDeliveryTime!),
            Icons.access_time_outlined,
            formatTimeToAmPm(
              homeState.selectedOrder.estimatedDeliveryTime!,
              uppercaseSuffix: false,
            ),
          ),
          const SizedBox(height: 16),
          _sectionLabel(context, 'DETALLES'),
          const SizedBox(height: 8),
          Row(
            children: [
              _detailChip(context, label: homeState.selectedOrder.format),
              const SizedBox(width: 10),
              _detailChip(
                context,
                label: homeState.selectedOrder.isColor ? 'Color' : 'B/N',
              ),
              const SizedBox(width: 10),
              _detailChip(
                context,
                label: '${homeState.selectedOrder.pages} pág',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- Preview + botones ----------
  Widget _previewCard(
    BuildContext context,
    double width,
    HomeState homeState,
    VoidCallback viewThePdf,
  ) {
    final inverse = Theme.of(context).colorScheme.inverseSurface;

    return Container(
      width: width * 0.95,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Previsualización',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: inverse,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.picture_as_pdf,
                      size: 56,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text(
                          textAlign: TextAlign.center,
                          homeState.selectedOrder.pdfName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${homeState.selectedOrder.pages} páginas',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: viewThePdf,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.visibility, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Visualizar',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String title) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.inverseSurface,
          ),
        ),
        const SizedBox(width: 6),
        const Icon(Icons.arrow_drop_down, size: 20),
      ],
    );
  }

  // Método reutilizable para mostrar fecha + hora (izq/derecha)
  Widget _dateRow(
    BuildContext context,
    IconData leftIcon,
    String leftText,
    IconData rightIcon,
    String rightText,
  ) {
    final inverse = Theme.of(context).colorScheme.inverseSurface;
    return Row(
      children: [
        Row(
          children: [
            Icon(leftIcon),
            const SizedBox(width: 8),
            Text(
              leftText,
              style: TextStyle(color: inverse, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(width: 18),
        Row(
          children: [
            Icon(rightIcon),
            const SizedBox(width: 8),
            Text(
              rightText,
              style: TextStyle(color: inverse, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _detailChip(BuildContext context, {required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.grey.shade800,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _statusChip(bool canceled) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: canceled ? Colors.redAccent : Colors.greenAccent.shade400,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            canceled ? Icons.cancel : Icons.check_circle,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            canceled ? 'Cancelada' : 'Completada',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
