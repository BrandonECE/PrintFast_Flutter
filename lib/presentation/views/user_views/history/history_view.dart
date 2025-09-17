import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:printfast_rebuild/config/routes/routes.dart';
import 'package:printfast_rebuild/domain/entities/entities.dart';
import 'package:printfast_rebuild/presentation/blocs/user_blocs/home_bloc/home_bloc.dart';
import 'package:printfast_rebuild/presentation/widgets/widgets.dart';
import 'package:printfast_rebuild/utils/utils.dart';

class MyHistoryView extends StatelessWidget {
  const MyHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
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
            child: _buildBody(context, width),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, double width) {
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
          Icon(Icons.arrow_drop_down, 
               size: 25, 
               color: colorScheme.inverseSurface),
        ],
      ),
    );
  }

  Widget _buildSectionContainer(BuildContext context, double width) {
    final colorScheme = Theme.of(context).colorScheme;
    final homeBloc = context.read<HomeBloc>();

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final historyOrders = state.historyOrders;

        if (historyOrders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history_rounded,
                  color: Colors.grey.shade300,
                  size: 80,
                ),
                const SizedBox(height: 16),
                Text(
                  "No hay historial disponible",
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
          ),
          width: width * 0.83,
          child: ListView.separated(
            itemCount: historyOrders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final order = historyOrders[index];
              return _buildOrderItem(
                context,
                colorScheme,
                order,
                homeBloc,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildOrderItem(
    BuildContext context,
    ColorScheme colorScheme,
    AorderEntity order,
    HomeBloc homeBloc,
  ) {
    final formatYmd = formatDateToYMD(order.initDate);
    final formatAmPm = formatTimeToAmPm(order.initDate);
    final String date = "$formatYmd, $formatAmPm";

    void selectOrder() {
      homeBloc.add(
        HomeUpdateSelectedOrderEvent(selectedOrder: order),
      );
      context.push(Routes.historyOrder);
    }

    return Column(
      children: [
        // Banner con fecha de orden
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Información de la orden
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Código de orden
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
                    
                    // Lugar
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
                            order.place,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: colorScheme.inverseSurface.withOpacity(0.8),
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

              // Precio y botón
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
      ],
    );
  }
}