import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf_render_plus/pdf_render_widgets.dart';
import 'package:printfast_rebuild/presentation/blocs/shopping_bloc/shopping_bloc.dart';
import 'package:printfast_rebuild/presentation/widgets/widgets.dart';

class MyPdfView extends StatefulWidget {
  const MyPdfView({super.key});

  @override
  State<MyPdfView> createState() => _MyPdfViewState();
}

class _MyPdfViewState extends State<MyPdfView> {

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Esperamos a que la animación de la transición termine
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Simulamos un pequeño delay para asegurar que la animación terminó
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: primary,
      appBar: _myAppBar(context),
      body: _myBody(width, context),
    );
  }

  MyAppBarWidget _myAppBar(BuildContext context) {
    return MyAppBarWidget(
      title: "Visualizar PDF",
      leadingIcon: Icons.picture_as_pdf,
      leadingIconSize: 25,
      actionIcon: Icons.close_sharp,
      actionIconSize: 25,
      onAction: () => context.canPop() ? context.pop() : null,
    );
  }

  Widget _myBody(double width, BuildContext context) {
    final String fileName = "documento_demo.pdf";
    final int pages = 0;
    return BlocBuilder<ShoppingBloc, ShoppingState>(
      builder: (context, state) {
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
                child: state.bytes == null
                    ? myMessageWithNoPdf(fileName, pages)
                    : _isLoading ?
                     Container(
                      alignment: Alignment.center,
                       child: MyLoadingIndicator()
                     ) 
                  :  myPDFView(state.bytes!)
            ),
          ),
        ));
      },
    );
  }

    Widget myPDFView(Uint8List byte) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: PdfViewer.openData(byte, // Uint8List
            params: PdfViewerParams(padding: 0, alignPanAxis: true, ),
      ),
    );
  }


  // Widget myPDFView(Uint8List byte) {
  Column myMessageWithNoPdf(String fileName, int pages) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Representación visual simple del PDF
        const Icon(Icons.picture_as_pdf, size: 56, color: Colors.redAccent),
        const SizedBox(height: 8),
        Text(fileName, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text("Páginas: $pages", style: TextStyle(color: Colors.grey.shade600)),
      ],
    );
  }
}

