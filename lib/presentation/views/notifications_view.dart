import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:printfast_rebuild/domain/entities/entities.dart';
import 'package:printfast_rebuild/presentation/widgets/widgets.dart';
import 'package:printfast_rebuild/utils/utils.dart';

/// MyNotificationsPureDesign
/// Solo DISEÑO: StatelessWidget, sin parámetros, sin lógica.
/// Variables internas para simular loading / empty / lista.
class MyNotificationsView extends StatelessWidget {
  MyNotificationsView({super.key});

  // Edita estas variables para probar estados:
  final bool _isLoading = false;
  // Para simular "sin notificaciones" deja la lista vacía: []
  final List<NotificationEntity> _notifications =  [
    NotificationEntity(subject: "Orden Finalizada", message: "Pedido Entregado.", dateTime:  DateTime.now(), seen: false),
    NotificationEntity(subject: "Orden Activa", message: "Pedido Listo.", dateTime:  DateTime.now(), seen: false),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: primary,
      appBar: _myAppBar(context) ,
      body: _myBody(width, context));
  }

  MyAppBarWidget _myAppBar(BuildContext context) {
    return MyAppBarWidget(title: "Notificaciones", leadingIcon: Icons.notifications, leadingIconSize: 25, actionIcon: Icons.close_sharp, actionIconSize: 25, onAction: () => context.canPop() ? context.pop() : null,);
  }

  Center _myBody(double width, BuildContext context) {
    return Center(
    child: Padding(
      padding:  EdgeInsets.only(bottom: width * 0.025),
      child: Container(
        width: width * 0.95,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(20))),
        child: _buildBody(context, width),
      ),
    ),
  );
  }


  // ---------------- Body: título + sección ----------------
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
          Text("Todas", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: inverse)),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_drop_down, size: 25),
        ],
      ),
    );
  }

  Widget _buildSectionContainer(BuildContext context, double width) {
    final Widget content = _chooseContent(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(bottom: 25),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300, width: 2), color: Colors.grey.shade200, borderRadius: BorderRadius.circular(20)),
        width: width * 0.83,
        child: SizedBox(
          height: 420, // demo height; reemplaza por Expanded en integración real
          child: content,
        ),
      ),
    );
  }

  // ---------------- Contenido condicional ----------------
  Widget _chooseContent(BuildContext context) {
    if (_isLoading) return _buildLoading(context);
    if (_notifications.isEmpty) return _buildEmpty(context);
    return _buildList(context);
  }

  Widget _buildLoading(BuildContext context) {
    return const Center(child: CircularProgressIndicator(strokeWidth: 5));
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(child: Icon(Icons.hide_source, color: Colors.grey.shade300, size: 100));
  }

  // ---------------- Lista de notificaciones (UI) ----------------
  Widget _buildList(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.only(top: 0, bottom: 8),
      physics: const BouncingScrollPhysics(),
      itemCount: _notifications.length,
      separatorBuilder: (_, __) => const SizedBox(height: 20),
      itemBuilder: (context, index) => _buildNotificationItem(context, index),
    );
  }

  Widget _buildNotificationItem(BuildContext context, int index) {
    final primary = Theme.of(context).colorScheme.primary;
    final inverse = Theme.of(context).colorScheme.inverseSurface;
    final item = _notifications[index];
    final formatYmd = formatDateToYMD(item.dateTime!);
    final formatAmPm = formatTimeToAmPm(item.dateTime!);

    // Formateo visual de la fecha (demo similar al original)
    final String fecha = "$formatYmd , $formatAmPm ";

    return Column(
      children: [
        // banner fecha
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade600), color: primary, borderRadius: BorderRadius.circular(10)),
          width: double.infinity,
          child: Text(fecha, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 10),

        // tarjeta de notificación
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), color: Colors.white, borderRadius: BorderRadius.circular(10)),
          width: double.infinity,
          height: 95,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // icono circular
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: primary, borderRadius: const BorderRadius.all(Radius.circular(100))),
                child: const Icon(Icons.shopping_basket, color: Colors.white),
              ),

              // texto (asunto + mensaje)
              Expanded(
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 17),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(item.subject, style: TextStyle(fontWeight: FontWeight.bold, color: inverse)),
                      const SizedBox(height: 0),
                      Text(item.message, style: TextStyle(color: inverse)),
                    ]),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
