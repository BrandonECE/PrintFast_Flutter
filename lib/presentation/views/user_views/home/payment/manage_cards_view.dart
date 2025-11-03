// lib/presentation/views/my_manage_cards_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:printfast_rebuild/config/routes/routes.dart';
import 'package:printfast_rebuild/di/service_locator.dart';
import 'package:printfast_rebuild/domain/repositories/user_repository.dart';
import 'package:printfast_rebuild/domain/entities/all_entities/card_payment_method_entity.dart';
import 'package:printfast_rebuild/presentation/blocs/shared_blocs/message_error_warning_bloc/message_error_warning_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/user_blocs/home_bloc/home_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/user_blocs/payment_blocs/change_payment_method_bloc/change_payment_method_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/user_blocs/payment_blocs/manage_cards_bloc/manage_cards_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/user_blocs/payment_blocs/pay_outstanding_bloc/pay_outstanding_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/user_blocs/payment_blocs/shopping_pay_method_bloc/shopping_pay_method_bloc.dart';

import 'package:printfast_rebuild/presentation/widgets/widgets.dart';

import '../../../../../utils/utils.dart';

class MyManageCardsView extends StatelessWidget {
  const MyManageCardsView({
    super.key,
    required this.passedBloc,
    required this.voidCallBack,
  });
  final Object? passedBloc;
  final Object? voidCallBack;

  @override
  Widget build(BuildContext context) {
    final homeBlocState = context.read<HomeBloc>().state;
    final registration = homeBlocState.userEntity.registration;

    return _myManageCardsView(registration, passedBloc);
  }

  BlocProvider<ManageCardsBloc> _myManageCardsView(
    String registration,
    Object? extra,
  ) {
    return BlocProvider(
      create: (context) => ManageCardsBloc(
        userRepository: getIt<UserRepository>(),
        registration: registration,
      )..add(const LoadUserCards()),
      child: BlocBuilder<ManageCardsBloc, ManageCardsState>(
        buildWhen: (prev, curr) => prev.saveStatus != curr.saveStatus,
        builder: (context, state) {
          final messageErrorWarningBloc = context
              .read<MessageErrorWarningBloc>();
          return Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: _ManageCardsViewContent(
                  passedBloc: extra,
                  voidCallBack: voidCallBack,
                ),
              ),
              MyMessageErrorWarning(
                voidCallback: () {
                  if (state.saveStatus == ActionManageCardsStatus.idle) {
                    context.read<ManageCardsBloc>().add(const SaveChanges());
                  } else if (state.saveStatus ==
                      ActionManageCardsStatus.failure) {
                    context.read<ManageCardsBloc>().add(
                      ChangeActionManageCardsStatusEvent(
                        saveStatus: ActionManageCardsStatus.idle,
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

class _ManageCardsViewContent extends StatelessWidget {
  const _ManageCardsViewContent({
    required this.passedBloc,
    required this.voidCallBack,
  });
  final Object? passedBloc;
  final Object? voidCallBack;

  static const Duration _animDur = Duration(milliseconds: 225);
  static const Curve _animCurve = Curves.easeOut;

  void _thereWasAnError(BuildContext context, ManageCardsState state) {
    showSnackBar(
      context: context,
      title: "¡Error inesperado!",
      text: state.errorMessage ?? "",
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      appBar: _myAppBar(context),
      body: BlocListener<ManageCardsBloc, ManageCardsState>(
        listener: (context, state) {
          if (state.saveStatus == ActionManageCardsStatus.success) {
            final passedBloc = this.passedBloc;
            _successfulManageCardHandle(passedBloc, context, voidCallBack as VoidCallback?);
            context.pop();
          } else if (state.saveStatus == ActionManageCardsStatus.failure &&
              state.errorMessage != null) {
            _thereWasAnError(context, state);
          }
        },
        child: Center(
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
              child: BlocBuilder<ManageCardsBloc, ManageCardsState>(
                builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header siempre visible (lo dejé aquí como método)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: _buildHeaderTitle(context),
                      ),
                      const SizedBox(height: 20),

                      // AREA CENTRAL: loader/error/content (AnimatedSwitcher)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: AnimatedSwitcher(
                            duration: _animDur,
                            switchInCurve: Curves.easeOut,
                            switchOutCurve: Curves.easeIn,
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                            child: _centralChildForState(context, state),
                          ),
                        ),
                      ),

                      // Botones de acción (siempre visibles)
                      _buildActionButtonsSection(context, voidCallBack),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _successfulManageCardHandle(
    Object? passedBloc,
    BuildContext context,
    VoidCallback? voidCallBack,
  ) {
    if (passedBloc is ShoppingPayMethodBloc) {
      context.read<ShoppingPayMethodBloc>().add(const LoadSavedCards());
    } else if (passedBloc is ChangePaymentMethodBloc) {
      context.read<ChangePaymentMethodBloc>().add(
        LoadPaymentMethods(
          currentPaymentMethodId: context
              .read<HomeBloc>()
              .state
              .activeOrder!
              .paymentMethod,
        ),
      );
    } else if (passedBloc is PayOutstandingBloc) {
      context.read<PayOutstandingBloc>().add(const LoadCardsForOutstanding());
      voidCallBack?.call();
    }
  }

  void _successfulAddCardHandle(
    Object? passedBloc,
    BuildContext context,
    VoidCallback? voidCallBack,
  ) {
    if (passedBloc is ShoppingPayMethodBloc) {
      context.read<ShoppingPayMethodBloc>().add(const LoadSavedCards());
    } else if (passedBloc is ChangePaymentMethodBloc) {
      context.read<ChangePaymentMethodBloc>().add(
        LoadPaymentMethods(
          currentPaymentMethodId: context
              .read<HomeBloc>()
              .state
              .activeOrder!
              .paymentMethod,
        ),
      );
    } else if (passedBloc is PayOutstandingBloc) {
      context.read<PayOutstandingBloc>().add(const LoadCardsForOutstanding());
      voidCallBack?.call();
    }
    context.read<ManageCardsBloc>().add(const LoadUserCards());
  }

  // ------------------------
  // Central content switcher
  // ------------------------
  Widget _centralChildForState(BuildContext context, ManageCardsState state) {
    if (state.loadStatus == DataManageCardsStatus.loading) {
      return const Center(
        key: ValueKey('manage_cards_loading'),
        child: MyLoadingIndicator(),
      );
    }

    if (state.loadStatus == DataManageCardsStatus.failure) {
      return Center(
        key: const ValueKey('manage_cards_error'),
        child: Text(
          state.errorMessage ?? 'Error al cargar tarjetas',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
          textAlign: TextAlign.center,
        ),
      );
    }

    return _cardsReadyContent(
      context,
      state,
      key: const ValueKey('manage_cards_content'),
    );
  }

  Widget _cardsReadyContent(
    BuildContext context,
    ManageCardsState state, {
    required Key key,
  }) {
    return Column(
      key: key,
      children: [
        if (state.userCards.isNotEmpty) _selectionHeader(context, state),
        state.userCards.isEmpty
            ? _noCardsPlaceholder(context)
            : Flexible(
                child: ListView(
                  key: const ValueKey('manage_cards_list'),
                  children: [
                    const SizedBox(height: 8),
                    ...state.userCards.map((card) {
                      return KeyedSubtree(
                        key: ValueKey(card.token),
                        child: _cardItem(context, card, state),
                      );
                    }).toList(),
                  ],
                ),
              ),
        const SizedBox(height: 16),
        _cashOption(context, state),
      ],
    );
  }

  // ------------------------
  // AppBar (tu MyAppBarWidget)
  // ------------------------
  MyAppBarWidget _myAppBar(BuildContext context) {
    return MyAppBarWidget(
      title: "Administrar tarjetas",
      leadingIcon: Icons.credit_card_rounded,
      leadingIconSize: 24,
      actionIcon: Icons.close_rounded,
      actionIconSize: 25,
      onAction: () => context.canPop() ? context.pop() : null,
    );
  }

  // ------------------------
  // Header title (inline)
  // ------------------------
  Widget _buildHeaderTitle(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Administrar tarjetas",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colorScheme.inverseSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Gestiona tus métodos de pago y establece tu predeterminado",
          style: TextStyle(
            fontSize: 13,
            color: colorScheme.inverseSurface.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ------------------------
  // Selection header (left + right button)
  // ------------------------
  Widget _selectionHeader(BuildContext context, ManageCardsState state) {
    final allSelected = state.selectedCards.length == state.userCards.length;
    final selectingMode = state.selectedCards.isNotEmpty;
    final leftTitle = selectingMode
        ? "Eliminar tarjetas"
        : "Seleccionar tarjetas";
    final rightText = allSelected ? "Deseleccionar todas" : "Seleccionar todas";

    final textStyle = const TextStyle(
      color: Colors.blue,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            leftTitle,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(
                context,
              ).colorScheme.inverseSurface.withOpacity(0.8),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (allSelected) {
                  context.read<ManageCardsBloc>().add(const DeselectAllCards());
                } else {
                  context.read<ManageCardsBloc>().add(const SelectAllCards());
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: AnimatedContainer(
                duration: _animDur,
                curve: _animCurve,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                alignment: Alignment.center,
                child: Text(rightText, style: textStyle),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------
  // Card item (respetando tu diseño)
  // ------------------------
  Widget _cardItem(
    BuildContext context,
    CardPaymentMethodEntity card,
    ManageCardsState state,
  ) {
    final isSelected = state.selectedCards.contains(card.token);
    final isDefault = state.pendingDefaultCardId == card.token;
    final selectingMode = state.selectedCards.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (isSelected) {
              context.read<ManageCardsBloc>().add(
                DeselectCardForAction(cardId: card.token),
              );
            } else {
              context.read<ManageCardsBloc>().add(
                SelectCardForAction(cardId: card.token),
              );
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: _animDur,
            curve: _animCurve,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.blue.withOpacity(0.1)
                  : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                AnimatedContainer(
                  duration: _animDur,
                  curve: _animCurve,
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey.shade400,
                      width: 2,
                    ),
                    color: isSelected ? Colors.blue : Colors.transparent,
                  ),
                  child: AnimatedSwitcher(
                    duration: _animDur,
                    child: isSelected
                        ? const Icon(
                            Icons.check_rounded,
                            key: ValueKey('selected'),
                            color: Colors.white,
                            size: 14,
                          )
                        : const SizedBox(key: ValueKey('not_selected')),
                  ),
                ),
                const SizedBox(width: 12),
                // Icono tarjeta
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.credit_card_rounded,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Texto de la tarjeta + indicador fijo (para evitar saltos)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "**** **** **** ${card.last4}",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.inverseSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${card.brand} • Vence ${card.expMonth}/${card.expYear}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(
                          context,
                        ).colorScheme.inverseSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: Stack(
                      children: [
                        Positioned(
                          top: 0,
                          right: 0,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 225),
                            switchInCurve: Curves.easeOutBack,
                            switchOutCurve: Curves.easeInBack,
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                            child: isDefault
                                ? Container(
                                    key: const ValueKey('default_indicator'),
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
                                  )
                                : const SizedBox(
                                    key: ValueKey('no_default'),
                                    width: 0,
                                    height: 0,
                                  ),
                          ),
                        ),

                        Align(
                          alignment: Alignment.topRight,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 260),
                            switchInCurve: Curves.easeOutBack,
                            switchOutCurve: Curves.easeInBack,
                            transitionBuilder: (child, animation) {
                              return ScaleTransition(
                                scale: animation,
                                child: FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                              );
                            },
                            child: !isDefault
                                ? Opacity(
                                    key: ValueKey(
                                      "in_not_default_${card.token}_${selectingMode ? 1 : 0}",
                                    ),
                                    opacity: selectingMode ? 0.35 : 1.0,
                                    child: IgnorePointer(
                                      ignoring: selectingMode,
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () => context
                                              .read<ManageCardsBloc>()
                                              .add(
                                                SetCardAsDefault(
                                                  cardId: card.token,
                                                ),
                                              ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.withOpacity(
                                                0.1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: const Icon(
                                              Icons.star_outline_rounded,
                                              color: Colors.orange,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox(
                                    key: ValueKey('no_default'),
                                    width: 0,
                                    height: 0,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------
  // Cash option (inline)
  // ------------------------
  Widget _cashOption(BuildContext context, ManageCardsState state) {
    final isCashDefault = state.pendingDefaultCardId == 'cash';
    final selectingMode = state.selectedCards.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: selectingMode
              ? null
              : () => context.read<ManageCardsBloc>().add(
                  const SetCashAsDefault(),
                ),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: _animDur,
            curve: _animCurve,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCashDefault
                  ? Colors.orange.withOpacity(0.1)
                  : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCashDefault ? Colors.orange : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.money_rounded,
                    color: Colors.orange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Efectivo",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.inverseSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Paga al recibir tu pedido",
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(
                          context,
                        ).colorScheme.inverseSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: Stack(
                      children: [
                        Positioned(
                          top: 0,
                          right: 0,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 260),
                            switchInCurve: Curves.easeOutBack,
                            switchOutCurve: Curves.easeInBack,
                            transitionBuilder: (child, animation) {
                              return ScaleTransition(
                                scale: animation,
                                child: FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                              );
                            },
                            child: isCashDefault
                                ? Container(
                                    key: const ValueKey(
                                      'cash_default_indicator',
                                    ),
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
                                  )
                                : const SizedBox(
                                    key: ValueKey('cash_no_default'),
                                    width: 0,
                                    height: 0,
                                  ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 260),
                            switchInCurve: Curves.easeOutBack,
                            switchOutCurve: Curves.easeInBack,
                            transitionBuilder: (child, animation) {
                              return ScaleTransition(
                                scale: animation,
                                child: FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                              );
                            },
                            child: !isCashDefault
                                ? Opacity(
                                    key: ValueKey(
                                      "cash_not_default_${selectingMode ? 1 : 0}",
                                    ),
                                    opacity: selectingMode ? 0.35 : 1.0,
                                    child: IgnorePointer(
                                      ignoring: selectingMode,
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () => context
                                              .read<ManageCardsBloc>()
                                              .add(const SetCashAsDefault()),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.withOpacity(
                                                0.1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: const Icon(
                                              Icons.star_outline_rounded,
                                              color: Colors.orange,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox(
                                    key: ValueKey('cash_is_default'),
                                    width: 0,
                                    height: 0,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------
  // No cards placeholder
  // ------------------------
  Widget _noCardsPlaceholder(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
            "Agrega una tarjeta para empezar",
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

  // ------------------------
  // Action buttons section (inline)
  // ------------------------
  Widget _buildActionButtonsSection(
    BuildContext context,
    Object? voidCallBack,
  ) {
    return BlocBuilder<ManageCardsBloc, ManageCardsState>(
      builder: (context, state) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Column(
            children: [
              _addCardButton(context, passedBloc, voidCallBack),
              const SizedBox(height: 16),
              _saveButton(context, state),
            ],
          ),
        );
      },
    );
  }

  Widget _addCardButton(
    BuildContext context,
    Object? extra,
    Object? voidCallBack,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(
          Routes.addCard,
          extra: () {
            //Sucessful Response
            _successfulAddCardHandle(extra, context, voidCallBack as VoidCallback?);
          },
        ),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1.2),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_rounded, color: Colors.blue, size: 16),
              SizedBox(width: 8),
              Text(
                "Agregar tarjeta",
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

  Widget _saveButton(BuildContext context, ManageCardsState state) {
    final isSaveLoading =
        state.saveStatus == ActionManageCardsStatus.loading ||
        state.saveStatus == ActionManageCardsStatus.success;
    final isEnabled = state.hasChanges && !isSaveLoading;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled
            ? () => showSnackBar(
                context: context,
                title: "¿Guardar cambios?",
                text: "Se aplicarán los cambios a tus tarjetas",
                showCancelButton: true,
              )
            : !isSaveLoading
            ? null
            : () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: isSaveLoading
              ? const MyLoadingIndicator(
                  key: ValueKey('save_loader'),
                  size: 28,
                  color: Colors.white,
                )
              : const Row(
                  key: ValueKey('save_text'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save_rounded, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "Guardar cambios",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
