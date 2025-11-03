import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:printfast_rebuild/config/routes/routes.dart';
import 'package:printfast_rebuild/di/service_locator.dart';
import 'package:printfast_rebuild/domain/entities/entities.dart';
import 'package:printfast_rebuild/domain/repositories/admin_repository.dart';
import 'package:printfast_rebuild/presentation/blocs/admin_blocs/admin_history_bloc/admin_history_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/admin_blocs/admin_home_bloc/admin_home_bloc.dart';
import 'package:printfast_rebuild/presentation/widgets/widgets.dart';

class MyAdminOrdersHistoryView extends StatelessWidget {
  const MyAdminOrdersHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final colorScheme = Theme.of(context).colorScheme;
    final copyShopEmail = context.read<AdminHomeBloc>().state.userEntity.adminLocationByEmail;

    return BlocProvider(
      create: (context) => AdminHistoryBloc(
        emailCopyShop: copyShopEmail, 
        adminRepository: getIt<AdminRepository>()
      )..add(LoadAdminHistory()),
      child: Scaffold(
        backgroundColor: colorScheme.primary,
        body: _myBody(width, context),
      ),
    );
  }

  SafeArea _myBody(double width, BuildContext context) {
    return SafeArea(
      child: Center(
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
    );
  }
  Widget _buildBody(BuildContext context, double width) {
    return BlocBuilder<AdminHistoryBloc, AdminHistoryState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildTitleRow(context, width),
              const SizedBox(height: 16),
              Expanded(child: _buildSectionContainer(context, width, state)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTitleRow(BuildContext context, double width) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      width: width * 0.83,
      child: Row(
        children: [
          Text(
            "Historial",
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

  Widget _buildSectionContainer(BuildContext context, double width, AdminHistoryState state) {

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
  }

  Widget _contentForState(BuildContext context, AdminHistoryState state) {
    switch (state.status) {
      case AdminHistoryStatus.loading:
        return _buildLoading(context, key: const ValueKey('admin_history_loading'));
      case AdminHistoryStatus.failure:
        return _buildFailure(context, state.errorMessage!, key: const ValueKey('admin_history_failure'));
      case AdminHistoryStatus.success:
        return _buildSuccessContent(state, context);
    }
  }

  Widget _buildSuccessContent(AdminHistoryState state, BuildContext context) {
    final monthMap = state.monthOrderHistoryMap;
    if (monthMap.isEmpty) {
      return _buildEmpty(context, key: const ValueKey('admin_history_empty'));
    }
    
    return ListView.separated(
      key: const ValueKey('admin_history_list'),
      itemCount: monthMap.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final entry = monthMap.entries.elementAt(index);
        return _buildMonthSummary(
          context,
          entry.key,
          entry.value,
        );
      },
    );
  }

  Widget _buildMonthSummary(
    BuildContext context,
    String monthTitle,
    List<HorderEntity> orders,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final total = orders.length;
    final completed = orders.where((o) => !o.hasItBeenCanceled).length;
    final canceled = orders.where((o) => o.hasItBeenCanceled).length;

    void monthOrderHistoryElementSelect() {
      context.read<AdminHistoryBloc>().add(
        AdminMonthOrderHistoryElementSelectedEvent(
          monthOrderHistoryElementSelected: {monthTitle: orders},
        ),
      );
      context.push(Routes.adminMonthOrdersHistorySelectedView, extra: context.read<AdminHistoryBloc>());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
            monthTitle,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 12),
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
                          Icons.receipt_long_rounded,
                          size: 18,
                          color: colorScheme.inverseSurface,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Total: $total órdenes",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.inverseSurface,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 18,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "$completed",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.inverseSurface,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Row(
                          children: [
                            Icon(
                              Icons.cancel_rounded,
                              size: 18,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "$canceled",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.inverseSurface,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: monthOrderHistoryElementSelect,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: colorScheme.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  shadowColor: colorScheme.primary.withOpacity(0.3),
                ),
                child: const Icon(Icons.remove_red_eye, size: 20),
              ),
            ],
          ),
        ),
      ],
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

  Widget _buildEmpty(BuildContext context, {Key? key}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      key: key,
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
              "No hay historial disponible",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colorScheme.inverseSurface,
              ),
            ),
            const SizedBox(height: 8),
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

  Widget _buildFailure(BuildContext context, String message, {required Key key}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      key: key,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 28.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
}