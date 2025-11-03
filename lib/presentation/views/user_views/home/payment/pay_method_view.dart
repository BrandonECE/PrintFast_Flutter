// lib/presentation/views/my_pay_method_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:printfast_rebuild/config/routes/routes.dart';
import 'package:printfast_rebuild/di/service_locator.dart';
import 'package:printfast_rebuild/domain/repositories/user_repository.dart';
import 'package:printfast_rebuild/domain/entities/all_entities/card_payment_method_entity.dart';
import 'package:printfast_rebuild/presentation/blocs/shared_blocs/message_error_warning_bloc/message_error_warning_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/user_blocs/home_bloc/home_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/user_blocs/payment_blocs/shopping_pay_method_bloc/shopping_pay_method_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/user_blocs/shopping_blocs/shopping_bloc/shopping_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/user_blocs/shopping_blocs/shopping_location_picker_bloc/shopping_location_picker_bloc.dart';
import 'package:printfast_rebuild/presentation/widgets/widgets.dart';
import 'package:printfast_rebuild/utils/utils.dart';

class MyPayMethodView extends StatelessWidget {
  const MyPayMethodView({super.key});

  @override
  Widget build(BuildContext context) {
    return _myPayMethodScreen(context);
  }

  /// Creamos el BlocProvider aquí, pasando el registration desde HomeBloc
  BlocProvider<ShoppingPayMethodBloc> _myPayMethodScreen(BuildContext context) {
    final homeBlocState = context.read<HomeBloc>().state;
    final shoppingBlocState = context.read<ShoppingBloc>().state;
    final registration = homeBlocState.userEntity.registration;

  
    return BlocProvider(
      create: (context) => ShoppingPayMethodBloc(
        userRepository: getIt<UserRepository>(),
        registration: registration,
      )..add(const LoadSavedCards()),
      child: BlocBuilder<ShoppingPayMethodBloc, ShoppingPayMethodState>(
        buildWhen: (prev, curr) => prev.paymentStatus != curr.paymentStatus,
        builder: (context, state) {
          final messageErrorWarningBloc = context
              .read<MessageErrorWarningBloc>();
          return Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: const _PayMethodViewContent(),
              ),
              MyMessageErrorWarning(
                voidCallbackByCloseIcon: () {
                  if (state.paymentStatus == ActionMethodPayStatus.failure) {
                    context.read<ShoppingPayMethodBloc>().add( ChangeActionMethodPayStatusEvent( paymentStatus: ActionMethodPayStatus.idle, ), );
                  }
                  messageErrorWarningBloc.add( ShowMessageErrorWarningEvent( showMessageErrorWarning: false, ), );
                },
                voidCallback: () {
                  if (state.paymentStatus == ActionMethodPayStatus.idle) {
                    context.read<ShoppingPayMethodBloc>().add( ConfirmPayment( amount: shoppingBlocState.totalPrice, userRegistration: homeBlocState.userEntity.registration, ), );
                  } else if (state.paymentStatus == ActionMethodPayStatus.failure) {
                    context.read<ShoppingPayMethodBloc>().add( ChangeActionMethodPayStatusEvent( paymentStatus: ActionMethodPayStatus.idle, ), );
                    if(state.outstandingCharges > 0.0){
                      context.push(Routes.payOutstanding, extra: {
                        "outstandingCharges": state.outstandingCharges,
                        "shoppingPayMethodBloc": context.read<ShoppingPayMethodBloc>(),
                      });
                    }
                  }
                  messageErrorWarningBloc.add( ShowMessageErrorWarningEvent( showMessageErrorWarning: false, ), );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PayMethodViewContent extends StatelessWidget {
  const _PayMethodViewContent();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;
    final shoppingBloc = context.read<ShoppingBloc>();
    final shoppingLocationPickerBloc = context
        .read<ShoppingLocationPickerBloc>();
    final shoppingLocationPickerBlocState = shoppingLocationPickerBloc.state;
    final homeBlocState = context.read<HomeBloc>().state;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      appBar: _myAppBar(context),
      body: BlocListener<ShoppingPayMethodBloc, ShoppingPayMethodState>(
        listenWhen: (prev, curr) => prev.paymentStatus != curr.paymentStatus,
        listener: (context, state) {
          // Navegar SOLO cuando el proceso de pago haya terminado con éxito

          if (state.paymentStatus == ActionMethodPayStatus.success) {
            shoppingBloc.processingPayment(
              homeBlocState.userEntity,
              shoppingLocationPickerBlocState
                  .shops[shoppingLocationPickerBlocState.index],
              state.selectedMethodId!,
            );
            context.pop();
          }
          // Errores de pago
          else if (state.paymentStatus == ActionMethodPayStatus.failure &&
              state.paymentError != null) {
            final String errorTitle = state.outstandingCharges > 0.0
                ? "Pago Pendiente: \$${state.outstandingCharges.toStringAsFixed(2)}"
                : "¡Error inesperado!";
            final String errorMessage = state.outstandingCharges > 0.0
                ? "Liquida el saldo pendiente por cancelación para continuar."
                : state.paymentError ?? "";
            thereWasAnError(errorTitle, errorMessage, context);
          }
        },
        child: _myBody(width, context),
      ),
    );
  }

  void thereWasAnError(
    String errorTitle,
    String errorMessage,
    BuildContext context,
  ) {
    showSnackBar(context: context, title: errorTitle, text: errorMessage);
  }

  MyAppBarWidget _myAppBar(BuildContext context) {
    return MyAppBarWidget(
      title: "Método de pago",
      leadingIcon: Icons.credit_card_rounded,
      leadingIconSize: 24,
      actionIcon: Icons.close_rounded,
      actionIconSize: 25,
      onAction: () => context.canPop() ? context.pop() : null,
    );
  }

  Widget _myBody(double width, BuildContext context) {
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
                _headerSection(colorScheme),
                const SizedBox(height: 20),
                Expanded(child: _paymentMethodsList(context)),
                const SizedBox(height: 16),
                _openCardSettingsButton(context, colorScheme),
                const SizedBox(height: 18),
                _confirmButton(context, colorScheme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Método de pago",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colorScheme.inverseSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Selecciona cómo deseas pagar",
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
    return BlocBuilder<ShoppingPayMethodBloc, ShoppingPayMethodState>(
      builder: (context, state) {
        Widget child;

        if (state.cardsStatus == DataMethodPayStatus.loading) {
          child = const Center(
            key: ValueKey('loading_cards'),
            child: MyLoadingIndicator(),
          );
        } else if (state.cardsStatus == DataMethodPayStatus.failure) {
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
                            isSelected: state.selectedMethodId == card.token,
                            isDefault: card.isDefault == true,
                            onSelected: (selected) {
                              if (selected) {
                                context.read<ShoppingPayMethodBloc>().add(
                                  SelectPaymentMethod(methodId: card.token),
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

                SizedBox(height: state.savedCards.length >= 4 ? 32 : 16),

                _paymentOption(
                  context: context,
                  id: 'cash',
                  icon: Icons.money_rounded,
                  title: "Efectivo",
                  subtitle: "Paga al recibir tu pedido",
                  color: Colors.orange,
                  isSelected: state.selectedMethodId == 'cash',
                  isDefault: !state.savedCards.any(
                    (element) => element.isDefault,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      context.read<ShoppingPayMethodBloc>().add(
                        const SelectPaymentMethod(methodId: 'cash'),
                      );
                    }
                  },
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
            'passedBloc':context.read<ShoppingPayMethodBloc>(),
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

  Widget _confirmButton(BuildContext context, ColorScheme colorScheme) {
    return BlocBuilder<ShoppingPayMethodBloc, ShoppingPayMethodState>(
      builder: (context, state) {
        final isMethodSelected = state.selectedMethodId != null;
        final showLoad =
            state.paymentStatus == ActionMethodPayStatus.loading ||
            state.paymentStatus == ActionMethodPayStatus.success;

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (isMethodSelected)
                ? () {
                    showSnackBar(
                      context: context,
                      title: "Confirmar pedido",
                      text:
                          "Tu pedido se enviará y quedará pendiente de aprobación",
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
              text: "Confirmar pago",
              icon: Icons.payment_rounded,
            ),
          ),
        );
      },
    );
  }
}
