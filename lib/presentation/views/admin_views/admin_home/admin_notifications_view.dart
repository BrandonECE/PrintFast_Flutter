import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:printfast_rebuild/domain/entities/entities.dart';
import 'package:printfast_rebuild/presentation/widgets/widgets.dart';
import 'package:printfast_rebuild/utils/utils.dart';

class MyAdminNotificationsView extends StatelessWidget {
  MyAdminNotificationsView({super.key});

  // Edita estas variables para probar estados:
  final bool _isLoading = false;
  // Para simular "sin notificaciones" deja la lista vacía: []
  final List<NotificationEntity> _notifications = [
    NotificationEntity(
      subject: "Cancelada #234",
      message: "Usuario: 1974238",
      dateTime: DateTime.now().add(const Duration(minutes: 2)),
      seen: false,
    ),
    NotificationEntity(
      subject: "Nueva Orden #235",
      message: "Usuario: 1974239",
      dateTime: DateTime.now(),
      seen: false,
    ),
  ];

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

  Center _myBody(double width, BuildContext context) {
    return Center(
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
    );
  }

  // ---------------- Body: título + sección ----------------
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
          Icon(Icons.arrow_drop_down, 
               size: 25, 
               color: colorScheme.inverseSurface),
        ],
      ),
    );
  }

  Widget _buildSectionContainer(BuildContext context, double width) {
    final Widget content = _chooseContent(context);

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

  // ---------------- Contenido condicional ----------------
  Widget _chooseContent(BuildContext context) {
    if (_isLoading) return _buildLoading(context);
    if (_notifications.isEmpty) return _buildEmpty(context);
    return _buildList(context);
  }

  Widget _buildLoading(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: MyLoadingIndicator(),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_rounded,
            color: Colors.grey.shade300,
            size: 80,
          ),
          const SizedBox(height: 16),
          Text(
            "No hay notificaciones",
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Lista de notificaciones (UI) ----------------
  Widget _buildList(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: _notifications.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) => _buildNotificationItem(context, index),
    );
  }

  Widget _buildNotificationItem(BuildContext context, int index) {
    final colorScheme = Theme.of(context).colorScheme;
    final item = _notifications[index];
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
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
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
              // icono circular
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.shopping_basket_rounded, 
                  color: Colors.white, 
                  size: 24
                ),
              ),
              const SizedBox(width: 16),

              // texto (asunto + mensaje)
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