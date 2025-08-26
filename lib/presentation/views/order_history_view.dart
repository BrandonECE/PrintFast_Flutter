import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:printfast_rebuild/presentation/widgets/appbar_widget.dart';

/// MyHistoryOrderPureDesign
/// Solo DISEÑO: StatelessWidget, sin parámetros, sin lógica.
/// Variables internas con ejemplo de orderHistoryInfo y productos.
/// Métodos privados para construir cada bloque (igual estructura del original).
class MyOrderHistoryView extends StatelessWidget {
  const MyOrderHistoryView({super.key});

  // ---------- Datos de ejemplo (internos) ----------
  final String _dateInit = "12/08/2025";
  final String _timeInit = "10:30";
  final String _dateFinal = "12/08/2025";
  final String _timeFinal = "11:05";
  final String _totalPrice = "75.00";

  // Mapa de productos como en tu original: clave -> cantidad (string)
  // Para probar la sección "Impresiones" la dejamos primero con valor != 0
  final Map<String, String> _productosMap = const {
    "Impresiones": "2",
    "Cartulinas": "3",
    "Folletos": "0",
    "Plastificado": "1",
  };

  // ---------- Build principal ----------
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final inverse = Theme.of(context).colorScheme.inverseSurface;
    final primary = Theme.of(context).colorScheme.primary;

    // Construimos la lista de Widgets de productos respetando el orden original:
    // Impresiones (si existe >0) al inicio, luego el resto en orden.
    final List<Widget> productosWidgets = [];
    _productosMap.forEach((key, value) {
      final int qty = int.tryParse(value) ?? 0;
      if (qty == 0) return;
      if (key == "Impresiones") {
        productosWidgets.insert(0, _itemProductImpresion(context, product: key, howMany: value));
      } else {
        productosWidgets.add(_itemProductNormal(context, product: key, howMany: value));
      }
    });

    return Scaffold(
      backgroundColor: primary,
      appBar: _myAppBar(context),
      body: _myBody(width, context, productosWidgets, inverse));
  }

    MyAppBarWidget _myAppBar(BuildContext context) {
    return MyAppBarWidget(title: "Historial", leadingIcon: Icons.history, leadingIconSize: 25, actionIcon: Icons.close_sharp, actionIconSize: 25, onAction: () => context.canPop() ? context.pop() : null,);
  }

  Center _myBody(double width, BuildContext context, List<Widget> productosWidgets, Color inverse) {
    return Center(
    child: Padding(
      padding: EdgeInsets.only(bottom: width * 0.025),
      child: Column(
        children: [
          // Top card: Fechas ordenado / finalizado
          Container(
            padding: const EdgeInsets.all(20),
            width: width * 0.95,
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(20))),
            child: Column(
              children: [
                _buildSectionLabel(context, "ORDENADO"),
                const SizedBox(height: 8),
                _buildDateRow(context, Icons.calendar_month, _dateInit, Icons.access_time_outlined, _timeInit),
                const SizedBox(height: 12),
                _buildSectionLabel(context, "FINALIZADO"),
                const SizedBox(height: 8),
                _buildDateRow(context, Icons.calendar_month, _dateFinal, Icons.access_time_outlined, _timeFinal),
              ],
            ),
          ),
      
          SizedBox(height: width * 0.03),
      
          // Bottom expanded area: productos + total
          Expanded(
            child: Container(
              width: width * 0.95,
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(20))),
              child: Column(
                children: [
                  // Título Productos
                  _titlesContainer(context, "PRODUCTOS"),
      
                  // Contenedor gris con lista de productos
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: const BorderRadius.all(Radius.circular(20))),
                      width: width * 0.83,
                      child: productosWidgets.isEmpty
                          ? Center(child: Icon(Icons.hide_source, size: 80, color: Colors.grey.shade400))
                          : ListView.separated(
                              itemCount: productosWidgets.length,
                              separatorBuilder: (c, i) => const SizedBox(height: 12),
                              itemBuilder: (c, i) => productosWidgets[i],
                            ),
                    ),
                  ),
      
                  // Total
                  Container(
                    width: width * 0.78,
                    margin: const EdgeInsets.only(bottom: 30, top: 10),
                    child: Text(
                      "Total: $_totalPrice \$",
                      style: TextStyle(color: inverse, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
  }

  // ---------- Métodos privados de UI ----------

  Widget _buildSectionLabel(BuildContext context, String title) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Text(
            title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.inverseSurface),
          ),
        ),
        const SizedBox(width: 6),
        const Icon(Icons.arrow_drop_down, size: 25),
      ],
    );
  }

  Widget _buildDateRow(BuildContext context, IconData iconLeft, String textLeft, IconData iconRight, String textRight) {
    final inverse = Theme.of(context).colorScheme.inverseSurface;
    return Row(
      children: [
        Row(
          children: [
            Icon(iconLeft),
            const SizedBox(width: 8),
            Text(textLeft, style: TextStyle(color: inverse, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(width: 16),
        Row(
          children: [
            Icon(iconRight),
            const SizedBox(width: 8),
            Text(textRight, style: TextStyle(color: inverse, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _titlesContainer(BuildContext context, String title) {
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 10),
      width: MediaQuery.of(context).size.width * 0.83,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.inverseSurface)),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_drop_down, size: 25),
        ],
      ),
    );
  }

  // Item especial para "Impresiones" (estilo distinto si quieres)
  Widget _itemProductImpresion(BuildContext context, {required String product, required String howMany}) {
    final inverse = Theme.of(context).colorScheme.inverseSurface;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade400)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icon + nombre
          Row(
            children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.insert_drive_file, size: 20)),
              const SizedBox(width: 10),
              Text(product, style: TextStyle(fontWeight: FontWeight.bold, color: inverse)),
            ],
          ),
          // cantidad a la derecha
          Text(howMany, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  // Item normal (otros productos)
  Widget _itemProductNormal(BuildContext context, {required String product, required String howMany}) {
    final inverse = Theme.of(context).colorScheme.inverseSurface;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade400)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // nombre con icono pequeño
          Row(
            children: [
              const Icon(Icons.shopping_bag_outlined, size: 18),
              const SizedBox(width: 10),
              Text(product, style: TextStyle(fontWeight: FontWeight.bold, color: inverse)),
            ],
          ),

          // cantidad
          Text(howMany, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
        ],
      ),
    );
  }
}
