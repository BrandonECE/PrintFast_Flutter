// lib/presentation/views/my_history_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:printfast_rebuild/config/routes/routes.dart';
import 'package:printfast_rebuild/domain/entities/entities.dart';
import 'package:printfast_rebuild/domain/repositories/user_repository.dart';
import 'package:printfast_rebuild/presentation/blocs/user_blocs/history_bloc/history_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/user_blocs/home_bloc/home_bloc.dart';
import 'package:printfast_rebuild/presentation/widgets/widgets.dart';
import 'package:printfast_rebuild/utils/utils.dart';
import 'package:printfast_rebuild/di/service_locator.dart';

class MyHistoryView extends StatelessWidget {
  const MyHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final colorScheme = Theme.of(context).colorScheme;

    final registration = context.read<HomeBloc>().state.userEntity.registration;

    return BlocProvider(
      create: (_) => HistoryBloc(
        userRepository: getIt<UserRepository>(),
        registration: registration,
      )..add(LoadHistory()),
      child: Scaffold(
        backgroundColor: colorScheme.primary,
        appBar: MyAppBarWidget(
          title: "Historial",
          leadingIcon: Icons.history_rounded,
          leadingIconSize: 25,
          actionIcon: Icons.close_rounded,
          actionIconSize: 25,
          onAction: () => context.canPop() ? context.pop() : null,
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.only(bottom: width * 0.025),
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
              child: _HistoryBody(width: width),
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryBody extends StatelessWidget {
  final double width;
  const _HistoryBody({required this.width});

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildTitleRow(context, width),
          const SizedBox(height: 16),
          Expanded(child: _buildSectionContainer(context, width)),
        ],
      ),
    );
  }

  Widget _buildTitleRow(BuildContext context, double width) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: width * 0.83,
      child: Row(
        children: [
          Text(
            "Todas las órdenes",
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
    );
  }

  Widget _buildSectionContainer(BuildContext context, double width) {
    return BlocBuilder<HistoryBloc, HistoryState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
          ),
          width: width * 0.83,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 225),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: _contentForState(context, state),
          ),
        );
      },
    );
  }

  Widget _contentForState(BuildContext context, HistoryState state) {
    switch (state.status) {
      case HistoryStatus.loading:
        return _buildLoading(context, key: ValueKey('history_loading'));

      case HistoryStatus.failure:
        return _buildFailure(context, state.errorMessage!, key:  const ValueKey('history_failure'),);
      case HistoryStatus.success:
        return _buildSucessfulContent(state, context);
      }
  }

  Widget _buildSucessfulContent(HistoryState state, BuildContext context) {
     final orders = state.historyOrders;
    if (orders.isEmpty) {
      return _buildEmpty(context, key: ValueKey('history_empty'));
    }
    
    return ListView.separated(
      key: const ValueKey('history_list'),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderItem(
          context,
          Theme.of(context).colorScheme,
          order,
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

  Widget _buildEmpty(BuildContext context, {required Key key}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      key: key,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono grande dentro de círculo (más llamativo)
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.12),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.history_rounded,
                size: 44,
                color: colorScheme.primary,
              ),
            ),

            const SizedBox(height: 18),

            // Título
            Text(
              "No hay historial disponible",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colorScheme.inverseSurface,
              ),
            ),

            const SizedBox(height: 8),

            // Subtítulo explicativo
            Text(
              "Aquí aparecerán tus órdenes pasadas. Si deberías ver órdenes, "
              "verifica tu conexión o inténtalo de nuevo más tarde.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
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

    return Center(
      key: key,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 28.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icono grande con color principal de la app y sombra sutil
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.12),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 36,
                color: colorScheme.primary,
              ),
            ),

            const SizedBox(height: 16),

            // Título del error
            Text(
              'No se pudo cargar el historial',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            // Mensaje explicativo más detallado (pasado por parámetro)
            Text(
              message.isNotEmpty
                  ? message
                  : 'Revisa tu conexión e inténtalo de nuevo más tarde.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.75),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(
    BuildContext context,
    ColorScheme colorScheme,
    HorderEntity order,
  ) {
    final formatYmd = formatDateToYMD(order.initDate);
    final formatAmPm = formatTimeToAmPm(order.initDate);
    final String date = "$formatYmd, $formatAmPm";

    void selectOrder() {
      context.read<HistoryBloc>().add(SelectHistoryOrder(order: order));
      context.push(Routes.historyOrder, extra: context.read<HistoryBloc>());
    }

    return Column(
      children: [
        // Banner fecha
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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

        // Tarjeta de orden
        InkWell(
          onTap: selectOrder,
          borderRadius: BorderRadius.circular(12),
          child: Container(
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.receipt_long_rounded,
                            size: 18,
                            color: colorScheme.inverseSurface,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Orden #${order.orderCode}",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.inverseSurface,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 18,
                            color: colorScheme.inverseSurface.withOpacity(0.8),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              order.copyShopName,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: colorScheme.inverseSurface.withOpacity(
                                  0.8,
                                ),
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Precio y boton ver
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "\$${order.price.toStringAsFixed(2)}",
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
        ),
      ],
    );
  }
}
