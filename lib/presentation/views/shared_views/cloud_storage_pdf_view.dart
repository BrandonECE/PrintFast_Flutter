import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf_render_plus/pdf_render_widgets.dart';
import 'package:printfast_rebuild/presentation/blocs/shared_blocs/cloud_storage_pdf_bloc.dart/cloud_storage_pdf_bloc.dart';
import 'package:printfast_rebuild/presentation/widgets/widgets.dart';

class MyCloudStoragePdfView extends StatelessWidget {
  const MyCloudStoragePdfView({super.key});

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
    return BlocBuilder<CloudStoragePdfBloc, CloudStoragePdfState>(
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
                child:
                    state.cloudStoragePdfViewStatus ==
                        CloudStoragePdfViewStatus.loading
                    ? _myLoadingIndicator()
                    : state.cloudStoragePdfViewStatus ==
                          CloudStoragePdfViewStatus.failure
                    ? myMessageError(context)
                    : state.fileFromCloudStorage == null
                    ? myMessageWithNoPdf()
                    : myPDFView(state.fileFromCloudStorage!),
              ),
            ),
          ),
        );
      },
    );
  }

  Container _myLoadingIndicator() {
    return Container(alignment: Alignment.center, child: MyLoadingIndicator());
  }

  Widget myPDFView(Uint8List byte) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: PdfViewer.openData(
        byte, // Uint8List
        params: PdfViewerParams(padding: 0, alignPanAxis: true),
      ),
    );
  }

  // Widget myPDFView(Uint8List byte) {
  Column myMessageWithNoPdf() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.picture_as_pdf, size: 56, color: Colors.redAccent),
        const SizedBox(height: 12),
        const Text(
          "Archivo no disponible",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 6),
        Text(
          "No se encontró el PDF.",
          style: TextStyle(color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Column myMessageError(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.picture_as_pdf, size: 56, color: Colors.redAccent),

        const SizedBox(height: 12),
        const Text(
          "Ups... algo salió mal",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Text(
            "No pudimos cargar el PDF ahora mismo. Puedes intentar de nuevo o revisar tu conexión.",
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
