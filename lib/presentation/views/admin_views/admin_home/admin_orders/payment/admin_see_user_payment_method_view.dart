import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:printfast_rebuild/di/service_locator.dart';
import 'package:printfast_rebuild/domain/entities/all_entities/card_payment_method_entity.dart';
import 'package:printfast_rebuild/domain/repositories/admin_repository.dart';
import 'package:printfast_rebuild/presentation/blocs/admin_blocs/admin_home_bloc/admin_home_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/admin_blocs/payment_blocs/admin_user_payment_method_bloc/admin_user_payment_method_bloc.dart';
import 'package:printfast_rebuild/presentation/widgets/widgets.dart';

class MyAdminSeeUserPaymentMethodView extends StatelessWidget {
  const MyAdminSeeUserPaymentMethodView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;

    // Obtener la orden actual del AdminHomeBloc
    final adminHomeState = context.read<AdminHomeBloc>().state;
    final registration = adminHomeState.selectedOrder.userRegistration;
    final paymentMethodId = adminHomeState.selectedOrder.paymentMethod;

    return BlocListener<AdminHomeBloc, AdminHomeState>(
      listenWhen: (prev, curr) => prev.archivingAcceptedOrderAfterBeingaCancelledByTheUserStatus !=
              curr.archivingAcceptedOrderAfterBeingaCancelledByTheUserStatus ||
          prev.selectedOrder.hasItBeenCanceledByUser !=
              curr.selectedOrder.hasItBeenCanceledByUser,
      listener: (context, state) {
        if (state.selectedOrder.hasItBeenCanceledByUser == true && state .archivingAcceptedOrderAfterBeingaCancelledByTheUserStatus == ArchivingAcceptedOrderAfterBeingCanceledByTheUserStatus.idle) {
          context.pop();
        }
      },
      child: BlocProvider(
        create: (context) => AdminSeeUserPaymentMethodBloc(
          adminRepository: getIt<AdminRepository>(),
          registration: registration,
          paymentMethodId: paymentMethodId,
        )..add(const LoadUserPaymentMethod()),
        child: Scaffold(
          backgroundColor: colorScheme.primary,
          appBar: _myAppBar(context),
          body: Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: width * 0.025),
              child: Container(
                width: width * 0.95,
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
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _headerSection(colorScheme),
                          const SizedBox(height: 20),
                          _paymentMethodDisplay(context),
                          const SizedBox(height: 20),
                          _infoSection(context),
                        ],
                      ),
                      // Botón de cerrar en la parte inferior
                      _closeButton(context, colorScheme),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  MyAppBarWidget _myAppBar(BuildContext context) {
    return MyAppBarWidget(
      title: "Método de pago",
      leadingIcon: Icons.credit_card_rounded,
      leadingIconSize: 24,
      actionIcon: Icons.close_rounded,
      actionIconSize: 25,
      onAction: () => context.pop(),
    );
  }

  Widget _headerSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Método de pago del usuario",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colorScheme.inverseSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Método con el que el usuario pagó esta orden",
          style: TextStyle(
            fontSize: 13,
            color: colorScheme.inverseSurface.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _paymentMethodDisplay(BuildContext context) {
    return BlocBuilder<
      AdminSeeUserPaymentMethodBloc,
      AdminSeeUserPaymentMethodState
    >(
      builder: (context, state) {
        return AnimatedSize(
          alignment: Alignment.topCenter,
          duration: const Duration(milliseconds: 815),
          curve: Curves.fastLinearToSlowEaseIn,
          clipBehavior: Clip.hardEdge, // evita overflow visual
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 225),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (Widget child, Animation<double> animation) {
              // puedes usar slide+fade si quieres, aquí solo fade por simplicidad
              return FadeTransition(opacity: animation, child: child);
            },
            layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
              return Stack(
                alignment: Alignment.topCenter,
                children: <Widget>[
                  // previousChildren posicionados para NO afectar el tamaño del Stack
                  ...previousChildren.map((w) => Positioned.fill(child: w)),
                  // currentChild, no posicionado, determina el tamaño del Stack
                  if (currentChild != null) currentChild,
                ],
              );
            },
            // _contentForState ya devuelve KeyedSubtree con ValueKey(...) — perfecto
            child: _contentForState(state, context),
          ),
        );
      },
    );
  }

  Widget _contentForState(
    AdminSeeUserPaymentMethodState state,
    BuildContext context,
  ) {
    switch (state.status) {
      case AdminSeeUserPaymentMethodStatus.loading:
        return KeyedSubtree(
          key: const ValueKey('loading'),
          child: _buildLoadingContent(),
        );

      case AdminSeeUserPaymentMethodStatus.failure:
        return KeyedSubtree(
          key: const ValueKey('failure'),
          child: _buildErrorContent(
            state.error ?? 'Error desconocido',
            context,
          ),
        );

      case AdminSeeUserPaymentMethodStatus.success:
        return KeyedSubtree(
          key: const ValueKey('success'),
          child: _buildSuccessContent(state, context),
        );
    }
  }

  Widget _buildLoadingContent() {
    return const Center(child: SizedBox(child: MyLoadingIndicator()));
  }

  Widget _buildErrorContent(String message, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icono compacto
            Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.12),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 32,
                color: colorScheme.primary,
              ),
            ),

            const SizedBox(height: 12),

            // Título
            Text(
              'Error al cargar',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.inverseSurface,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 6),

            // Mensaje
            Text(
              message.isNotEmpty ? message : 'Revisa tu conexión',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.inverseSurface.withOpacity(0.78),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 14),

            // Botón reintentar que dispara evento al bloc
            ElevatedButton(
              onPressed: () {
                context.read<AdminSeeUserPaymentMethodBloc>().add(
                  const LoadUserPaymentMethod(),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: const Size(0, 38),
              ),
              child: const Text(
                'Reintentar',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessContent(
    AdminSeeUserPaymentMethodState state,
    BuildContext context,
  ) {
    if (state.paymentMethod == 'cash') {
      return _buildCashMethod();
    } else if (state.paymentMethod == 'card' && state.card != null) {
      return _buildCardMethod(state.card!);
    } else {
      return _buildNotFoundMethod();
    }
  }

  Widget _buildCashMethod() {
    return _buildPaymentItem(
      icon: Icons.money_rounded,
      title: "Efectivo",
      subtitle: "Pago al recibir el pedido",
      color: Colors.orange,
    );
  }

  Widget _buildCardMethod(CardPaymentMethodEntity card) {
    return _buildPaymentItem(
      icon: Icons.credit_card_rounded,
      title: "**** **** **** ${card.last4}",
      subtitle: "${card.brand} • Vence ${card.expMonth}/${card.expYear}",
      color: Colors.blue,
    );
  }

  Widget _buildNotFoundMethod() {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          children: [
            // Icono de error
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withOpacity(0.1),
                border: Border.all(color: Colors.red, width: 2),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: Colors.red,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),

            // Icono del método
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.credit_card_off_rounded,
                color: Colors.red,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Información
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Método no disponible",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "El método de pago actual no se encuentra disponible",
                    style: TextStyle(fontSize: 12, color: Colors.red.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              children: [
                // Icono del método
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),

                // Información
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Badge a la derecha
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: Text(
              "Activo",
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.1),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: colorScheme.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                "Información",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.inverseSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Este es el método de pago que el usuario seleccionó para esta orden. "
            "Si el usuario cambia su método de pago, esta pantalla se actualizará la próxima vez que la veas.",
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.inverseSurface.withOpacity(0.7),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _closeButton(BuildContext context, ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => context.pop(),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary.withOpacity(0.9),
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 1,
        ),
        icon: const Icon(Icons.arrow_back_rounded, size: 20),
        label: const Text(
          'Volver a la orden',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
