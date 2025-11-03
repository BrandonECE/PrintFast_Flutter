import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:printfast_rebuild/config/routes/routes.dart';
import 'package:printfast_rebuild/di/service_locator.dart';
import 'package:printfast_rebuild/domain/entities/all_entities/aorder_entity.dart';
import 'package:printfast_rebuild/domain/entities/all_entities/card_payment_method_entity.dart';
import 'package:printfast_rebuild/domain/repositories/user_repository.dart';
import 'package:printfast_rebuild/presentation/blocs/shared_blocs/message_error_warning_bloc/message_error_warning_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/user_blocs/home_bloc/home_bloc.dart';

import 'package:printfast_rebuild/presentation/blocs/user_blocs/payment_blocs/change_payment_method_bloc/change_payment_method_bloc.dart';
import 'package:printfast_rebuild/presentation/widgets/widgets.dart';

import '../../../../../../utils/utils.dart';

class MyChangePaymentMethodView extends StatelessWidget {
  const MyChangePaymentMethodView({super.key});

  @override
  Widget build(BuildContext context) {
    final homeBlocState = context.watch<HomeBloc>().state;
    final currentPaymentMethodId = homeBlocState.activeOrder!.paymentMethod;
    final registration = homeBlocState.userEntity.registration;

    return _myChangePaymentMethodScreen(
      homeBlocState.activeOrder,
      registration,
      currentPaymentMethodId,
      context,
    );
  }

  BlocProvider<ChangePaymentMethodBloc> _myChangePaymentMethodScreen(
    AorderEntity? activeOrder,
    String registration,
    String currentPaymentMethodId,
    BuildContext context,
  ) {
    final messageErrorWarningBloc = context.read<MessageErrorWarningBloc>();

    return BlocProvider(
      create: (context) =>
          ChangePaymentMethodBloc(
            userRepository: getIt<UserRepository>(),
            registration: registration,
            currentPaymentMethodId: currentPaymentMethodId,
          )..add(
            LoadPaymentMethods(currentPaymentMethodId: currentPaymentMethodId),
          ),

      child: BlocBuilder<ChangePaymentMethodBloc, ChangePaymentMethodState>(
        buildWhen: (prev, curr) => prev.changeStatus != curr.changeStatus,
        builder: (context, state) {
          return Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: _ChangePaymentMethodViewContent(),
              ),
              MyMessageErrorWarning(
                voidCallback: () {
                  if (state.changeStatus ==
                          ChangePaymentMethodActionStatus.idle &&
                      activeOrder != null) {
                    context.read<ChangePaymentMethodBloc>().add(
                      ConfirmChange(
                        userRegistration: activeOrder.userRegistration,
                        copyShopEmail: activeOrder.copyShopEmail,
                        orderCode: activeOrder.orderCode,
                      ),
                    );
                  } else if (state.changeStatus ==
                      ChangePaymentMethodActionStatus.failure) {
                    context.read<ChangePaymentMethodBloc>().add(
                      ChangePaymentMethodActionStatusEvent(
                        changePaymentMethodActionStatus:
                            ChangePaymentMethodActionStatus.idle,
                      ),
                    );
                  }

                  messageErrorWarningBloc.add(
                    ShowMessageErrorWarningEvent(
                      showMessageErrorWarning: false,
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ChangePaymentMethodViewContent extends StatelessWidget {
  const _ChangePaymentMethodViewContent();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _headerSection(colorScheme),
                  const SizedBox(height: 20),
                  Expanded(child: _paymentMethodsList(context)),
                  const SizedBox(height: 16),
                  _openCardSettingsButton(context, colorScheme),
                  const SizedBox(height: 18),
                  _changeButton(context, colorScheme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  MyAppBarWidget _myAppBar(BuildContext context) {
    return MyAppBarWidget(
      title: "Cambiar pago",
      leadingIcon: Icons.credit_card_rounded,
      leadingIconSize: 24,
      actionIcon: Icons.close_rounded,
      actionIconSize: 25,
      onAction: () => context.canPop() ? context.pop() : null,
    );
  }

  Widget _headerSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Cambiar método de pago",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colorScheme.inverseSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Selecciona un nuevo método de pago para tu orden",
          style: TextStyle(
            fontSize: 13,
            color: colorScheme.inverseSurface.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _paymentMethodsList(BuildContext context) {
    return BlocBuilder<ChangePaymentMethodBloc, ChangePaymentMethodState>(
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 225),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: _contentForState(state, context),
        );
      },
    );
  }

  Widget _contentForState(
    ChangePaymentMethodState state,
    BuildContext context,
  ) {
    switch (state.status) {
      case ChangePaymentMethodStatus.initial:
      case ChangePaymentMethodStatus.loading:
        return KeyedSubtree(
          key: const ValueKey('loading'),
          child: _buildLoadingContent(),
        );

      case ChangePaymentMethodStatus.failure:
        return KeyedSubtree(
          key: const ValueKey('failure'),
          child: _buildErrorContent(
            state.error ?? 'Error desconocido',
            context,
          ),
        );

      case ChangePaymentMethodStatus.success:
        return KeyedSubtree(
          key: const ValueKey('success'),
          child: _buildSuccessContent(state, context),
        );
    }
  }

  Widget _buildLoadingContent() {
    return const Center(child: MyLoadingIndicator());
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
                final currentMethodId = context
                    .read<ChangePaymentMethodBloc>()
                    .state
                    .currentMethodId;
                if (currentMethodId != null) {
                  context.read<ChangePaymentMethodBloc>().add(
                    LoadPaymentMethods(currentPaymentMethodId: currentMethodId),
                  );
                }
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
    ChangePaymentMethodState state,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Método actual
        _currentMethodSection(state, context),

        const SizedBox(height: 20),

        // Separador
        Container(height: 1, color: Colors.grey.shade300),

        const SizedBox(height: 20),

        // Métodos disponibles
        _availableMethodsSection(state, context),
      ],
    );
  }

  Widget _currentMethodSection(
    ChangePaymentMethodState state,
    BuildContext context,
  ) {
    final currentMethodId = state.currentMethodId;
    final currentMethodCard = state.currentMethodCard;

    Widget currentMethodWidget;

    if (currentMethodId == 'cash') {
      currentMethodWidget = _buildCashMethod(true, state, false);
    } else if (currentMethodCard != null) {
      currentMethodWidget = _buildCardMethod(
        currentMethodCard,
        true,
        false,
        () {},
      );
    } else {
      // Método no encontrado
      currentMethodWidget = _buildNotFoundMethod();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Método actual",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(
              context,
            ).colorScheme.inverseSurface.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 12),
        currentMethodWidget,
      ],
    );
  }

  Widget _availableMethodsSection(
    ChangePaymentMethodState state,
    BuildContext context,
  ) {
    
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Seleccionar nuevo método",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(
                context,
              ).colorScheme.inverseSurface.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: ListView(
              children: [
                // Opción de efectivo (solo si no es el método actual)
                if (state.currentMethodId != 'cash') ...[
                  _buildCashMethod(
                    state.selectedMethodId == 'cash',
                    state,
                    false,
                    onTap: () {
                      context.read<ChangePaymentMethodBloc>().add(
                        const SelectPaymentMethod('cash'),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                ],

                // Tarjetas disponibles
                if (state.savedCards.isNotEmpty) ...[
                  ...state.savedCards.map((card) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildCardMethod(
                        card,
                        state.selectedMethodId == card.token,
                        false,
                        () {
                          context.read<ChangePaymentMethodBloc>().add(
                            SelectPaymentMethod(card.token),
                          );
                        },
                      ),
                    );
                  }),
                ] else if (state.currentMethodId == 'cash') ...[
                  // Solo mostrar placeholder si no hay tarjetas y el método actual es cash
                  _noCardsPlaceholder(context),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCashMethod(
    bool isSelected,
    ChangePaymentMethodState state,
    bool isCurrent, {
    VoidCallback? onTap,
  }) {
    for (var element in state.savedCards) {
      print("${element.brand} : isDeafult: ${element.isDefault}");
    }
    return _buildPaymentMethod(
      id: 'cash',
      icon: Icons.money_rounded,
      title: "Efectivo",
      subtitle: "Paga al recibir tu pedido",
      color: Colors.orange,
      isDefault: !state.savedCards.any((card) => card.isDefault) && !state.currentMethodCard!.isDefault,
      isSelected: isSelected,
      isCurrent: isCurrent,
      onTap: onTap,
    );
  }

  Widget _buildCardMethod(
    CardPaymentMethodEntity card,
    bool isSelected,
    bool isCurrent,
    VoidCallback onTap,
  ) {
    return _buildPaymentMethod(
      id: card.token,
      icon: Icons.credit_card_rounded,
      title: "**** **** **** ${card.last4}",
      subtitle: "${card.brand} • Vence ${card.expMonth}/${card.expYear}",
      color: Colors.blue,
      isSelected: isSelected,
      isCurrent: isCurrent,
      isDefault: card.isDefault == true,
      onTap: onTap,
    );
  }

  // NUEVO: Widget para método no encontrado
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

  Widget _buildPaymentMethod({
    required String id,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isSelected,
    required bool isCurrent,
    bool isDefault = false,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isCurrent ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isCurrent
                ? color.withOpacity(0.15)
                : isSelected
                ? color.withOpacity(0.1)
                : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCurrent
                  ? color
                  : isSelected
                  ? color
                  : Colors.grey.shade300,
              width: isCurrent ? 2.0 : 1.5,
            ),
          ),
          child: Row(
            children: [
              // Indicador de selección/actual
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCurrent
                        ? color
                        : isSelected
                        ? color
                        : Colors.grey.shade400,
                    width: 2,
                  ),
                  color: isCurrent || isSelected ? color : Colors.transparent,
                ),
                child: isCurrent || isSelected
                    ? Icon(
                        isCurrent
                            ? Icons.check_circle_rounded
                            : Icons.check_rounded,
                        color: Colors.white,
                        size: 16,
                      )
                    : null,
              ),
              const SizedBox(width: 12),

              // Icono del método
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),

              // Información
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    if (isDefault) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
                          ),
                        ),
                        child: const Text(
                          "Predet.",
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _noCardsPlaceholder(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1.2),
      ),
      child: Column(
        children: [
          Icon(
            Icons.credit_card_off_rounded,
            size: 32,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            "No tienes tarjetas guardadas",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Agrega una tarjeta para pagar con ella",
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _openCardSettingsButton(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(
          Routes.manageCards,
           extra: {
            'passedBloc': context.read<ChangePaymentMethodBloc>(),
            'voidCallBack': null
          }
        
        ),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1.2),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.settings, color: Colors.blue, size: 16),
              SizedBox(width: 8),
              Text(
                "Administrar tarjetas",
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _changeButton(BuildContext context, ColorScheme colorScheme) {
    return BlocConsumer<ChangePaymentMethodBloc, ChangePaymentMethodState>(
      listener: (context, state) {
        if (state.changeStatus == ChangePaymentMethodActionStatus.success) {
          // Navegar hacia atrás cuando el cambio sea exitoso
          context.pop();
        } else if (state.changeStatus ==
            ChangePaymentMethodActionStatus.failure) {
          print("error");
          _thereWasAnError(context, state);
        }
      },
      builder: (context, state) {
        final isMethodSelected = state.selectedMethodId != null;
        final isDifferentFromCurrent =
            state.selectedMethodId != state.currentMethodId;
        final showLoad =
            state.changeStatus == ChangePaymentMethodActionStatus.loading ||
            state.changeStatus == ChangePaymentMethodActionStatus.success;
        final isEnabled =
            isMethodSelected && isDifferentFromCurrent && !showLoad;

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isEnabled
                ? () {
                    showSnackBar(
                      context: context,
                      title: "¿Cambiar método de pago?",
                      text: "Cambiará el método actual.",
                      showCancelButton: true,
                    );
                  }
                : showLoad
                ? () {}
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: MyAnimatedContentSwitcherButton(
              showLoad: showLoad,
              text: "Cambiar método de pago",
              icon: Icons.swap_horiz_rounded,
            ),
          ),
        );
      },
    );
  }

  void _thereWasAnError(BuildContext context, ChangePaymentMethodState state) {
    showSnackBar(
      context: context,
      title: "¡Error inesperado!",
      text: state.error ?? "",
    );
  }
}
