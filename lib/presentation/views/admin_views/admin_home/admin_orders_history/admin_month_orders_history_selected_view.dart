import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:printfast_rebuild/config/routes/routes.dart';
import 'package:printfast_rebuild/domain/entities/entities.dart';
import 'package:printfast_rebuild/presentation/blocs/admin_blocs/admin_history_bloc/admin_history_bloc.dart';
import 'package:printfast_rebuild/presentation/widgets/appbar_widget.dart';
import 'package:printfast_rebuild/presentation/widgets/widgets.dart';
import 'package:printfast_rebuild/utils/utils.dart';

class MyAdminMonthOrdersHistorySelectedView extends StatelessWidget {
  const MyAdminMonthOrdersHistorySelectedView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      appBar: _myAppBar(context),
      body: _myBody(width, context),
    );
  }

  SafeArea _myBody(double width, BuildContext context) {
    return SafeArea(
      child: Center(
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

  MyAppBarWidget _myAppBar(BuildContext context) {
    return MyAppBarWidget(
      title: "Historial",
      leadingIcon: Icons.history_rounded,
      leadingIconSize: 25,
      actionIcon: Icons.close_rounded,
      actionIconSize: 25,
      onAction: () => context.canPop() ? context.pop() : null,
    );
  }

  Widget _buildBody(BuildContext context, double width) {
    return BlocBuilder<AdminHistoryBloc, AdminHistoryState>(
      builder: (context, state) {
        final selected = state.monthOrderHistoryElementSelected;

        if (selected.isEmpty) {
          return Expanded(child: _buildEmpty(context));
        }

        final entry = selected.entries.first;
        final monthTitle = entry.key;
        final orders = entry.value;

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildTitleRow(context, width, monthTitle),
              const SizedBox(height: 16),
              Expanded(child: _buildSectionContainer(context, width, orders)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTitleRow(BuildContext context, double width, String title) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: width * 0.83,
      child: Row(
        children: [
          Text(
            title,
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

  Widget _buildSectionContainer(BuildContext context, double width, List<HorderEntity> orders) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      width: width * 0.83,
      child: _buildList(context, orders),
    );
  }

  Widget _buildList(BuildContext context, List<HorderEntity> orders) {
    if (orders.isEmpty) {
      return _buildEmpty(context);
    }
    
    return ListView.separated(
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderItem(context, order);
      },
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
            Text(
              "No hay órdenes en este mes",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colorScheme.inverseSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(BuildContext context, HorderEntity order) {
    final colorScheme = Theme.of(context).colorScheme;
    final formatYmd = formatDateToYMD(order.initDate);
    final formatAmPm = formatTimeToAmPm(order.initDate);
    final String date = "$formatYmd, $formatAmPm";

    void selectOrder() {
      context.read<AdminHistoryBloc>().add(SelectAdminHistoryOrder(order: order));
      context.push(Routes.adminOrderHistoryView, extra: context.read<AdminHistoryBloc>());
    }

    return Column(
      children: [
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
                            Icons.person_2_rounded,
                            size: 18,
                            color: colorScheme.inverseSurface.withOpacity(0.8),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            order.copyShopName,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: colorScheme.inverseSurface.withOpacity(0.8),
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