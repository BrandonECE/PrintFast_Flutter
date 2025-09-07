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
  const MyAdminOrdersView({super.key});
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final primary = Theme.of(context).colorScheme.primary;

    return _myBody(width, context);
  }

  Center _myBody(double width, BuildContext context) {
    return Center(
      child: Container(
        width: width * 0.95,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: _buildBody(context, width),
      ),
    );
  }

  // ---------------- Body: título + sección ----------------
  Widget _buildBody(BuildContext context, double width) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Expanded(
      child: Column(
        children: [
          _buildTitleRow(context, width),
          SizedBox(height: 5),
          DefaultTabController(
            length: 2,
            initialIndex: 0,
            child: Expanded(
              child: Column(
                children: [
                  SizedBox(
                    width: width * 0.83,
                    child: SegmentedTabControl(
                      textStyle: Theme.of(context).textTheme.titleMedium,
                      splashColor: Colors.white.withOpacity(0.1),
                      selectedTextStyle: Theme.of(context).textTheme.titleSmall!
                          .copyWith(fontWeight: FontWeight.w600),
                      tabTextColor:
                          primaryColor, // color de texto no seleccionado
                      selectedTabTextColor:
                          Colors.white, // color de texto seleccionado
                      height: 57.5,
                      indicatorPadding: const EdgeInsets.all(0),
                      squeezeIntensity: 2,
                      tabPadding: const EdgeInsets.symmetric(horizontal: 4),

                      // Barra blanca con borde
                      barDecoration: BoxDecoration(
                        color: Colors.white, // <-- fondo blanco
                        borderRadius: BorderRadius.circular(20),
                      ),

                      // Solo la pestaña seleccionada en color primary
                      indicatorDecoration: BoxDecoration(
                        color: primaryColor, // <-- color del botón activo
                        borderRadius: BorderRadius.circular(20),
                      ),

                      tabs: [
                        SegmentTab(label: 'Aceptadas'),
                        SegmentTab(label: 'Pend. (3)', color: Colors.redAccent),
                      ],
                    ),
                  ),
                  Expanded(
                    child: BlocBuilder<AdminHomeBloc, AdminHomeState>(
                      builder: (context, state) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 25, top: 20),
                          child: TabBarView(
                            children: [
                              Center(
                                child: _buildSectionContainer(
                                  context,
                                  width,
                                  _buildList(context, state.acceptedOrders),
                                ),
                              ),
                              Center(
                                child: _buildSectionContainer(
                                  context,
                                  width,
                                  _buildList(context, state.pendingOrders),
                                ),
                              ),
                            ],
                          ),
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

  Widget _buildTitleRow(BuildContext context, double width) {
    final inverse = Theme.of(context).colorScheme.inverseSurface;
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
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
                  fontWeight: FontWeight.bold,
                  color: inverse,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_drop_down, size: 25),
            ],
          ),

          StatusPill(
            isOnline: true, 
            onTap: () {
            },
          ),

        ],
      ),
    );
  }

  Widget _buildSectionContainer(
    BuildContext context,
    double width,
    Widget content,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
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
        final String date = "$formatYmd , $formatAmPm ";

        void selectOrder(){
          adminHomeBloc.add(AdminHomeUpdateSelectedOrderEvent(selectedOrder: orders[index]));
          context.push(Routes.adminOrderView);
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
                          SizedBox(width: 2.5),
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


class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.isOnline,
    this.onTap,
  });

  final bool isOnline;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color onlineColor = Colors.greenAccent.shade700;
    final Color pausedColor = Colors.orangeAccent.shade700;
    final Color bg = isOnline ? onlineColor : pausedColor;
    final String label = isOnline ? 'Disponible' : 'Pausada';
    final IconData icon = isOnline ? Icons.check_circle : Icons.pause_circle;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: Colors.white24,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: bg.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: bg.withOpacity(0.23), width: 1.2)
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: bg),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: bg,
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
}