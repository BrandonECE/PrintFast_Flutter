import 'dart:io';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf_render_plus/pdf_render.dart';

part 'shopping_event.dart';
part 'shopping_state.dart';

class ShoppingBloc extends Bloc<ShoppingEvent, ShoppingState> {
  final double priceCartaPerPage = 2.0;
  final double priceOficioPerPage = 3.0;
  final double priceBlackAndWhite = 1.0;
  final double priceColor = 2.0;

  ShoppingBloc() : super(ShoppingInitial()) {
    on<ShoppingChangeHasFileEvent>((event, emit) {
      emit(state.copyWith(hasFile: event.hasFile));
    });

    on<ShoppingChangeTotalPriceEvent>((event, emit) {
      emit(state.copyWith(totalPrice: event.totalPrice));
    });

    on<ShoppingChangeFileNameEvent>((event, emit) {
      emit(state.copyWith(fileName: event.fileName));
    });

    on<ShoppingChangeNumPagesEvent>((event, emit) {
      emit(state.copyWith(pages: event.pages));
      totalPriceCalculate();
    });

    on<ShoppingChangeIsColorEvent>((event, emit) {
      emit(state.copyWith(isColor: event.isColor));
      totalPriceCalculate();
    });

    on<ShoppingChangeIsFormatCartaEvent>((event, emit) {
      emit(state.copyWith(isFormatCarta: event.isFormatCarta));
      totalPriceCalculate();
    });

    on<ShoppingChangeIsLoadingEvent>((event, emit) {
      emit(state.copyWith(isLoading: event.isLoading));
      totalPriceCalculate();
    });

    on<ShoppingChangeUint8ListBytesEvent>((event, emit) {
      emit(state.copyWith(bytes: event.bytes));
    });
  }

  Future<void> onPick() async {
    // emit(state.copyWith(loading: true, error: null));

    Uint8List? bytes;
    int pages = 0;
    String nameDocumentPdf = "";

    try {
      final res = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true, // intentamos obtener bytes directamente
      );

      if (res == null) {
        onRemove();
        print("CANCELADO");
        return;
      }

      add(ShoppingChangeIsLoadingEvent(isLoading: true));

      final picked = res.files.single;
      nameDocumentPdf = picked.name;

      // validación simple de extensión
      final ext = (picked.extension ?? '').toLowerCase();
      if (ext != 'pdf') {
        print("NO ES UN PDF");
        onRemove();
        return;
      }

      if (picked.bytes != null) {
        bytes = picked.bytes!;
      } else if (picked.path != null) {
        final file = File(picked.path!);
        bytes = await file.readAsBytes();
      } else {
        onRemove();
        print("No se pudo leer el archivo seleccionado.");
        return;
      }

      // obtener número de páginas (intentar, pero no crítico)
      try {
        final doc = await PdfDocument.openData(bytes);
        pages = doc.pageCount;
        await doc.dispose();
      } catch (_) {
        onRemove();
        pages = 0;
      }

      print("TODO SALIO BIEN.");
      add(ShoppingChangeIsLoadingEvent(isLoading: false));
      add(ShoppingChangeHasFileEvent(hasFile: true));
      add(ShoppingChangeFileNameEvent(fileName: nameDocumentPdf));
      add(ShoppingChangeUint8ListBytesEvent(bytes: bytes));
      add(ShoppingChangeNumPagesEvent(pages: pages));
      bytes = null;
    } catch (e) {
      print(e);
      add(ShoppingChangeIsLoadingEvent(isLoading: false));
      onRemove();
      print("Error al seleccionar el archivo.");
    }
  }

  void onRemove() async {
    add(ShoppingChangeHasFileEvent(hasFile: false));
    add(ShoppingChangeFileNameEvent(fileName: "example.pdf"));
    add(ShoppingChangeUint8ListBytesEvent(bytes: null));
    add(ShoppingChangeNumPagesEvent(pages: 0));
  }

  void totalPriceCalculate() {
    final double caclulate =
        state.pages *
        (state.isColor ? priceColor : priceBlackAndWhite) *
        (state.isFormatCarta ? priceCartaPerPage : priceOficioPerPage);
    add(ShoppingChangeTotalPriceEvent(totalPrice: caclulate));
  }
}
