// lib/presentation/views/notifications_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:printfast_rebuild/di/service_locator.dart';
import 'package:printfast_rebuild/domain/entities/entities.dart';
import 'package:printfast_rebuild/domain/repositories/user_repository.dart';
import 'package:printfast_rebuild/presentation/widgets/widgets.dart';
import 'package:printfast_rebuild/utils/utils.dart';
import 'package:printfast_rebuild/presentation/blocs/user_blocs/notifications_bloc/notifications_bloc.dart';
import 'package:printfast_rebuild/presentation/blocs/user_blocs/home_bloc/home_bloc.dart';

class MyNotificationsView extends StatelessWidget {
  const MyNotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final colorScheme = Theme.of(context).colorScheme;

    final homeState = context.read<HomeBloc>().state;
    final registration = homeState.userEntity.registration;

    return BlocProvider(
      create: (_) => NotificationsBloc(
        userRepository: getIt<UserRepository>(),
        registration: registration,
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
              child: _NotificationsBody(width: width),
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

class _NotificationsBody extends StatelessWidget {
  final double width;
  const _NotificationsBody({required this.width});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildTitleRow(context, width),
          const SizedBox(height: 16),
          Expanded(
            child: _buildSectionContainer(context, width),
          ),
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
          Icon(Icons.arrow_drop_down, size: 25, color: colorScheme.inverseSurface),
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
      // Aquí usamos AnimatedSwitcher para transiciones de contenido (loader/list/empty/error)
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: BlocBuilder<NotificationsBloc, NotificationsState>(
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

  Widget _contentForState(BuildContext context, NotificationsState state) {
    switch (state.status) {
      case NotificationsStatus.loading:
        return _buildLoading(context, key: const ValueKey('loading'));
      case NotificationsStatus.failure:
        return _buildFailure(context, state.errorMessage ?? 'Error desconocido', key: const ValueKey('failure'));
      case NotificationsStatus.success:
        if (state.notifications.isEmpty) {
          return _buildEmpty(context, key: const ValueKey('empty'));
        } else {
          return _buildList(context, state.notifications, key: const ValueKey('list'));
        }
      default:
        // mostrar loader mientras llega algo
        return _buildLoading(context, key: const ValueKey('initial_loading'));
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
                Icons.notifications_off_rounded,
                size: 44,
                color: colorScheme.primary,
              ),
            ),

            const SizedBox(height: 18),

            // Título
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

            // Subtítulo explicativo
            Text(
              "Aquí verás las alertas relacionadas con tus pedidos y el servicio. "
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

  Widget _buildFailure(BuildContext context, String message, {required Key key}) {
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
            'No se pudieron cargar las notificaciones',
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

  Widget _buildList(BuildContext context, List<NotificationEntity> notifications, {required Key key}) {
    return ListView.separated(
      key: key,
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: notifications.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) => _buildNotificationItem(context, notifications[index]),
    );
  }

  Widget _buildNotificationItem(BuildContext context, NotificationEntity item) {
    final colorScheme = Theme.of(context).colorScheme;
    final formatYmd = formatDateToYMD(item.dateTime!);
    final formatAmPm = formatTimeToAmPm(item.dateTime!);
    final String date = "$formatYmd , $formatAmPm";

    return Column(
      children: [
        // banner fecha
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
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
        const SizedBox(height: 12),

        // tarjeta de notificación
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3)),
            ],
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              // icono circular
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: colorScheme.primary.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2)),
                  ],
                ),
                child: Icon( Icons.shopping_basket_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),

              // texto (asunto + mensaje)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.subject,
                      style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.inverseSurface, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.message,
                      style: TextStyle(color: colorScheme.inverseSurface.withOpacity(0.8), fontSize: 14),
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
