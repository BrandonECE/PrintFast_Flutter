import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:printfast_rebuild/config/routes/routes.dart';
import 'package:printfast_rebuild/presentation/widgets/widgets.dart';

class MyLocationPickerView extends StatelessWidget {
  const MyLocationPickerView({super.key});

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
      title: "Ubicación",
      leadingIcon: Icons.location_on_rounded,
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
    const demoQueue = "3 órdenes";
    const demoPrice = "15.00";

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
              
              // Badge recomendada
              _recommendedBadge(colorScheme, panelHeight, panelPadding),

              // Overlay degradado
              _gradientOverlay(panelHeight, panelPadding),

              // Panel inferior
              _bottomPanel(
                context: context,
                panelHeight: panelHeight,
                panelPadding: panelPadding,
                colorScheme: colorScheme,
                placeName: demoPlaceName,
                distance: demoDistance,
                time: demoTime,
                queue: demoQueue,
                price: demoPrice,
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
              "Mapa interactivo",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
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

  Widget _recommendedBadge(ColorScheme colorScheme, double panelHeight, double panelPadding) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(bottom: panelHeight + panelPadding + 16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star_rounded, color: Colors.amber, size: 18),
              const SizedBox(width: 6),
              Text(
                "Recomendada",
                style: TextStyle(
                  color: colorScheme.inverseSurface,
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

  Widget _bottomPanel({
    required BuildContext context,
    required double panelHeight,
    required double panelPadding,
    required ColorScheme colorScheme,
    required String placeName,
    required String distance,
    required String time,
    required String queue,
    required String price,
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
              _panelTopRow(placeName: placeName, colorScheme: colorScheme),
              const SizedBox(height: 12),
              _panelInfoAndAction(
                context: context, 
                colorScheme: colorScheme,
                distance: distance,
                time: time,
                queue: queue,
                price: price,
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
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _circleArrowButton(
          icon: Icons.arrow_back_ios_rounded,
          color: colorScheme.primary,
          onPressed: () {},
        ),
        Expanded(
          child: Center(
            child: Text(
              placeName,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: colorScheme.inverseSurface,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        _circleArrowButton(
          icon: Icons.arrow_forward_ios_rounded,
          color: colorScheme.primary,
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _circleArrowButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: color, size: 22),
      style: IconButton.styleFrom(
        backgroundColor: Colors.white,
        padding: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withOpacity(0.2), width: 1),
        ),
      ),
    );
  }

  Widget _panelInfoAndAction({
    required BuildContext context,
    required ColorScheme colorScheme,
    required String distance,
    required String time,
    required String queue,
    required String price,
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
                icon: Icons.people_rounded,
                text: "$queue en fila",
                color: colorScheme.inverseSurface.withOpacity(0.7),
              ),
              const SizedBox(height: 6),
              _infoItem(
                icon: Icons.attach_money_rounded,
                text: "Precio: \$$price",
                color: colorScheme.primary,
                isBold: true,
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        // Botón aceptar
        _acceptButton(context, colorScheme),
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

Widget _acceptButton(BuildContext context, ColorScheme colorScheme) {
  return SizedBox(
    width: 140,
    child: ElevatedButton(
      onPressed: () => context.push(Routes.payMethodView),
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary, // Usar el color primario en vez de verde
        foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14), //
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.arrow_forward_rounded, size: 17), // Icono de flecha hacia adelante
          SizedBox(width: 5),
          Text(
            "Continuar", // Indica que hay más pasos
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    ),
  );
}
}

