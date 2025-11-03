import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:printfast_rebuild/config/routes/routes.dart';
import 'package:printfast_rebuild/di/service_locator.dart';
import 'package:printfast_rebuild/domain/repositories/user_repository.dart';
import 'package:printfast_rebuild/domain/entities/all_entities/card_payment_method_entity.dart';
import 'package:printfast_rebuild/presentation/blocs/shared_blocs/message_error_warning_bloc/message_error_warning_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/user_blocs/home_bloc/home_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/user_blocs/payment_blocs/pay_outstanding_bloc/pay_outstanding_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/user_blocs/payment_blocs/shopping_pay_method_bloc/shopping_pay_method_bloc.dart';
import 'package:printfast_rebuild/presentation/widgets/widgets.dart';
import 'package:printfast_rebuild/utils/utils.dart';

class PayOutstandingView extends StatelessWidget {
  const PayOutstandingView({super.key, required this.extra});
  final double extra; // monto del saldo pendiente

  @override
  Widget build(BuildContext context) {
    return _payOutstandingScreen(context, extra);
  }

  BlocProvider<PayOutstandingBloc> _payOutstandingScreen(
    BuildContext context,
    double outstandingAmount,
  ) {
    final homeBlocState = context.read<HomeBloc>().state;
    final registration = homeBlocState.userEntity.registration;

    return BlocProvider(
      create: (context) => PayOutstandingBloc(
        userRepository: getIt<UserRepository>(),
        registration: registration,
      )..add(const LoadCardsForOutstanding()),
      child: BlocBuilder<PayOutstandingBloc, PayOutstandingState>(
        buildWhen: (prev, curr) => prev.paymentStatus != curr.paymentStatus,
        builder: (context, state) {
          final messageErrorWarningBloc = context
              .read<MessageErrorWarningBloc>();
          return Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: _PayOutstandingViewContent(
                  outstandingAmount: outstandingAmount,
                ),
              ),
              MyMessageErrorWarning(
                voidCallbackByCloseIcon: () {
                  if (state.paymentStatus == ActionOutstandingStatus.failure) {
                    context.read<PayOutstandingBloc>().add(
                      ChangePayOutstandingStatus(
                        paymentStatus: ActionOutstandingStatus.idle,
                      ),
                    );
                  }
                  messageErrorWarningBloc.add(
                    ShowMessageErrorWarningEvent(
                      showMessageErrorWarning: false,
                    ),
                  );
                },
                voidCallback: () {
                  if (state.paymentStatus == ActionOutstandingStatus.idle) {
                    context.read<PayOutstandingBloc>().add(
                      PayOutstandingAmount(
                        amount: outstandingAmount,
                        userRegistration: registration,
                      ),
                    );
                  } else if (state.paymentStatus ==
                      ActionOutstandingStatus.failure) {
                    context.read<PayOutstandingBloc>().add(
                      ChangePayOutstandingStatus(
                        paymentStatus: ActionOutstandingStatus.idle,
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

class _PayOutstandingViewContent extends StatelessWidget {
  const _PayOutstandingViewContent({required this.outstandingAmount});
  final double outstandingAmount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      appBar: _myAppBar(context),
      body: BlocListener<PayOutstandingBloc, PayOutstandingState>(
        listenWhen: (prev, curr) => prev.paymentStatus != curr.paymentStatus,
        listener: (context, state) {
          // Navegar SOLO cuando el proceso de pago haya terminado con éxito
          if (state.paymentStatus == ActionOutstandingStatus.success) {
            context.pop();
          }
          // Errores de pago
          else if (state.paymentStatus == ActionOutstandingStatus.failure &&
              state.paymentError != null) {
            _thereWasAnError(context, state);
          }
        },
        child: _myBody(width, context, outstandingAmount),
      ),
    );
  }

  void _thereWasAnError(BuildContext context, PayOutstandingState state) {
    showSnackBar(
      context: context,
      title: "¡Error inesperado!",
      text: state.paymentError ?? "",
    );
  }

  MyAppBarWidget _myAppBar(BuildContext context) {
    return MyAppBarWidget(
      title: "Pagar saldo pendiente",
      leadingIcon: Icons.credit_card_rounded,
      leadingIconSize: 24,
      actionIcon: Icons.close_rounded,
      actionIconSize: 25,
      onAction: () => context.canPop() ? context.pop() : null,
    );
  }

  Widget _myBody(double width, BuildContext context, double outstandingAmount) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
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
                _headerSection(colorScheme, outstandingAmount),
                const SizedBox(height: 20),
                Expanded(child: _paymentMethodsList(context)),
                const SizedBox(height: 16),
                _openCardSettingsButton(context, colorScheme),
                const SizedBox(height: 18),
                _payButton(context, colorScheme, outstandingAmount),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerSection(ColorScheme colorScheme, double outstandingAmount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Pagar saldo pendiente",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colorScheme.inverseSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Selecciona una tarjeta para pagar \$${outstandingAmount.toStringAsFixed(2)}",
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
    return BlocBuilder<PayOutstandingBloc, PayOutstandingState>(
      builder: (context, state) {
        Widget child;

        if (state.cardsStatus == DataOutstandingStatus.loading) {
          child = const Center(
            key: ValueKey('loading_cards'),
            child: MyLoadingIndicator(),
          );
        } else if (state.cardsStatus == DataOutstandingStatus.failure) {
          child = Center(
            key: const ValueKey('cards_error'),
            child: Text(
              state.cardsError ?? 'Error desconocido cargando tarjetas',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
        } else {
          final List<CardPaymentMethodEntity> savedCards = state.savedCards;

          child = Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                Flexible(
                  child: ListView(
                    key: const ValueKey('cards_content'),
                    shrinkWrap: true,
                    children: [
                      if (savedCards.isNotEmpty) ...[
                        Text(
                          "Tarjetas guardadas",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(
                              context,
                            ).colorScheme.inverseSurface.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...savedCards.map(
                          (CardPaymentMethodEntity card) => _paymentOption(
                            context: context,
                            id: card.token,
                            icon: Icons.credit_card_rounded,
                            title: "**** **** **** ${card.last4}",
                            subtitle:
                                "${card.brand} • Vence ${card.expMonth}/${card.expYear}",
                            color: Colors.blue,
                            isSelected: state.selectedCardId == card.token,
                            isDefault: card.isDefault == true,
                            onSelected: (selected) {
                              if (selected) {
                                context.read<PayOutstandingBloc>().add(
                                  SelectCardForOutstanding(cardId: card.token),
                                );
                              }
                            },
                          ),
                        ),
                      ] else ...[
                        _noCardsPlaceholder(context),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 225),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: child,
        );
      },
    );
  }

  Widget _paymentOption({
    required BuildContext context,
    required String id,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isSelected,
    required bool isDefault,
    required Function(bool) onSelected,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onSelected(!isSelected),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.1) : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? color : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                // Checkbox circular
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? color : Colors.grey.shade400,
                      width: 2,
                    ),
                    color: isSelected ? color : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check_rounded,
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
                  child: Column(
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
                              color: colorScheme.inverseSurface,
                            ),
                          ),
                          if (isDefault) ...[
                            const SizedBox(width: 8),
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
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.inverseSurface.withOpacity(0.6),
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
    );
  }

  Widget _noCardsPlaceholder(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
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
              color: colorScheme.inverseSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Agrega una tarjeta para pagar con ella",
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.inverseSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _loadPayMethodSavedCards(BuildContext context) {
    final shoppingPayMethodBloc = context.read<ShoppingPayMethodBloc>();
    shoppingPayMethodBloc.add(LoadSavedCards());
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
            'passedBloc': context.read<PayOutstandingBloc>(),
            'voidCallBack': () => _loadPayMethodSavedCards(context),
          },
        ),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1.2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.settings, color: Colors.blue, size: 16),
              const SizedBox(width: 8),
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

  Widget _payButton(
    BuildContext context,
    ColorScheme colorScheme,
    double outstandingAmount,
  ) {
    return BlocBuilder<PayOutstandingBloc, PayOutstandingState>(
      builder: (context, state) {
        final isMethodSelected = state.selectedCardId != null;
        final showLoad =
            state.paymentStatus == ActionOutstandingStatus.loading ||
            state.paymentStatus == ActionOutstandingStatus.success;

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (isMethodSelected)
                ? () {
                    showSnackBar(
                      context: context,
                      title: "Confirmar pago",
                      text:
                          "Se cobrará \$${outstandingAmount.toStringAsFixed(2)} de tu saldo pendiente",
                      showCancelButton: true,
                    );
                  }
                : !showLoad
                ? null
                : () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: isMethodSelected ? Colors.green : Colors.grey,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: MyAnimatedContentSwitcherButton(
              showLoad: showLoad,
              text: "Pagar saldo pendiente",
              icon: Icons.payment_rounded,
            ),
          ),
        );
      },
    );
  }
}
