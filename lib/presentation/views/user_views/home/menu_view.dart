// lib/presentation/views/my_menu_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:printfast_rebuild/config/routes/routes.dart';
import 'package:printfast_rebuild/presentation/blocs/user_blocs/home_bloc/home_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/shared_blocs/message_error_warning_bloc/message_error_warning_bloc.dart';
import 'package:printfast_rebuild/presentation/widgets/widgets.dart';
import 'package:printfast_rebuild/utils/utils.dart';
import '../../../../domain/entities/entities.dart';

class MyMenuView extends StatelessWidget {
  const MyMenuView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final homeBloc = context.read<HomeBloc>();

    void thereWasAnError(HomeState state, HomeBloc homeBloc) {
      showSnackBar(
        context: context,
        title: "¡Error inesperado!",
        text: state.messageError ?? "",
      );
      homeBloc.add(
        HomeUpdateHomeLogOutStatusEvent(
          homeLogOutStatus: HomeLogOutStatus.initial,
          messageError: null,
        ),
      );
    }

    void comeBackToLoginScreen(HomeBloc homeBloc, BuildContext context) {
      homeBloc.add(
        HomeUpdateUserEntityEvent(userEntity: UserEntity.defaultValues),
      );
      context.go(Routes.login);
      homeBloc.add(
        HomeUpdateHomeLogOutStatusEvent(
          homeLogOutStatus: HomeLogOutStatus.initial,
          messageError: null,
        ),
      );
    }

    return BlocListener<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state.homeLogOutStatus == HomeLogOutStatus.success) {
          comeBackToLoginScreen(homeBloc, context);
        }
        if (state.homeLogOutStatus == HomeLogOutStatus.failure) {
          thereWasAnError(state, homeBloc);
        }
      },
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return _buildLayout(width, context, state);
        },
      ),
    );
  }

  SafeArea _buildLayout(double width, BuildContext context, HomeState state) {
    return SafeArea(
      child: Center(
        child: Container(
          width: width * 0.95,
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              _topCard(context, state),
              const SizedBox(height: 14),
              Expanded(child: _mainContent(context, state)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topCard(BuildContext context, HomeState state) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      width: width * 0.95,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            children: [
              _profileAvatar(state.userEntity, context),
              const SizedBox(width: 14),
              Expanded(child: _greetingBlock(context, state)),
            ],
          ),
          const SizedBox(height: 18),
          _quickActionsRow(context),
        ],
      ),
    );
  }

  Widget _profileAvatar(UserEntity user, BuildContext context) {
    final initials = _makeInitials(user.name);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.12),
        shape: BoxShape.circle,
        border: Border.all(color: colorScheme.primary, width: 1.8),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _greetingBlock(BuildContext context, HomeState homeState) {
    final colorScheme = Theme.of(context).colorScheme;
    final name = homeState.userEntity.name.isNotEmpty
        ? firstName(homeState.userEntity.name)
        : "Usuario";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "¡Hola, $name!",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: colorScheme.inverseSurface,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          "Tu impresión en un click",
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.inverseSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _quickActionsRow(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final tileWidth = (width * 0.95 - 44) / 2;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        BlocBuilder<HomeBloc, HomeState>(
          buildWhen: (prev, curr) =>
              prev.homeOrderStatus != curr.homeOrderStatus ||
              prev.activeOrder != curr.activeOrder,
          builder: (context, state) {
            final isButtonEnable =
                state.homeOrderStatus != HomeOrderStatus.orderActive;

            final targetColor = isButtonEnable
                ? colorScheme.primary
                : mixColors(colorScheme.primary, Colors.white, 0.4);

            return _actionTile(
              context,
              icon: Icons.shopping_cart_rounded,
              label: "Comprar",
              color: targetColor,
              onTap: isButtonEnable
                  ? () => context.push(Routes.shopping)
                  : null,
              width: tileWidth,
            );
          },
        ),
        _actionTile(
          context,
          icon: Icons.history_rounded,
          label: "Historial",
          color: Theme.of(context).colorScheme.primary,
          onTap: () => context.push(Routes.history),
          width: tileWidth,
        ),
      ],
    );
  }

  Widget _actionTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onTap,
    required double width,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    const animDur = Duration(milliseconds: 190);

    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: color),
      duration: animDur,
      builder: (context, animatedColor, child) {
        final c = animatedColor ?? color;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: AnimatedContainer(
              duration: animDur,
              width: width,
              height: 100,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [c.withOpacity(0.18), c.withOpacity(0.1)],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: c.withOpacity(0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: animDur,
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: c,
                      borderRadius: BorderRadius.circular(11),
                      boxShadow: [
                        BoxShadow(
                          color: c.withOpacity(0.35),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: Colors.white, size: 22),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.inverseSurface,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: c.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 13,
                          color: c,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _mainContent(BuildContext context, HomeState state) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      width: width * 0.95,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(context, "Novedades", Icons.new_releases_rounded),
            const SizedBox(height: 14),
            _newsCard(context),
            const SizedBox(height: 20),
            _sectionTitle(context, "Orden activa", Icons.receipt_long_rounded),
            const SizedBox(height: 14),
            _activeOrderArea(context),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: colorScheme.primary, size: 20),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: colorScheme.inverseSurface,
          ),
        ),
      ],
    );
  }

  Widget _newsCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;

    return Container(
      width: width * 0.83,
      height: 110,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.85)],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.35),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "PrintFast",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(width: 7),
                SizedBox(
                  width: 20,
                  height: 20,
                  child: Image.asset(
                    'assets/images/printfast_logo.png',
                    fit: BoxFit.contain,
                    color: Colors.white,
                  ),
                ),
                // child:Icon(Icons.print, color: Colors.white, size: 25,)
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                "¡NUEVO SERVICIO!",
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- NUEVO: area que respeta homeOrderStatus ----------
  Widget _activeOrderArea(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (prev, curr) =>
          prev.homeOrderStatus != curr.homeOrderStatus ||
          prev.activeOrder != curr.activeOrder ||
          prev.activeOrderProgress != curr.activeOrderProgress ||
          prev.activeOrderTimeLabel != curr.activeOrderTimeLabel,
      builder: (context, state) {
        return Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey.shade200, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 225),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: _contentForHomeOrderStatus(context, state),
            ),
          ),
        );
      },
    );
  }

  Widget _contentForHomeOrderStatus(BuildContext context, HomeState state) {
    switch (state.homeOrderStatus) {
      case HomeOrderStatus.loading:
        return _loadingCard(key: const ValueKey('home_order_loading'));

      case HomeOrderStatus.orderActive:
        return Container(
          key: const ValueKey('home_order_active'),
          child: _activeOrderCard(context),
        );

      case HomeOrderStatus.noOrderActive:
      case HomeOrderStatus.idle:
        return Container(
          key: const ValueKey('home_order_no_active'),
          child: _noActiveOrderCard(context),
        );

      case HomeOrderStatus.failure:
        return Container(
          key: const ValueKey('home_order_failure'),
          child: _activeOrderFailureCard(
            context,
            state.messageError ?? 'No se pudo cargar la orden activa.',
          ),
        );

      case HomeOrderStatus.canceledByCopyShop:
        return Container(
          key: const ValueKey('home_order_canceled'),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.cancel_rounded,
                  size: 42,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 10),
                Text(
                  'Orden cancelada por el establecimiento',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.inverseSurface,
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }

  Widget _loadingCard({required ValueKey key}) {
    return Container(
      key: const ValueKey('home_order_loading_card'),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: MyLoadingIndicator(),
    );
  }

  Widget _activeOrderFailureCard(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(top: 8, right: 12, left: 12, bottom: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.error.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 26,
              color: colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "No se pudo cargar la orden",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colorScheme.inverseSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            message.isNotEmpty
                ? message
                : "Hubo un problema al obtener la información. Intenta más tarde.",
            style: TextStyle(
              fontSize: 11,
              color: colorScheme.inverseSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _activeOrderCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (prev, curr) =>
          prev.homeOrderStatus != curr.homeOrderStatus ||
          prev.activeOrder != curr.activeOrder ||
          prev.activeOrderProgress != curr.activeOrderProgress ||
          prev.activeOrderTimeLabel != curr.activeOrderTimeLabel,
      builder: (context, state) {
        final order = state.activeOrder;
        final orderCode = order?.orderCode ?? "#A2837";
        final isActive =
            order != null &&
            (order.hasItBeenAccepted == true || order.hasItBeenAccepted == null
                ? (order.hasItBeenAccepted == true)
                : false);
        final status = isActive ? "Activa" : "En revisión";
        final place = order?.copyShopName ?? "FIME";
        final time = state.activeOrderTimeLabel.isNotEmpty
            ? state.activeOrderTimeLabel
            : "12 min";
        final price = order != null ? order.price.toStringAsFixed(2) : "75.00";
        final progress = state.activeOrderProgress.clamp(0.0, 1.0);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      "Orden $orderCode",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.inverseSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _statusChip(context, isActive: isActive, status: status),
                ],
              ),

              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoRow(
                          context,
                          icon: Icons.location_on_rounded,
                          text: place,
                          iconColor: colorScheme.primary,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (isActive)
                              Expanded(
                                child: _infoRow(
                                  context,
                                  icon: Icons.access_time_rounded,
                                  text: time,
                                ),
                              ),
                            Expanded(
                              child: _infoRow(
                                context,
                                icon: Icons.attach_money_rounded,
                                text: price,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Indicador visual de progreso (usa progress y texto %)
                  Container(
                    width: 50,
                    height: 50,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            value: isActive ? progress : 0,
                            strokeWidth: 3,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.primary,
                            ),
                          ),
                        ),
                        Text(
                          isActive ? "${(progress * 100).round()}%" : "0%",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isActive
                                ? colorScheme.primary
                                : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => context.push(Routes.activeOrder),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.visibility_rounded, size: 16),
                          SizedBox(width: 5),
                          Text(
                            "Ver Detalles",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade100, width: 1),
                    ),
                    child: IconButton(
                      onPressed: () {
                        showSnackBar(
                          context: context,
                          title: "¿Cancelar orden?",
                          text: "Esta acción no se puede deshacer",
                          showCancelButton: true,
                        );
                      } /* no modifiqué lógica */,
                      icon: Icon(
                        Icons.close_rounded,
                        color: Colors.red.shade600,
                        size: 18,
                      ),
                      padding: EdgeInsets.zero,
                      iconSize: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoRow(
    BuildContext context, {
    required IconData icon,
    required String text,
    Color? iconColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: iconColor ?? colorScheme.inverseSurface.withOpacity(0.7),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: colorScheme.inverseSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusChip(
    BuildContext context, {
    required bool isActive,
    required String status,
  }) {
    final baseGreen = Colors.green;
    final baseOrange = Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isActive
            ? baseGreen.withOpacity(0.06)
            : baseOrange.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? baseGreen.withOpacity(0.18)
              : baseOrange.withOpacity(0.18),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.pending,
            size: 12,
            color: isActive
                ? baseGreen.withOpacity(0.85)
                : baseOrange.withOpacity(0.85),
          ),
          const SizedBox(width: 5),
          Text(
            status,
            style: TextStyle(
              color: isActive
                  ? baseGreen.withOpacity(0.85)
                  : baseOrange.withOpacity(0.85),
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _compactInfoItem(
    BuildContext context, {
    required IconData icon,
    required String text,
    required bool isPrimary,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 15,
          color: isPrimary
              ? colorScheme.primary
              : colorScheme.inverseSurface.withOpacity(0.7),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: isPrimary ? 14 : 13,
              fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
              color: isPrimary
                  ? colorScheme.inverseSurface
                  : colorScheme.inverseSurface.withOpacity(0.8),
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _noActiveOrderCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add_shopping_cart_rounded,
              size: 26,
              color: colorScheme.primary,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "Sin órdenes act.",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colorScheme.inverseSurface,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 4),

          Text(
            "Crear una orden",
            style: TextStyle(
              fontSize: 11,
              color: colorScheme.inverseSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          ElevatedButton(
            onPressed: () => context.push(Routes.shopping),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: const Size(0, 32),
            ),
            child: const Text(
              "Comprar",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  String _makeInitials(String fullName) {
    if (fullName.trim().isEmpty) return "PF";
    final parts = fullName.trim().split(" ");
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    final a = parts[0].substring(0, 1);
    final b = parts.length > 1 ? parts[1].substring(0, 1) : "";
    return (a + b).toUpperCase();
  }
}
