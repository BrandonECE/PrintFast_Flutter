import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf_render_plus/pdf_render.dart';
import 'package:printfast_rebuild/config/constants/cloud_storage_url.dart';
import 'package:printfast_rebuild/domain/entities/all_entities/aorder_entity.dart';
import 'package:printfast_rebuild/domain/entities/all_entities/copyshop_entity.dart';
import 'package:printfast_rebuild/domain/entities/all_entities/user_entity.dart';
import 'package:printfast_rebuild/domain/repositories/user_repository.dart';

part 'shopping_event.dart';
part 'shopping_state.dart';

class ShoppingBloc extends Bloc<ShoppingEvent, ShoppingState> {
  static const String _cloudStorageURL = CloudStorageUrl.cloudStorageUrl;
  final double priceCartaPerPage = 2.0;
  final double priceOficioPerPage = 3.0;
  final double priceBlackAndWhite = 1.0;
  final double priceColor = 2.0;
  final UserRepository userRepository;
  ShoppingBloc({required this.userRepository}) : super(ShoppingInitial()) {
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

    on<ShoppingChangeStatusEvent>((event, emit) {
      emit(
        state.copyWith(
          shoppingStatus: event.shoppingStatus,
          messageError: event.messageError,
        ),
      );
    });

    on<ShoppingResetEvent>((event, emit) {
      print("testsss - RESETEANDOOOO");
      emit(ShoppingInitial().copyWith(shoppingStatus: event.shoppingStatus));
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

  Future<void> processingPayment(
    UserEntity userEntity,
    CopyShopEntity selectedCopyShop,
    String paymentMethod,
  ) async {
    add(ShoppingChangeStatusEvent(shoppingStatus: ShoppingStatus.loading));

    try {
      final getOrderCode = await userRepository.generateUniqueOrderCode(
        selectedCopyShop.copyShopEmail,
      );

      // ignore: unused_local_variable
      final AorderEntity aorderEntity = AorderEntity(
        copyShopName: selectedCopyShop.copyShopName,
        copyShopEmail: selectedCopyShop.copyShopEmail,
        userRegistration: userEntity.registration,
        userName: userEntity.name,
        orderCode: getOrderCode,
        hasItBeenCanceledByUser: false,
        hasItBeenCompleted: false,
        estimatedDeliveryTime: selectedCopyShop.estimatedDeliveryTime,
        hasTheEstimatedDeliveryTimeChanged: false,
        hasItBeenAccepted: null,
        format: state.isFormatCarta ? "Carta" : "Oficio",
        initDate: DateTime.now(),
        isColor: state.isColor,
        pages: state.pages,
        pdfName: state.fileName,
        placeLat: selectedCopyShop.lat,
        placeLong: selectedCopyShop.long,
        price: state.totalPrice,
        pdfFileBytes: state.bytes,
        url: _getFinalUrl(userEntity.registration, state.fileName),
        paymentMethod: paymentMethod,
        verificationCode: generateFiveDigitCode(),
        printDate: null,
      );

      //  throw Exception("La recepción de órdenes está temporalmente detenida en esta papelería.");

      final bool isCopyshopPaused = await userRepository.isCopyshopPaused(
        selectedCopyShop.copyShopEmail,
      );
      if (isCopyshopPaused) {
        add(
          ShoppingChangeStatusEvent(
            shoppingStatus: ShoppingStatus.failureByNoReception,
            messageError:
                "La recepción de órdenes está temporalmente detenida en esta papelería.",
          ),
        );
        return;
      }

      await userRepository.placeAOrder(aorderEntity, uploadPdf: true);

      await Future.delayed(Duration(milliseconds: 1000));

      add(ShoppingChangeStatusEvent(shoppingStatus: ShoppingStatus.inProgress));
      //###Next Step...
      //###Next Step...
      //###Next Step...
    } catch (e) {
      add(
        ShoppingChangeStatusEvent(
          shoppingStatus: ShoppingStatus.failure,
          messageError: e.toString(),
        ),
      );
    }
  }

  dynamic _prepareForPrint(dynamic value) {
    if (value == null) return null;

    // DateTime
    if (value is DateTime) return value.toIso8601String();

    // Intentar detectar Timestamp de Firestore (llamando a toDate() si existe)
    try {
      final dyn = value as dynamic;
      if (dyn != null && dyn.toDate is Function) {
        final dt = dyn.toDate();
        if (dt is DateTime) return dt.toIso8601String();
      }
    } catch (_) {
      // no es un Timestamp o no se pudo convertir -> seguir
    }

    // Map -> procesar recursivamente
    if (value is Map) {
      final Map<String, dynamic> out = {};
      value.forEach((k, v) {
        out[k.toString()] = _prepareForPrint(v);
      });
      return out;
    }

    // List -> procesar cada elemento
    if (value is List) {
      return value.map((e) => _prepareForPrint(e)).toList();
    }

    // Otros tipos primitivos: devolver tal cual
    return value;
  }

  void printAorderEntity(dynamic aorder) {
    if (aorder == null) {
      print('Aorder: null');
      return;
    }

    dynamic rawMap;
    try {
      if (aorder is Map) {
        rawMap = aorder;
      } else {
        // Intentar llamar toMap() en la instancia (AorderEntity)
        rawMap = (aorder as dynamic).toMap();
      }
    } catch (e) {
      print('Error convirtiendo la entidad a Map: $e');
      print('Valor (toString): ${aorder.toString()}');
      return;
    }

    final printable = _prepareForPrint(rawMap);
    final pretty = const JsonEncoder.withIndent('  ').convert(printable);
    print(pretty);
  }

  String _getFinalUrl(String userRegistration, String pdfName) {
    final sanitizedUserRegistration = userRegistration.startsWith('/')
        ? userRegistration.substring(1)
        : userRegistration;
    final sanitizedPdfName = pdfName.startsWith('/')
        ? pdfName.substring(1)
        : pdfName;

    final String uniteInformation =
        "$sanitizedUserRegistration/$sanitizedPdfName";
    final String finalURL = _cloudStorageURL.endsWith('/')
        ? '${_cloudStorageURL.substring(0, _cloudStorageURL.length - 1)}/$uniteInformation'
        : '$_cloudStorageURL/$uniteInformation';
    return finalURL;
  }

  String generateFiveDigitCode() {
    final random = Random();
    String code = '';
    for (int i = 0; i < 5; i++) {
      code += random.nextInt(10).toString(); // genera un dígito (0-9)
    }
    return code;
  }
}
