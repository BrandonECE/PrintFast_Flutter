import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:printfast_rebuild/config/routes/routes.dart';
import 'package:printfast_rebuild/presentation/blocs/user_blocs/shopping_blocs/shopping_bloc/shopping_bloc.dart';
import 'package:printfast_rebuild/presentation/widgets/widgets.dart';

class MyShoppingView extends StatelessWidget {
  const MyShoppingView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      appBar: MyAppBarWidget(
        title: "Comprar",
        leadingIcon: Icons.shopping_cart_rounded,
        leadingIconSize: 25,
        actionIcon: Icons.close_rounded,
        actionIconSize: 25,
        onAction: () => context.canPop() ? context.pop() : null,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.only(bottom: width * 0.025),
          child: Container(
            width: width * 0.95,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  _titleRow(context),
                  const SizedBox(height: 16),
                  _uploadBlock(context),
                  const SizedBox(height: 18),
                  _formatSelector(context),
                  const SizedBox(height: 23),
                  _previewBlock(context, width),
                  const SizedBox(height: 16),
                  _pagesAndPriceRow(context),
                  const Spacer(),
                  _totalAndLocateRow(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Encabezado ----------
  Widget _titleRow(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.83,
      child: Row(
        children: [
          Text(
            "Impresión",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: colorScheme.inverseSurface,
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.insert_drive_file_rounded, 
               size: 22,
               color: colorScheme.inverseSurface.withOpacity(0.7)),
        ],
      ),
    );
  }

  Widget _uploadBlock(BuildContext context) {
    final shoppingBloc = context.read<ShoppingBloc>();

    return BlocBuilder<ShoppingBloc, ShoppingState>(
      builder: (context, state) {
        return AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: state.hasFile
                ? _fileBlock(context, state, shoppingBloc)
                : _uploadPlaceholder(context, state, shoppingBloc),
          ),
        );
      },
    );
  }

  Widget _fileBlock(BuildContext context, ShoppingState state, ShoppingBloc shoppingBloc) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      key: const ValueKey('file_block'),
      width: MediaQuery.of(context).size.width * 0.83,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.picture_as_pdf_rounded, size: 28, color: Colors.redAccent),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.35,
                    child: Text(
                      state.fileName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.inverseSurface,
                        fontSize: 13,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "${state.pages} páginas • PDF",
                    style: TextStyle(
                      color: colorScheme.inverseSurface.withOpacity(0.6),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            onPressed: () =>  state.shoppingStatus == ShoppingStatus.loading || state.shoppingStatus == ShoppingStatus.inProgress ? (){} :  shoppingBloc.onRemove(),
            icon: Icon(Icons.close_rounded, color: Colors.red, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.1),
              padding: const EdgeInsets.all(6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _uploadPlaceholder(BuildContext context, ShoppingState state, ShoppingBloc shoppingBloc) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      key: const ValueKey('upload_block'),
      width: MediaQuery.of(context).size.width * 0.83,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.cloud_upload_rounded, size: 22, color: colorScheme.inverseSurface.withOpacity(0.7)),
              const SizedBox(width: 12),
              Text(
                "Subir archivo PDF",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.inverseSurface,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: !state.isLoading ? () => shoppingBloc.onPick() : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Icon(Icons.drive_folder_upload_rounded, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _formatSelector(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final shoppingBloc = context.read<ShoppingBloc>();

    return BlocBuilder<ShoppingBloc, ShoppingState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título de configuración
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 10),
              child: Text(
                "Configuración de impresión",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.inverseSurface.withOpacity(0.8),
                  fontSize: 13,
                ),
              ),
            ),

            // Checkbox de color
            Container(
              width: MediaQuery.of(context).size.width * 0.83,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: state.isColor,
                    activeColor: colorScheme.primary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onChanged: (value) => shoppingBloc.add(
                      ShoppingChangeIsColorEvent(isColor: value ?? false),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Impresión a color",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.inverseSurface,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "${shoppingBloc.priceColor} \$/pg",
                    style: TextStyle(
                      color: colorScheme.inverseSurface.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // Selector de formato
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.83,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _formatChip(
                    context,
                    label: "Carta",
                    selected: state.isFormatCarta,
                    onTap: () => shoppingBloc.add(
                      ShoppingChangeIsFormatCartaEvent(isFormatCarta: true),
                    ),
                  ),
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

  Widget _formatChip(BuildContext context, {required String label, required bool selected, VoidCallback? onTap}) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Material(
      borderRadius: BorderRadius.circular(16),
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? Colors.transparent : Colors.grey.shade400,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: selected ? Colors.white : colorScheme.inverseSurface,
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Previsualización ----------
  Widget _previewBlock(BuildContext context, double width) {
    return BlocBuilder<ShoppingBloc, ShoppingState>(
      builder: (context, state) {
        final colorScheme = Theme.of(context).colorScheme;
        
        return Container(
          width: width * 0.83,
          height: width * 0.52,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: state.hasFile
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.picture_as_pdf_rounded, size: 42, color: Colors.redAccent),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        state.fileName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.inverseSurface,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${state.pages} páginas • Listo para imprimir",
                      style: TextStyle(
                        color: colorScheme.inverseSurface.withOpacity(0.6),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton(
                      onPressed: () => context.push(Routes.shoppingPdfView),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text(
                        "Visualizar PDF",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                )
              : Center(
                  child: state.isLoading
                      ? MyLoadingIndicator()
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.insert_drive_file_rounded, size: 38, color: Colors.grey.shade300),
                            const SizedBox(height: 10),
                            Text(
                              "Sube un archivo para previsualizar",
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                ),
        );
      },
    );
  }

  // ---------- Precio por página ----------
  Widget _pagesAndPriceRow(BuildContext context) {
    final shoppingBloc = context.read<ShoppingBloc>();
    final colorScheme = Theme.of(context).colorScheme;
    
    return BlocBuilder<ShoppingBloc, ShoppingState>(
      builder: (context, state) {
        return Container(
          width: MediaQuery.of(context).size.width * 0.83,
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Precio por página:",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.inverseSurface,
                  fontSize: 13,
                ),
              ),
              Text(
                "\$${state.isFormatCarta ? shoppingBloc.priceCartaPerPage.toStringAsFixed(2) : shoppingBloc.priceOficioPerPage.toStringAsFixed(2)}",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------- Total y botón ----------
  Widget _totalAndLocateRow(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return BlocBuilder<ShoppingBloc, ShoppingState>(
      builder: (context, state) {
        final enabled = state.totalPrice > 0;
        
        return Container(
          width: MediaQuery.of(context).size.width * 0.83,
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total estimado:",
                    style: TextStyle(
                      color: colorScheme.inverseSurface.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    "\$${state.totalPrice.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.inverseSurface,
                    ),
                  ),
                ],
              ),
             SizedBox(
              width: 140, // Un poquito más de ancho (de 135 a 140)
              child: ElevatedButton(
                onPressed: state.shoppingStatus == ShoppingStatus.loading || state.shoppingStatus == ShoppingStatus.inProgress ? (){} : enabled ? () => context.push(Routes.locationPicker) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: enabled ? colorScheme.primary : Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14), // Ajustado
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_forward_rounded, size: 17), // Un poquito más pequeño
                    SizedBox(width: 5), // Menos espacio
                    Text(
                      "Continuar",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600), // Texto más pequeño
                    ),
                  ],
                ),
              ),
            ),
            ],
          ),
        );
      },
    );
  }
}