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
    final primary = Theme.of(context).colorScheme.primary;
    final messageErrorWarningBloc = context.read<MessageErrorWarningBloc>();
    final cloudStoragePdfViewBloc = context.read<CloudStoragePdfBloc>();

    void handleErrorToPrint(
      MessageErrorWarningBloc messageErrorWarningBloc,
      CloudStoragePdfBloc cloudStoragePdfViewBloc,
    ) {
      messageErrorWarningBloc.updateMessageErrorWarning(
        "Error de impresión",
        "No se pudo cargar el documento.",
      );
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
        if (state.cloudStoragePrintPdfStatus ==
            CloudStoragePrintPdfStatus.failure) {
          handleErrorToPrint(messageErrorWarningBloc, cloudStoragePdfViewBloc);
        }
      },
      child: BlocBuilder<AdminHomeBloc, AdminHomeState>(
        builder: (context, state) {
          void viewThePdf() {
            cloudStoragePdfViewBloc.fileFromCloudStorage(
              "1974238",
              "ModeloMatematicoCom.pdf",
            );
            context.push(Routes.cloudStoragePdfView);
          }

          void printPdf() {
            cloudStoragePdfViewBloc.printPdf(
              "1974238",
              "ModeloMatematicoCom.pdf",
            );
          }

          return Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: _myBody(
                  primary,
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
    Color primary,
    BuildContext context,
    double width,
    AdminHomeState state,
    void Function() viewThePdf,
    void Function() printPdf,
  ) {
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
                  "Orden #${adminHomeState.selectedOrder.orderCode}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: inverse,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.person_2, size: 18, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      adminHomeState.selectedOrder.userName,
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
                      Icons.badge_outlined,
                      size: 18,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      adminHomeState.selectedOrder.userRegistration,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.bold,
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
              _statusChip(adminHomeState.selectedOrder.hasItBeenCanceledByUser),
              const SizedBox(height: 8.5),
              Text(
                '\$ ${adminHomeState.selectedOrder.price.toStringAsFixed(2)}',
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
  Widget _datesCard(
    BuildContext context,
    double width,
    AdminHomeState adminHomeState,
  ) {
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
            formatDateToYMD(adminHomeState.selectedOrder.initDate),
            Icons.access_time_outlined,
            formatTimeToAmPm(
              adminHomeState.selectedOrder.initDate,
              uppercaseSuffix: false,
            ),
          ),
          const SizedBox(height: 16),
          _sectionLabel(context, 'ENTREGA ESTIMADA'),
          const SizedBox(height: 12),
          _dateRow(
            context,
            Icons.calendar_month,
            formatDateToYMD(
              adminHomeState.selectedOrder.estimatedDeliveryTime!,
            ),
            Icons.access_time_outlined,
            formatTimeToAmPm(
              adminHomeState.selectedOrder.estimatedDeliveryTime!,
              uppercaseSuffix: false,
            ),
          ),
          const SizedBox(height: 16),
          _sectionLabel(context, 'DETALLES'),
          const SizedBox(height: 8),
          Row(
            children: [
              _detailChip(context, label: adminHomeState.selectedOrder.format),
              const SizedBox(width: 10),
              _detailChip(
                context,
                label: adminHomeState.selectedOrder.isColor ? 'Color' : 'B/N',
              ),
              const SizedBox(width: 10),
              _detailChip(
                context,
                label: '${adminHomeState.selectedOrder.pages} pág',
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
    AdminHomeState adminHomeState,
    VoidCallback viewThePdf,
    VoidCallback printPdf,
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
                          adminHomeState.selectedOrder.pdfName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${adminHomeState.selectedOrder.pages} páginas',
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

          const SizedBox(height: 15),

          _printButton(context, printPdf),
        ],
      ),
    );
  }

  // ---------- Botón grande "Imprimir" que reemplaza a Aceptar/Rechazar ----------
 Widget _printButton(BuildContext context, VoidCallback printPdf) {
  final primaryColor = Theme.of(context).colorScheme.primary;
  final cloudStoragePdfState = context.watch<CloudStoragePdfBloc>().state;
  final isLoading = cloudStoragePdfState.cloudStoragePrintPdfStatus == CloudStoragePrintPdfStatus.loading;

  return Row(
    children: [
      Expanded(
        child: ElevatedButton(
          onPressed: isLoading ? (){} : printPdf,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            // Altura fija para mantener el tamaño constante
          ),
          child: _animatedSwitcherButton(context, primaryColor, isLoading),
        ),
      ),
    ],
  );
}

AnimatedSwitcher _animatedSwitcherButton(
  BuildContext context,
  Color primaryColor,
  bool isLoading,
) {
  return AnimatedSwitcher(
    duration: const Duration(milliseconds: 180),
    switchInCurve: Curves.easeOut,
    switchOutCurve: Curves.easeIn,
    layoutBuilder: (currentChild, previousChildren) {
      return Stack(
        alignment: Alignment.center,
        children: <Widget>[
          ...previousChildren,
          if (currentChild != null) currentChild,
        ],
      );
    },
    transitionBuilder: (child, animation) {
      final fade = FadeTransition(opacity: animation, child: child);
      final scale = ScaleTransition(
        scale: Tween<double>(
          begin: 0.97,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
        child: fade,
      );
      return scale;
    },
    child: isLoading
        ? MyLoadingIndicator(
          key: ValueKey('print_loader'),
          color: Colors.white,
          size: 54, // Tamaño consistente
        )
        : Padding(
           padding: const EdgeInsets.symmetric(vertical: 14),
          key: const ValueKey('print_text'),
          child: Row(
              key: const ValueKey('print_text'),
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.print, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Imprimir',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
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
