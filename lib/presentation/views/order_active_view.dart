import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:printfast_rebuild/config/routes/routes.dart';
import 'package:printfast_rebuild/presentation/widgets/widgets.dart';

/// MyOrderActiveInfoPureDesign
/// Solo DISEÑO: StatelessWidget, sin parámetros ni lógica.
/// Variables internas con datos de ejemplo y métodos privados para construir la UI.
class MyActiveOrderView extends StatelessWidget {
  const MyActiveOrderView({super.key});

  // ---------- Datos de ejemplo (internos) ----------
  final String _initDate = "12/08/2025";
  final String _initTime = "10:30";
  final String _finalDate = "12/08/2025";
  final String _finalTime = "11:05";
  final String _totalPrice = "75.00";

  // Mapa de productos: clave -> cantidad (string)
  // "Impresiones" se mostrará primero si tiene valor > 0 (como en tu original)
  final Map<String, String> _productosMap = const {
    "Impresiones": "2",
    "Cartulinas": "3",
    "Folletos": "0",
    "Plastificado": "1",
  };

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final primary = Theme.of(context).colorScheme.primary;

    // Construir lista de widgets de productos (UI-only)
    final List<Widget> productosWidgets = [];
    _productosMap.forEach((key, value) {
      final int qty = int.tryParse(value) ?? 0;
      if (qty == 0) return;
      if (key == "Impresiones") {
        productosWidgets.insert(
          0,
          _itemProductImpresion(context, product: key, howMany: value),
        );
      }
    });

    return Scaffold(
      backgroundColor: primary,
      appBar: _myAppBar(context),
      body: _myBody(width, context, productosWidgets));
  }

  MyAppBarWidget _myAppBar(BuildContext context) {
    return MyAppBarWidget(title: "Orden Activa", leadingIcon: Icons.shopping_basket_rounded, leadingIconSize: 25, actionIcon: Icons.close_sharp, actionIconSize: 25, onAction: () => context.canPop() ? context.pop() : null,);
  }

  Center _myBody(double width, BuildContext context, List<Widget> productosWidgets) {
    return Center(
    child: Padding(
      padding: EdgeInsets.only(bottom: width * 0.025),
      child: Column(
        children: [
          // Top card: Fechas (Ordenado / Finalizado)
          Container(
            padding: const EdgeInsets.all(20),
            width: width * 0.95,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Column(
              children: [
                _sectionLabel(context, "ORDENADO"),
                const SizedBox(height: 8),
                _dateTimeRow(
                  context,
                  Icons.calendar_month,
                  _initDate,
                  Icons.access_time_outlined,
                  _initTime,
                ),
                const SizedBox(height: 12),
                _sectionLabel(context, "FINALIZADO"),
                const SizedBox(height: 8),
                _dateTimeRow(
                  context,
                  Icons.calendar_month,
                  _finalDate,
                  Icons.access_time_outlined,
                  _finalTime,
                ),
              ],
            ),
          ),
      
          SizedBox(height: width * 0.03),
      
          // Bottom panel: productos list + actions + total
          Expanded(
            child: Container(
              width: width * 0.95,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Column(
                children: [
                  _titlesContainer(context, "PRODUCTOS"),
      
                  // Productos container (gris) con lista
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(20),
                        ),
                      ),
                      width: width * 0.83,
                      child: productosWidgets.isEmpty
                          ? Center(
                              child: Icon(
                                Icons.hide_source,
                                size: 80,
                                color: Colors.grey.shade400,
                              ),
                            )
                          : ListView.separated(
                              itemCount: productosWidgets.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (_, i) => productosWidgets[i],
                            ),
                    ),
                  ),
      
                  // Botón "Ver dirección" (visual) y Total
                  Container(
                    width: width * 0.8,
                    margin: const EdgeInsets.only(bottom: 12, top: 5),
                    child: ElevatedButton(
                      onPressed: () => context.push(Routes.liveTracking),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Ver seguimiento",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.directions, size: 25,),
                        ],
                      ),
                    ),
                  ),
      
                  Container(
                    alignment: Alignment.centerLeft,
                    width: width * 0.78,
                    margin: const EdgeInsets.only(bottom: 30, top: 6),
                    child: Text(
                      "Total: $_totalPrice \$",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.inverseSurface,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
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

  // ---------- Métodos privados para construir bloques UI ----------

  Widget _sectionLabel(BuildContext context, String title) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.inverseSurface,
            ),
          ),
        ),
        const SizedBox(width: 6),
        const Icon(Icons.arrow_drop_down, size: 25),
      ],
    );
  }

  Widget _dateTimeRow(
    BuildContext context,
    IconData leftIcon,
    String leftText,
    IconData rightIcon,
    String rightText,
  ) {
    final inverse = Theme.of(context).colorScheme.inverseSurface;
    return Row(
      children: [
        Row(
          children: [
            Icon(leftIcon),
            const SizedBox(width: 8),
            Text(
              leftText,
              style: TextStyle(
                color: inverse,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Row(
          children: [
            Icon(rightIcon),
            const SizedBox(width: 8),
            Text(
              rightText,
              style: TextStyle(
                color: inverse,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
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
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.inverseSurface,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_drop_down, size: 25),
        ],
      ),
    );
  }

  Widget _itemProductImpresion(
    BuildContext context, {
    required String product,
    required String howMany,
  }) {
    final inverse = Theme.of(context).colorScheme.inverseSurface;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "PRODUCTO:",
                    style: TextStyle(
                      color: inverse,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product,
                    style: TextStyle(
                      color: inverse,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Row(
              children: [
                Text(
                  "Pg.",
                  style: TextStyle(
                    color: inverse,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  alignment: Alignment.center,
                  height: 40,
                  width: 35,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                  ),
                  child: Text(
                    howMany,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inverseSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
