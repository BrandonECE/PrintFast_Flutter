
import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:printfast_rebuild/config/routes/routes.dart';
import 'package:printfast_rebuild/domain/entities/entities.dart';
import 'package:printfast_rebuild/presentation/blocs/admin_blocs/admin_home_bloc/admin_home_bloc.dart';
// import 'package:printfast_rebuild/presentation/widgets/widgets.dart';
import 'package:printfast_rebuild/utils/utils.dart';

class MyAdminOrdersView extends StatelessWidget {
  const MyAdminOrdersView({super.key, required this.callBack});
  final void Function(int index) callBack;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // ignore: unused_local_variable
    final colorScheme = Theme.of(context).colorScheme;

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
                  SizedBox(
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
                      tabTextColor: colorScheme.inverseSurface.withOpacity(0.7),
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
                        SegmentTab(label: 'Pend. (3)', color: Colors.redAccent),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: BlocBuilder<AdminHomeBloc, AdminHomeState>(
                      builder: (context, state) {
                        return TabBarView(
                          children: [
                            _buildSectionContainer(
                              context,
                              width,
                              _buildList(context, state.acceptedOrders),
                            ),
                            _buildSectionContainer(
                              context,
                              width,
                              _buildList(context, state.pendingOrders),
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
          StatusPill(
            isOnline: true,
            onTap: () => callBack.call(3),
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
            AdminHomeUpdateSelectedOrderEvent(selectedOrder: orders[index]),
          );
          context.push(Routes.adminOrderView);
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
}

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.isOnline, this.onTap});

  final bool isOnline;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color onlineColor = Colors.green;
    final Color pausedColor = Colors.orange;
    final Color bg = isOnline ? onlineColor : pausedColor;
    final String label = isOnline ? 'Disponible' : 'Pausada';
    final IconData icon = isOnline ? Icons.check_circle : Icons.pause_circle;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: bg.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: bg.withOpacity(0.3), width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: bg),
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
    );
  }
}
