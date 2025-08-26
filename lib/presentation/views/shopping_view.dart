
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:printfast_rebuild/config/routes/routes.dart';
import 'package:printfast_rebuild/presentation/blocs/shopping_bloc/shopping_bloc.dart';
import 'package:printfast_rebuild/presentation/widgets/widgets.dart';

/// MyShoppingView
/// Solo DISEÑO: StatelessWidget, sin lógica ni parámetros.
/// Muestra la UI de impresión: subir archivo, color, formato, previsual y total.
class MyShoppingView extends StatelessWidget {
  const MyShoppingView({super.key});

  // ---------- Datos demo (hardcoded, UI-only) ----------
  // Cambia estos valores para ver distintos estados en la vista previa.

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: primary,
      appBar: _myAppBar(context),
      body: _myBody(width, context),
    );
  }

  MyAppBarWidget _myAppBar(BuildContext context) {
    return MyAppBarWidget(
      title: "Comprar",
      leadingIcon: Icons.shopping_cart,
      leadingIconSize: 25,
      actionIcon: Icons.close_sharp,
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
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    _titleRow(context),

                    SizedBox(height: 10),
                    // Upload / file box
                    _uploadBlock(context),

                    SizedBox(height: 20),

                    // Formato (Carta / Oficio)
                    _formatSelector(context),

                    SizedBox(height: 16),

                    // Previsualización PDF
                    _previewBlock(context, width),

                    // Precio por página y páginas detectadas
                    _pagesAndPriceRow(context),
                  ],
                ),

                // Total + localizar
                _totalAndLocateRow(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Encabezado ----------
  Widget _titleRow(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.83,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "Impresión",
            style: TextStyle(
              color: Theme.of(context).colorScheme.inverseSurface,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.insert_drive_file_rounded, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _uploadBlock(BuildContext context) {
    final shoppingBloc = context.read<ShoppingBloc>();

    return BlocBuilder<ShoppingBloc, ShoppingState>(
      builder: (context, state) {
        return AnimatedSize(
          alignment: Alignment.topCenter,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: ClipRect(
            // evita cualquier overflow visual
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              reverseDuration: const Duration(milliseconds: 200),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
                // IMPORTANT: hacemos que SOLO el currentChild afecte el tamaño del layout.
                // Luego superponemos previousChildren con Positioned.fill para permitir su animación
                // sin que cambien la medida.
                return Stack(
                  alignment: Alignment.topCenter,
                  children: <Widget>[
                    if (currentChild != null) currentChild,
                    // Colocamos los anteriores encima (o debajo) pero con Positioned.fill
                    // para que no modifiquen el tamaño de la Stack (la Stack toma el tamaño del currentChild).
                    ...previousChildren.map(
                      (child) => Positioned.fill(child: child),
                    ),
                  ],
                );
              },
              transitionBuilder: (child, animation) {
                // Fade + slide hacia arriba (puedes invertir el offset si prefieres)
                final offsetAnim = Tween<Offset>(
                  begin: const Offset(0, 0.05),
                  end: Offset.zero,
                ).animate(animation);

                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(position: offsetAnim, child: child),
                );
              },
              child: state.hasFile
                  ? Container(
                      key: const ValueKey('file_block'),
                      width: MediaQuery.of(context).size.width * 0.83,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.picture_as_pdf,
                                size: 32,
                                color: Colors.redAccent,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.49,
                                    child: Text(
                                      state.fileName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        overflow: TextOverflow.ellipsis,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.inverseSurface,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${state.pages} páginas",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () => shoppingBloc.onRemove(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(12),
                              elevation: 0,
                            ),
                            child: const Icon(Icons.clear, color: Colors.white),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      key: const ValueKey('upload_block'),
                      width: MediaQuery.of(context).size.width * 0.83,
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 18,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.cloud_upload_outlined, size: 28),
                              const SizedBox(width: 12),
                              Text(
                                "Subir archivo PDF",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.inverseSurface,
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () =>
                                !state.isLoading ? shoppingBloc.onPick() : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: !state.isLoading
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(
                                      context,
                                    ).colorScheme.primary.withOpacity(0.4),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Icon(
                                Icons.drive_folder_upload_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _formatSelector(BuildContext context) {
    final inverse = Theme.of(context).colorScheme.inverseSurface;
    final shoppingBloc = context.read<ShoppingBloc>();

    return BlocBuilder<ShoppingBloc, ShoppingState>(
      builder: (context, state) {
        return Column(
          children: [
            // Color checkbox con Checkbox real
            Container(
              width: MediaQuery.of(context).size.width * 0.83,
              padding: const EdgeInsets.only(
                right: 12,
                left: 3,
                top: 1,
                bottom: 1,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Transform.scale(
                    scale: 1.2,
                    child: Checkbox(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      value: state.isColor,
                      activeColor: Theme.of(context).colorScheme.primary,
                      side: BorderSide(
                        // 👈 borde personalizado
                        color: state.isColor
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade400,
                        width: 1,
                      ),
                      onChanged: (value) => context.read<ShoppingBloc>().add(
                        ShoppingChangeIsColorEvent(isColor: value ?? false),
                      ),
                    ),
                  ),
                  SizedBox(width: 1),
                  Text(
                    "A color",
                    style: TextStyle(
                      color: inverse,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "Precio: ${shoppingBloc.priceColor} \$/pg",
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Formato toggles
            Container(
              width: MediaQuery.of(context).size.width * 0.83,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _formatChip(
                    context,
                    label: "Carta",
                    selected: state.isFormatCarta,
                    onTap: () => shoppingBloc.add(
                      ShoppingChangeIsFormatCartaEvent(isFormatCarta: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _formatChip(
                    context,
                    label: "Oficio",
                    selected: !state.isFormatCarta,
                    onTap: () => shoppingBloc.add(
                      ShoppingChangeIsFormatCartaEvent(isFormatCarta: false),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _formatChip(
    BuildContext context, {
    required String label,
    required bool selected,
    VoidCallback? onTap,
  }) {
    final primary = Theme.of(context).colorScheme.primary;
    final inverse = Theme.of(context).colorScheme.inverseSurface;

    return Material(
      borderRadius: BorderRadius.circular(25),
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        splashColor: primary.withOpacity(0.3),
        highlightColor: primary.withOpacity(0.15),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 125),
          curve: Curves.decelerate,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? primary : Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: selected ? Colors.transparent : Colors.grey.shade300,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : inverse,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Previsual (placeholder) ----------
  Widget _previewBlock(BuildContext context, double width) {
    return BlocBuilder<ShoppingBloc, ShoppingState>(
      builder: (context, state) {
        return Container(
          width: width * 0.83,
          height: width * 0.6,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: state.hasFile
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Representación visual simple del PDF
                      const Icon(
                        Icons.picture_as_pdf,
                        size: 56,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text(
                            textAlign: TextAlign.center,
                            state.fileName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Páginas: ${state.pages}",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 12),

                      // Botón simple con emoji de "view"
                      SizedBox(
                        width: 150,
                        child: ElevatedButton(
                          onPressed: () {
                            context.push(Routes.pdfView);
                          }, // conectar con preview modal más tarde
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Visualizar',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.visibility),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : state.isLoading ?  MyLoadingIndicator() : Icon(
                      Icons.hide_source,
                      size: 80,
                      color: Colors.grey.shade300,
                    ),
          ),
        );
      },
    );
  }

  // ---------- Páginas y precio por página (UI) ----------
  Widget _pagesAndPriceRow(BuildContext context) {
    final shoppingBloc = context.read<ShoppingBloc>();
    return BlocBuilder<ShoppingBloc, ShoppingState>(
      builder: (context, state) {
        return Column(
          children: [
            SizedBox(height: 12.5),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.83,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Páginas Formato ${state.isFormatCarta ? "Carta" : "Oficio"}:",
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "\$ ${state.isFormatCarta ? shoppingBloc.priceCartaPerPage.toStringAsFixed(2) : shoppingBloc.priceOficioPerPage.toStringAsFixed(2)} / pág ",
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ---------- Total y botón localizar ----------
  Widget _totalAndLocateRow(BuildContext context) {
    return BlocBuilder<ShoppingBloc, ShoppingState>(
      builder: (context, state) {
        final enabled = state.totalPrice > 0;
        return SizedBox(
          width: MediaQuery.of(context).size.width * 0.83,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total: ${enabled ? state.totalPrice.toStringAsFixed(2) : '0.00'} \$",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inverseSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              enabled
                  ? _locateButton(context, enabled: true)
                  : _locateButton(context, enabled: false),
            ],
          ),
        );
      },
    );
  }

  Widget _locateButton(BuildContext context, {required bool enabled}) {
    return ElevatedButton(
      onPressed: enabled ? () => context.push(Routes.locationPicker) : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: enabled
            ? Colors.greenAccent.shade400
            : Colors.greenAccent.shade100,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        "Localizar",
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}


