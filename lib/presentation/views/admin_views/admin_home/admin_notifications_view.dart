import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:printfast_rebuild/di/service_locator.dart';
import 'package:printfast_rebuild/domain/entities/entities.dart';
import 'package:printfast_rebuild/domain/repositories/admin_repository.dart';
import 'package:printfast_rebuild/presentation/blocs/admin_blocs/admin_home_bloc/admin_home_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/admin_blocs/admin_notifications_bloc/admin_notifications_bloc.dart';

import 'package:printfast_rebuild/presentation/widgets/widgets.dart';
import 'package:printfast_rebuild/utils/utils.dart';

class MyAdminNotificationsView extends StatelessWidget {
  const MyAdminNotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final colorScheme = Theme.of(context).colorScheme;

    final adminHomeBloc = context.read<AdminHomeBloc>();

    final copyShopEmail = context
        .read<AdminHomeBloc>()
        .state
        .userEntity
        .adminLocationByEmail;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) =>
          adminHomeBloc.add(AdminHomeMarkAllNotificationsAsSeenEvent()),
      child: BlocProvider(
        create: (_) => AdminNotificationsBloc(
          adminRepository: getIt<AdminRepository>(),
          copyShopEmail: copyShopEmail,
        ),
        child: Scaffold(
          backgroundColor: colorScheme.primary,
          appBar: _myAppBar(context),
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
                child: _AdminNotificationsBody(width: width),
              ),
            ),
          ),
        ),
      ),
    );
  }

  MyAppBarWidget _myAppBar(BuildContext context) {
    return MyAppBarWidget(
      title: "Notificaciones",
      leadingIcon: Icons.notifications_rounded,
      leadingIconSize: 25,
      actionIcon: Icons.close_rounded,
      actionIconSize: 25,
      onAction: () => context.canPop() ? context.pop() : null,
    );
  }
}

class _AdminNotificationsBody extends StatelessWidget {
  final double width;
  const _AdminNotificationsBody({required this.width});

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
    return Container(
      width: width * 0.83,
      child: Row(
        children: [
          Text(
            "Todas",
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
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildSectionContainer(BuildContext context, double width) {
    return Container(
      width: width * 0.83,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: BlocBuilder<AdminNotificationsBloc, AdminNotificationsState>(
          builder: (context, state) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 225),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: _contentForState(context, state),
            );
          },
        ),
      ),
    );
  }

  Widget _contentForState(BuildContext context, AdminNotificationsState state) {
    switch (state.status) {
      case AdminNotificationsStatus.loading:
        return _buildLoading(context, key: const ValueKey('loading'));
      case AdminNotificationsStatus.failure:
        return _buildFailure(
          context,
          state.errorMessage ?? 'Error desconocido',
          key: const ValueKey('failure'),
        );
      case AdminNotificationsStatus.success:
        if (state.notifications.isEmpty) {
          return _buildEmpty(context, key: const ValueKey('empty'));
        } else {
          return _buildList(
            context,
            state.notifications,
            key: const ValueKey('list'),
          );
        }
    }
  }

  Widget _buildLoading(BuildContext context, {required Key key}) {
    return Center(
      key: key,
      child: Padding(
        padding: const EdgeInsets.all(32),
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
                Icons.notifications_off_rounded,
                size: 44,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              "Nada por aquí todavía",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colorScheme.inverseSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Aquí verás las alertas relacionadas con los pedidos de tu copyshop. "
              "Si esperabas una notificación, prueba actualizar o revisa los ajustes.",
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
              'No se pudieron cargar las notificaciones',
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
                  : 'Revisa tu conexión a internet e intenta de nuevo más tarde.',
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

  Widget _buildList(
    BuildContext context,
    List<NotificationEntity> notifications, {
    required Key key,
  }) {
    return ListView.separated(
      key: key,
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: notifications.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) =>
          _buildNotificationItem(context, notifications[index]),
    );
  }

  Widget _buildNotificationItem(BuildContext context, NotificationEntity item) {
    final colorScheme = Theme.of(context).colorScheme;
    final formatYmd = formatDateToYMD(item.dateTime!);
    final formatAmPm = formatTimeToAmPm(item.dateTime!);
    final String date = "$formatYmd , $formatAmPm";
    final bool isUnseen = !item.seen;

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
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isUnseen ? colorScheme.primary : Colors.grey.shade400.withOpacity(0.5),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color:  isUnseen ? colorScheme.primary.withOpacity(0.3) : Colors.transparent,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.shopping_basket_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.subject,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.inverseSurface,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.message,
                      style: TextStyle(
                        color: colorScheme.inverseSurface.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
