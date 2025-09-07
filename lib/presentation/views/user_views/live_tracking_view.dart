
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:printfast_rebuild/presentation/widgets/widgets.dart';

class MyLiveTrackingView extends StatelessWidget {
  const MyLiveTrackingView({super.key});

  @override
  Widget build(BuildContext context) {

    final primary = Theme.of(context).colorScheme.primary;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: primary,
      appBar: _myAppBar(context),
      body: _myBody(width, height, context),
    );
  }

  MyAppBarWidget _myAppBar(BuildContext context) {
    return MyAppBarWidget(
      title: "Seguimiento",
      leadingIcon: Icons.directions,
      leadingIconSize: 25,
      actionIcon: Icons.close_sharp,
      actionIconSize: 25,
      onAction: () => context.canPop() ? context.pop() : null,
    );
  }
  Widget _myBody(double width, double height, BuildContext context) {
    // demo (hardcoded para diseño)
    const demoPlaceName = "Sucursal Central";
    const demoDistance = "Distancia: 750 m";
    const demoTime = "Tiempo: 12 min";
    const demoQueue = "Fila: 3 órdenes";
    final inverse = Theme.of(context).colorScheme.inverseSurface;

    final panelHeight = height * 0.245;
    final panelPadding = 10.0;

    return Center(
      child: Padding(
        padding: EdgeInsets.only(bottom: width * 0.025),
        child: Container(
          width: width * 0.95,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // MAP placeholder (usa GoogleMap aquí en tu implementación final)
              _mapPlaceholder(),

              // Overlay degradado que suaviza la transición hacia el panel inferior
              _gradientOverlay(panelHeight, panelPadding),

              // Panel inferior con flechas, info y botón
              _bottomPanel(
                panelHeight: panelHeight,
                panelPadding: panelPadding,
                primary: Theme.of(context).colorScheme.primary,
                inverse: inverse,
                placeName: demoPlaceName,
                distance: demoDistance,
                time: demoTime,
                queue: demoQueue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------
  // MÉTODOS PRIVADOS (UI PARTS)
  // ---------------------------

  /// Placeholder del mapa (sustituir por GoogleMap)
  Widget _mapPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
    );
  }

  /// Gradiente en la parte inferior para suavizar la transición
  Align _gradientOverlay(double panelHeight, double panelPadding) {
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
              Color.fromARGB(190, 255, 255, 255),
              Colors.white,
            ],
            stops: [0.0, 0.75, 1.0],
          ),
        ),
      ),
    );
  }

  /// Panel inferior con flechas, info y botón aceptar
  Align _bottomPanel({
    required double panelHeight,
    required double panelPadding,
    required Color primary,
    required Color inverse,
    required String placeName,
    required String distance,
    required String time,
    required String queue,
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
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _panelTopRow(placeName: placeName, primary: primary, inverse: inverse),
              _panelInfoAndAction(
                distance: distance,
                time: time,
                queue: queue,
                inverse: inverse,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Fila superior: flechas y título del lugar
  Widget _panelTopRow({
    required String placeName,
    required Color primary,
    required Color inverse,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 7),
        child: Text(
          placeName,
          style: TextStyle(
            color: inverse,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }



  /// Columna de información + botón aceptar (lado derecho)
  Widget _panelInfoAndAction({
    required String distance,
    required String time,
    required String queue,
    required Color inverse,
  }) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Info (distancia / tiempo / fila / precio)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  distance,
                  style: TextStyle(
                    color: inverse,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                _infoRow(icon: Icons.price_change, text: "Precio: 15.0 \$"),
                _infoRow(icon: Icons.access_time_rounded, text: time),
                _infoRow(icon: Icons.person_outline, text: queue),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Botón aceptar
          _acceptButton(),
        ],
      ),
    );
  }

  /// Fila pequeña con icono + texto (usa estilo gris pequeño)
  Widget _infoRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade500),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
      ],
    );
  }

  /// Botón Aceptar/Comprar (estándar)
  Widget _acceptButton() {
    return SizedBox(
      width: 140,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 19),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.close, size: 19),
            SizedBox(width: 8),
            Text("Cancelar", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
