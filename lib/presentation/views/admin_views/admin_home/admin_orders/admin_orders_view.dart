import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:printfast_rebuild/config/routes/routes.dart';
import 'package:printfast_rebuild/domain/entities/entities.dart';
import 'package:printfast_rebuild/presentation/blocs/admin_blocs/admin_home_bloc/admin_home_bloc.dart';
import 'package:printfast_rebuild/presentation/widgets/widgets.dart';
import 'package:printfast_rebuild/utils/utils.dart';

class MyAdminOrdersView extends StatelessWidget {
  const MyAdminOrdersView({super.key, required this.callBack});
  final void Function(int index) callBack;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Center(
      child: Container(
        width: width * 0.95,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: _buildBody(context, width, callBack),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    double width,
    void Function(int index) callBack,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildTitleRow(context, width, callBack),
          const SizedBox(height: 16),
          DefaultTabController(
            length: 2,
            initialIndex: 0,
            child: Expanded(
              child: Column(
                children: [
                  BlocBuilder<AdminHomeBloc, AdminHomeState>(
                    
                      buildWhen: (prev, curr) =>
                        prev.acceptedOrders.length !=
                            curr.acceptedOrders.length ||
                        prev.pendingOrders.length != curr.pendingOrders.length,
                    builder: (context, state) {
                      final pendigAOrdersCount = state.pendingOrders.length;

                      return SizedBox(
                        width: width * 0.83,
                        child: SegmentedTabControl(
                          textStyle: TextStyle(
                            fontSize: 14,
                            color: colorScheme.inverseSurface,
                            fontWeight: FontWeight.w500,
                          ),
                          splashColor: Colors.white.withOpacity(0.1),
                          selectedTextStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          tabTextColor: colorScheme.inverseSurface.withOpacity(
                            0.7,
                          ),
                          selectedTabTextColor: Colors.white,
                          height: 48,
                          indicatorPadding: const EdgeInsets.all(2),
                          squeezeIntensity: 2,
                          tabPadding: const EdgeInsets.symmetric(horizontal: 4),
                          barDecoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          indicatorDecoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary.withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          tabs: [
                            SegmentTab(label: 'Aceptadas'),
                            SegmentTab(
                              label: 'Pend. ($pendigAOrdersCount)',
                              color: Colors.redAccent,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: BlocBuilder<AdminHomeBloc, AdminHomeState>(
                      buildWhen: (prev, curr) =>
                          prev.adminAordersStatus != curr.adminAordersStatus ||
                          prev.acceptedOrders != curr.acceptedOrders ||
                          prev.pendingOrders != curr.pendingOrders,
                      builder: (context, state) {
                        return TabBarView(
                          children: [
                            _buildSectionContainer(
                              context,
                              width,
                              _buildContentForState(context, state, true),
                            ),
                            _buildSectionContainer(
                              context,
                              width,
                              _buildContentForState(context, state, false),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentForState(
    BuildContext context,
    AdminHomeState state,
    bool isAcceptedOrdersTab,
  ) {
    final orders = isAcceptedOrdersTab ? state.acceptedOrders : state.pendingOrders;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 225),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: _contentForAdminAordersStatus(
        context,
        state,
        orders,
        isAcceptedOrdersTab,
      ),
    );
  }

  Widget _contentForAdminAordersStatus(
    BuildContext context,
    AdminHomeState state,
    List<AorderEntity> orders,
    bool isAcceptedTab,
  ) {
    switch (state.adminAordersStatus) {
      case AdminAordersStatus.loading:
        return _buildLoading(
          context,
          key: const ValueKey('admin_orders_loading'),
        );

      case AdminAordersStatus.failure:
        return _buildFailure(
          context,
          state.messageError ?? 'Error desconocido',
          key: const ValueKey('admin_orders_failure'),
        );

      case AdminAordersStatus.success:
        if (orders.isEmpty) {
          return _buildEmpty(
            context,
            isAcceptedTab,
            key: ValueKey(
              'admin_orders_empty_${isAcceptedTab ? 'accepted' : 'pending'}',
            ),
          );
        }
        return _buildOrdersListWithAnimation(
          context,
          orders,
          isAcceptedTab,
          key: ValueKey(
            'admin_orders_list_${isAcceptedTab ? 'accepted' : 'pending'}_${orders.length}',
          ),
        );

      case AdminAordersStatus.initial:
        return _buildLoading(
          context,
          key: const ValueKey('admin_orders_initial'),
        );
    }
  }

  Widget _buildOrdersListWithAnimation(
    BuildContext context,
    List<AorderEntity> orders, 
    bool isAcceptedTab,
    {required Key key,
  }) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (Widget child, Animation<double> animation) {
        // Animación de entrada más elaborada
        final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
          ),
        );

        final slideAnimation =
            Tween<Offset>(
              begin: const Offset(0.0, 0.3),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: const Interval(0.2, 1.0, curve: Curves.easeOutBack),
              ),
            );

        final scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.1, 0.8, curve: Curves.easeOutBack),
          ),
        );

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: ScaleTransition(scale: scaleAnimation, child: child),
          ),
        );
      },
      child: _buildList(context, orders, isAcceptedTab, key: key),
    );
  }

  void _thereWasAnError(BuildContext context, String title, String errorMessage) {
      showSnackBar(
        context: context,
        title: title,
        text: errorMessage,
    );
  }

  Widget _buildList(
    BuildContext context,
    List<AorderEntity> orders,
    bool isAcceptedTab,
    {required Key key,
  }){
    final colorScheme = Theme.of(context).colorScheme;
    final adminHomeBloc = context.read<AdminHomeBloc>();

    return ListView.separated(
      key: key,
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = orders[index];
        final formatYmd = formatDateToYMD(item.initDate);
        final formatAmPm = formatTimeToAmPm(item.initDate);
        final String date = "$formatYmd , $formatAmPm";


        void selectOrder() {
          if (!isAcceptedTab) {
            final status = adminHomeBloc.state.pendingOrderStatus;
            final selectedCode = adminHomeBloc.state.selectedPendingOrderCode;
            final targetCode = orders[index].orderCode;

            final bool isSameOrEmpty = selectedCode == targetCode || selectedCode.isEmpty;

            if (status == PendingOrderStatus.idle) {
              // Si está idle, entramos sin más validaciones
              adminHomeBloc.add(
                AdminHomeUpdateSelectedPendingOrderCodeValueEvent(
                  selectedPendingOrderCode: targetCode,
                ),
              );
              adminHomeBloc.add(
                AdminHomeUpdateSelectedOrderEvent(selectedOrder: orders[index]),
              );
              context.push(Routes.adminOrderView);
              return;
            }

            if (status == PendingOrderStatus.loading) {
              // Si está cargando, sólo permitimos entrada si coincide la orden o si no hay selección previa
              if (isSameOrEmpty) {
                // Si estaba vacío, lo seteamos para dejar claro que esta orden está en proceso
                if (selectedCode.isEmpty) {
                  adminHomeBloc.add(
                    AdminHomeUpdateSelectedPendingOrderCodeValueEvent(
                      selectedPendingOrderCode: targetCode,
                    ),
                  );
                }

                adminHomeBloc.add(
                  AdminHomeUpdateSelectedOrderEvent(selectedOrder: orders[index]),
                );
                context.push(Routes.adminOrderView);
                return;
              } else {
                // Hay otra orden pendiente en proceso — bloqueamos
                adminHomeBloc.add(
                  AdminHomeUpdateAdminHomeActionsEvent(
                    adminHomeActions: AdminHomeActions.accessPendingOrder,
                  ),
                );
                _thereWasAnError(
                  context,
                  'Orden pendiente en proceso',
                  'Por favor espera a que se complete la autorización o el rechazo de la orden pendiente antes de acceder a una nueva',
                );
                return;
              }
            }

            // Para cualquier otro estado (si lo hay), bloqueamos por seguridad
            adminHomeBloc.add(
              AdminHomeUpdateAdminHomeActionsEvent(
                adminHomeActions: AdminHomeActions.accessPendingOrder,
              ),
            );
            _thereWasAnError(
              context,
              'Orden pendiente en proceso',
              'Por favor espera a que se complete la autorización o el rechazo de la orden pendiente antes de acceder a una nueva',
            );
          } else {
            // Si estamos en la pestaña accepted, entramos normalmente
            adminHomeBloc.add(
              AdminHomeUpdateSelectedOrderEvent(selectedOrder: orders[index]),
            );
            context.push(Routes.adminOrderView);
          }
        }


        return Column(
          children: [
            // fecha banner
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              width: double.infinity,
              child: Text(
                date,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // tarjeta de orden
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                   Row(
                  children: [
                    Icon(
                      Icons.receipt_long,
                      size: 18,
                      color: colorScheme.inverseSurface,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Ord #${item.orderCode}",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.inverseSurface,
                        fontSize: 15,
                      ),
                    ),
                    
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250), // Más rápido: 250ms
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          layoutBuilder: (currentChild, previousChildren) {
                            return Stack(
                              alignment: Alignment.centerLeft,
                              children: <Widget>[
                                ...previousChildren,
                                if (currentChild != null) currentChild,
                              ],
                            );
                          },
                          transitionBuilder: (child, animation) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(-1, 0), // Desplazamiento más corto
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOut,
                              )),
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            );
                          },
                              child: Row(
                                key: ValueKey('icons_${item.printDate != null}_${item.hasItBeenCanceledByUser}'),
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (item.printDate != null) 
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Icon(
                                        Icons.local_print_shop_rounded,
                                        size: 18,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                  
                                  if (item.hasItBeenCanceledByUser)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Icon(
                                        Icons.cancel_rounded,
                                        size: 18,
                                        color: Colors.red,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.person_2_sharp,
                              size: 18,
                              color: colorScheme.inverseSurface.withOpacity(
                                0.8,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              item.userRegistration,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: colorScheme.inverseSurface.withOpacity(
                                  0.8,
                                ),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${item.price}\$",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.inverseSurface,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: selectOrder,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: colorScheme.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                          shadowColor: colorScheme.primary.withOpacity(0.3),
                        ),
                        child: const Icon(Icons.remove_red_eye, size: 20),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoading(BuildContext context, {required Key key}) {
    return Center(
      key: key,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: MyLoadingIndicator(),
      ),
    );
  }

  Widget _buildEmpty(
    BuildContext context,
    bool isAcceptedTab, {
    required Key key,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final tabName = isAcceptedTab ? 'aceptadas' : 'pendientes';

    return Center(
      key: key,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 9),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono más compacto (ligeramente)
            Container(
              width: 76, // reducido desde 84
              height: 76,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.12),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.035),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                Icons.receipt_long,
                size: 32, // reducido desde 40
                color: colorScheme.primary,
              ),
            ),

            const SizedBox(height: 14),

            // Título algo más compacto
            Text(
              "No hay órdenes $tabName",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15, // reducido desde 17
                fontWeight: FontWeight.w600,
                color: colorScheme.inverseSurface,
              ),
            ),

            const SizedBox(height: 7),

            // Subtítulo ligeramente más compacto
            Text(
              "En esta sección aparecerán las órdenes $tabName",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13, // reducido desde 14
                color: colorScheme.inverseSurface.withOpacity(0.78),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFailure(
    BuildContext context,
    String message, {
    required Key key,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final adminHomeBloc = context.read<AdminHomeBloc>();

    return Center(
      key: key,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icono un poco más compacto
            Container(
              width: 66, // reducido desde 72
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
                size: 32, // reducido desde 36
                color: colorScheme.primary,
              ),
            ),

            const SizedBox(height: 12),

            // Título más compacto
            Text(
              'Error al cargar',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.inverseSurface,
                fontSize: 15, // reducido desde 16
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 6),

            // Mensaje más compacto
            Text(
              message.isNotEmpty ? message : 'Revisa tu conexión',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.inverseSurface.withOpacity(0.78),
                fontSize: 13, // reducido desde 14
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 14),

            // Botón ligeramente más compacto
            ElevatedButton(
              onPressed: () {
                adminHomeBloc.add(
                  AdminHomeStartAordersListenerEvent(
                    copyShopEmail: adminHomeBloc.state.userEntity.email,
                  ),
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
                minimumSize: const Size(0, 38), // un poco menos que antes
              ),
              child: const Text(
                'Reintentar',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13, // igual que antes pequeño
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleRow(
    BuildContext context,
    double width,
    void Function(int index) callBack,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: width * 0.83,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                "Órdenes",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.inverseSurface,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_drop_down,
                size: 25,
                color: colorScheme.inverseSurface,
              ),
            ],
          ),
          _StatusPill(onTap: () => callBack.call(3)),
        ],
      ),
    );
  }

  Widget _buildSectionContainer(
    BuildContext context,
    double width,
    Widget content,
  ) {
    return Container(
      width: width * 0.83,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: content,
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color onlineColor = Colors.green;
    final Color pausedColor = Colors.orange;
    final Color loadingColor = Colors.grey;

    return BlocBuilder<AdminHomeBloc, AdminHomeState>(
      builder: (context, state) {
        state.receptionStatus;
        final bg = switch (state.receptionStatus) {
          AdminReceptionStatus.success =>
            state.copyShopEntity.pauseReception ?  pausedColor :  onlineColor,
          _ => loadingColor, // default
        };

        final String label = switch (state.receptionStatus) {
          AdminReceptionStatus.success =>
            state.copyShopEntity.pauseReception ? 'Pausada' : 'Disponible',
          _ => "Cargando...", // default
        };

        final Widget icon = switch (state.receptionStatus) {
          AdminReceptionStatus.success =>
            state.copyShopEntity.pauseReception
                ? Icon(Icons.pause_circle, size: 16, color: bg)
                : Icon(Icons.check_circle, size: 16, color: bg),
          _ => MyLoadingIndicator(size: 18, color: bg,), // default
        };

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                 layoutBuilder: (currentChild, previousChildren) {
                return Stack(
                  alignment: Alignment.centerRight,
                  children: <Widget>[
                    ...previousChildren,
                    if (currentChild != null) currentChild,
                  ],
                );
              },
              child: Container(
                // key que cambia cuando cambia el estado relevante
                key: ValueKey(
                  '${state.receptionStatus}_${state.copyShopEntity.pauseReception}',
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: bg.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: bg.withOpacity(0.3), width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    icon,
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: TextStyle(
                        color: bg,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
