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
    final primary = Theme.of(context).colorScheme.primary;
    
    return Scaffold(
      backgroundColor: primary,
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
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(20)),
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
      leadingIcon: Icons.history,
      leadingIconSize: 25,
      actionIcon: Icons.close_sharp,
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

        return Column(
          children: [
            _buildTitleRow(context, width, monthTitle),
            _buildSectionContainer(context, width, orders),
          ],
        );
      },
    );
  }

  Widget _buildTitleRow(BuildContext context, double width, String title) {
    final inverse = Theme.of(context).colorScheme.inverseSurface;
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: width * 0.83,
      child: Row(
        children: [
          Text(
            title, // el mes como título
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: inverse,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_drop_down, size: 25),
        ],
      ),
    );
  }

  Widget _buildSectionContainer(
      BuildContext context, double width, List<AorderEntity> orders) {
    final content = _chooseContent(context, orders);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(bottom: 25),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, width: 2),
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        width: width * 0.83,
        child: content,
      ),
    );
  }

  // ---------- Contenido condicional ----------
  Widget _chooseContent(BuildContext context, List<AorderEntity> orders) {
    if (_isLoading) return _buildLoading(context);
    if (orders.isEmpty) return _buildEmpty(context);
    return _buildList(context, orders);
  }

  Widget _buildLoading(BuildContext context) {
    return const Center(child: CircularProgressIndicator(strokeWidth: 5));
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Icon(Icons.hide_source, color: Colors.grey.shade300, size: 100),
    );
  }

  Widget _buildList(BuildContext context, List<AorderEntity> orders) {
    final primary = Theme.of(context).colorScheme.primary;
    final inverse = Theme.of(context).colorScheme.inverseSurface;
    final adminHomeBloc = context.read<AdminHomeBloc>();

    return ListView.separated(
      padding: const EdgeInsets.only(top: 0, bottom: 8),
      physics: const BouncingScrollPhysics(),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 20),
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade600),
                color: primary,
                borderRadius: BorderRadius.circular(10),
              ),
              width: double.infinity,
              child: Text(
                date,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // tarjeta de orden
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              width: double.infinity,
              height: 95,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Info izquierda
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 80,
                            child: Text(
                              "Ord #${item.orderCode}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: inverse,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 2.5),
                          Icon(Icons.receipt_long, color: inverse, size: 18),
                        ],
                      ),
                      Text(
                        item.userRegistration,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: inverse,
                        ),
                      ),
                    ],
                  ),

                  // Precio
                  Padding(
                    padding: const EdgeInsets.only(right: 1.7),
                    child: Text(
                      "${item.price}\$",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: inverse,
                      ),
                    ),
                  ),

                  // Botón ver
                  ElevatedButton(
                    onPressed: selectOrder,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: primary,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                    ),
                    child: const Icon(Icons.remove_red_eye),
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
