import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:printfast_rebuild/config/routes/routes.dart';
import 'package:printfast_rebuild/presentation/blocs/admin_blocs/admin_home_bloc/admin_home_bloc.dart';
import 'package:printfast_rebuild/presentation/widgets/appbar_widget.dart';
import 'package:printfast_rebuild/utils/utils.dart';

import '../../../../../domain/entities/entities.dart';

class MyAdminMonthOrdersHistorySelectedView extends StatelessWidget {
  const MyAdminMonthOrdersHistorySelectedView({super.key});

  // ---------- Estatus visual ----------
  final bool _isLoading = false;

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
    return BlocBuilder<AdminHomeBloc, AdminHomeState>(
      builder: (context, state) {
        final selected = state.monthOrderHistoryElementSelected;

        if (selected == null || selected.isEmpty) {
          return Expanded(child: _buildEmpty(context));
        }

        // Solo hay un elemento → el mes seleccionado
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
          Icon(Icons.arrow_drop_down, 
               size: 25, 
               color: colorScheme.inverseSurface),
        ],
      ),
    );
  }

  Widget _buildSectionContainer(
      BuildContext context, double width, List<AorderEntity> orders) {
    final content = _chooseContent(context, orders);

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

  // ---------- Contenido condicional ----------
  Widget _chooseContent(BuildContext context, List<AorderEntity> orders) {
    if (_isLoading) return _buildLoading(context);
    if (orders.isEmpty) return _buildEmpty(context);
    return _buildList(context, orders);
  }

  Widget _buildLoading(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: CircularProgressIndicator(strokeWidth: 3),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
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
            "No hay órdenes en este período",
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, List<AorderEntity> orders) {
    final colorScheme = Theme.of(context).colorScheme;
    final adminHomeBloc = context.read<AdminHomeBloc>();

    return ListView.separated(
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
          adminHomeBloc.add(
            AdminHomeUpdateSelectedOrderEvent(selectedOrder: item),
          );
          context.push(Routes.adminOrderHistoryView);
        }

        return Column(
          children: [
            // fecha banner
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Info izquierda
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
                              "Ord #${item.orderCode}",
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
                              item.userRegistration,
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

                  // Precio y botón
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
}