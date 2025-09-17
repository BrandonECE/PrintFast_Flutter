import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:printfast_rebuild/presentation/widgets/widgets.dart';

class MyLiveTrackingView extends StatelessWidget {
  const MyLiveTrackingView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      appBar: _myAppBar(context),
      body: _myBody(width, height, context),
    );
  }

  MyAppBarWidget _myAppBar(BuildContext context) {
    return MyAppBarWidget(
      title: "Seguimiento",
      leadingIcon: Icons.directions_rounded,
      leadingIconSize: 25,
      actionIcon: Icons.close_rounded,
      actionIconSize: 25,
      onAction: () => context.canPop() ? context.pop() : null,
    );
  }

  Widget _myBody(double width, double height, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // demo (hardcoded para diseño)
    const demoPlaceName = "Sucursal Central";
    const demoDistance = "750 m";
    const demoTime = "12 min";
    const demoPrice = "15.00";
    
    // Tiempo restante en minutos (puedes cambiar este valor para probar)
    const remainingTime = 0; // 0, 2, 5, etc.

    final panelHeight = height * 0.28;
    final panelPadding = 12.0;

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
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Mapa placeholder
              _mapPlaceholder(),
              
              // Overlay degradado
              _gradientOverlay(panelHeight, panelPadding),

              // Panel inferior
              _bottomPanel(
                panelHeight: panelHeight,
                panelPadding: panelPadding,
                colorScheme: colorScheme,
                placeName: demoPlaceName,
                distance: demoDistance,
                time: demoTime,
                price: demoPrice,
                remainingTime: remainingTime,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mapPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_rounded, size: 48, color: Colors.grey.shade500),
            const SizedBox(height: 8),
            Text(
              "Seguimiento en vivo",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Ubicación en tiempo real",
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gradientOverlay(double panelHeight, double panelPadding) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: panelHeight + panelPadding,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(0, 255, 255, 255),
              Color.fromARGB(180, 255, 255, 255),
              Colors.white,
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _bottomPanel({
    required double panelHeight,
    required double panelPadding,
    required ColorScheme colorScheme,
    required String placeName,
    required String distance,
    required String time,
    required String price,
    required int remainingTime,
  }) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.all(panelPadding),
        child: Container(
          height: panelHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _panelTopRow(
                placeName: placeName, 
                colorScheme: colorScheme,
                remainingTime: remainingTime,
              ),
              const SizedBox(height: 12),
              _panelInfoAndAction(
                colorScheme: colorScheme,
                distance: distance,
                time: time,
                price: price,
                remainingTime: remainingTime,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _panelTopRow({
    required String placeName,
    required ColorScheme colorScheme,
    required int remainingTime,
  }) {
    Color statusColor;
    String statusMessage;
    IconData statusIcon;

    if (remainingTime <= 0) {
      // Pedido listo para recoger
      statusColor = Colors.green;
      statusMessage = "¡Pedido listo para recoger!";
      statusIcon = Icons.check_circle_rounded;
    } else if (remainingTime <= 4) {
      // Falta poco tiempo (1-4 min)
      statusColor = Colors.orange;
      statusMessage = "Listo en ~$remainingTime min";
      statusIcon = Icons.timer_rounded;
    } else {
      // Falta más tiempo (5+ min)
      statusColor = colorScheme.primary;
      statusMessage = "En preparación • $remainingTime min restantes";
      statusIcon = Icons.local_printshop_rounded;
    }

    return Column(
      children: [
        Text(
          placeName,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: colorScheme.inverseSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(statusIcon, size: 14, color: statusColor),
              const SizedBox(width: 6),
              Text(
                statusMessage,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _panelInfoAndAction({
    required ColorScheme colorScheme,
    required String distance,
    required String time,
    required String price,
    required int remainingTime,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Información
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoItem(
                icon: Icons.location_on_rounded,
                text: "$distance de distancia",
                color: colorScheme.inverseSurface,
              ),
              const SizedBox(height: 6),
              _infoItem(
                icon: Icons.access_time_rounded,
                text: "$time estimado",
                color: colorScheme.inverseSurface.withOpacity(0.7),
              ),
              const SizedBox(height: 6),
              _infoItem(
                icon: Icons.attach_money_rounded,
                text: "Total: \$$price",
                color: colorScheme.primary,
                isBold: true,
              ),
              // if (remainingTime <= 0) ...[
              //   const SizedBox(height: 8),
              //   _qrCodeButton(),
              // ],
            ],
          ),
        ),

        const SizedBox(width: 12),

        // Botón de cancelar (siempre visible)
        _cancelButton(),
      ],
    );
  }

  Widget _infoItem({
    required IconData icon,
    required String text,
    required Color color,
    bool isBold = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _qrCodeButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.qr_code_rounded, size: 12, color: Colors.green),
          const SizedBox(width: 5),
          Text(
            "Mostrar código",
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cancelButton() {
    return SizedBox(
      width: 125,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.close_rounded, size: 18),
            SizedBox(width: 6),
            Text(
              "Cancelar",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}