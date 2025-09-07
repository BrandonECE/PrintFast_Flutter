import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:printfast_rebuild/config/routes/routes.dart';
import 'package:printfast_rebuild/domain/entities/entities.dart';
import 'package:printfast_rebuild/presentation/blocs/user_blocs/home_bloc/home_bloc.dart';
import 'package:printfast_rebuild/presentation/widgets/widgets.dart';
import 'package:printfast_rebuild/utils/utils.dart';

/// Modelo ligero para diseño
class _DemoOrder {
  final String place;
  final String dateTimeComplete;
  final String price;
  const _DemoOrder(this.place, this.dateTimeComplete, this.price);
}

/// MyHistoryPureDesign
/// Solo DISEÑO: StatelessWidget, sin parámetros, sin lógica.
/// Variables internas (hardcoded) para ver los 3 estados: loading, empty, list.
class MyHistoryView extends StatelessWidget {
  const MyHistoryView({super.key});

  // ---------- Build ----------
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

  Center _myBody(double width, BuildContext context) {
    return Center(
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
    );
  }

  // ---------- Cuerpo: título + sección (contiene contenido condicional) ----------
  Widget _buildBody(BuildContext context, double width) {
    return Column(
      children: [
        _buildTitleRow(context, width),
        _buildSectionContainer(context, width),
      ],
    );
  }

  Widget _buildTitleRow(BuildContext context, double width) {
    final inverse = Theme.of(context).colorScheme.inverseSurface;
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: width * 0.83,
      child: Row(
        children: [
          Text(
            "Ordenes",
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

  Widget _buildSectionContainer(BuildContext context, double width) {
    return Expanded(
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          final Widget content = _chooseContent(context, state.historyOrders);
          return Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 25),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300, width: 2),
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            width: width * 0.83,
            child: SizedBox(
              height: 400, // demo: reemplaza por Expanded en integración real
              child: content,
            ),
          );
        },
      ),
    );
  }

  // ---------- Contenido condicional ----------
  Widget _chooseContent(
    BuildContext context,
    List<AorderEntity> historyOrders,
  ) {
    // if (_isLoading) return _buildLoading(context);
    if (historyOrders.isEmpty) return _buildEmpty(context);
    return _buildList(context, historyOrders);
  }

  Widget _buildLoading(BuildContext context) {
    return const Center(child: CircularProgressIndicator(strokeWidth: 5));
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Icon(Icons.hide_source, color: Colors.grey.shade300, size: 100),
    );
  }

  Widget _buildList(BuildContext context, List<AorderEntity> historyOrders) {
    final primary = Theme.of(context).colorScheme.primary;
    final inverse = Theme.of(context).colorScheme.inverseSurface;
    final homeBloc = context.read<HomeBloc>();

    return ListView.separated(
      padding: const EdgeInsets.only(top: 0, bottom: 8),
      physics: const BouncingScrollPhysics(),
      itemCount: historyOrders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 20),
      itemBuilder: (context, index) {

        void selectOrder() {
          homeBloc.add(
            HomeUpdateSelectedOrderEvent(
              selectedOrder: historyOrders[index],
            ),
          );
          context.push(Routes.historyOrder);
        }

        final item = historyOrders[index];
        final formatYmd = formatDateToYMD(item.estimatedDeliveryTime!);
        final formatAmPm = formatTimeToAmPm(item.estimatedDeliveryTime!);
        final String date = "$formatYmd , $formatAmPm ";

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
              height: 85,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 60,
                        child: Text(
                          item.place,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: inverse,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.location_on_rounded, color: inverse, size: 18),
                    ],
                  ),
                  Text(
                    "${item.price}\$",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: inverse,
                    ),
                  ),
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
