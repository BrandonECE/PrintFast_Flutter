// lib/blocs/cloud_storage_pdf_view/cloud_storage_pdf_view_bloc.dart

import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:printfast_rebuild/config/constants/cloud_storage_url.dart';
import 'package:printfast_rebuild/domain/repositories/storage_repository.dart';
import 'package:printing/printing.dart';

part 'cloud_storage_pdf_event.dart';
part 'cloud_storage_pdf_state.dart';

class CloudStoragePdfBloc
    extends Bloc<CloudStoragePdfEvent, CloudStoragePdfState> {
  final StorageRepository storageRepository;

  static const String _cloudStorageURL = CloudStorageUrl.cloudStorageUrl;
  static String _cloudStorageURLUsed =
      "$_cloudStorageURL/userRegistration/pdfName";

  CloudStoragePdfBloc({required this.storageRepository})
    : super(CloudStoragePdfViewInitial()) {
    on<ChangePdfFileFromCloudStorageEvent>((event, emit) {
      emit(state.copyWith(fileFromCloudStorage: event.fileFromCloudStorage));
    });

    on<ChangeStatusPdfFileFromCloudStorageEvent>((event, emit) {
      emit(
        state.copyWith(
          cloudStoragePdfViewStatus: event.cloudStoragePdfViewStatus,
        ),
      );
    });

    on<ChangeStatusPdfFileFromCloudStorageToPrintEvent>((event, emit) {
      emit(
        state.copyWith(
          cloudStoragePrintPdfStatus: event.cloudStoragePrintPdfStatus,
        ),
      );
    });
  }

  Future<void> fileFromCloudStorage(String cloudStorageURL) async {
    try {
      add(
        ChangeStatusPdfFileFromCloudStorageEvent(
          cloudStoragePdfViewStatus: CloudStoragePdfViewStatus.loading,
        ),
      );
      await Future.delayed(Duration(milliseconds: 300));
      final fileFromCloudStorage = await getCachedPdfOrDownload(
        cloudStorageURL,
      );
      add(
        ChangePdfFileFromCloudStorageEvent(
          fileFromCloudStorage: fileFromCloudStorage,
        ),
      );
      add(
        ChangeStatusPdfFileFromCloudStorageEvent(
          cloudStoragePdfViewStatus: CloudStoragePdfViewStatus.success,
        ),
      );

      print("CloudStoragePdfViewBloc -> EXITO al descargar archivo");
    } catch (e, st) {
      print("CloudStoragePdfViewBloc -> Error: $e");
      print(st);
      add(
        ChangeStatusPdfFileFromCloudStorageEvent(
          cloudStoragePdfViewStatus: CloudStoragePdfViewStatus.failure,
        ),
      );
      add(ChangePdfFileFromCloudStorageEvent(fileFromCloudStorage: null));
    }
  }

  //
  Future<void> printPdf(String cloudStorageURL) async {
    add(
      ChangeStatusPdfFileFromCloudStorageToPrintEvent(
        cloudStoragePrintPdfStatus: CloudStoragePrintPdfStatus.loading,
      ),
    );
    try {
      final fileFromCloudStorage = await getCachedPdfOrDownload(
        cloudStorageURL,
      );
      add(
        ChangePdfFileFromCloudStorageEvent(
          fileFromCloudStorage: fileFromCloudStorage,
        ),
      );
      await Printing.layoutPdf(
        onLayout: (format) async => state.fileFromCloudStorage!,
      );
      add(
        ChangeStatusPdfFileFromCloudStorageToPrintEvent(
          cloudStoragePrintPdfStatus: CloudStoragePrintPdfStatus.initial,
        ),
      );
    } catch (e) {
      add(
        ChangeStatusPdfFileFromCloudStorageToPrintEvent(
          cloudStoragePrintPdfStatus: CloudStoragePrintPdfStatus.failure,
        ),
      );
      print("Error al imprimir: $e");
    }
  }

  //
  Future<Uint8List?> getCachedPdfOrDownload(String cloudStorageURL) async {
    print('CloudStoragePdfViewBloc -> cloudStorageURL: $cloudStorageURL');
    print(
      'CloudStoragePdfViewBloc -> _cloudStorageURLUsed: $_cloudStorageURLUsed',
    );
    Uint8List? fileFromCloudStorage = state.fileFromCloudStorage;
    if (cloudStorageURL != _cloudStorageURLUsed) {
      try {
        _cloudStorageURLUsed = cloudStorageURL;
        fileFromCloudStorage = await storageRepository
            .getPdfFileFromCloudStorage(cloudStorageURL);
        print("Cargado");
      } catch (e) {
        _cloudStorageURLUsed = "$_cloudStorageURL/userRegistration/pdfName";
        return Future.error(e);
      }
    }
    return fileFromCloudStorage;
  }

  // //
  // String _getFinalUrl(String userRegistration, String pdfName) {
  //   final sanitizedUserRegistration = userRegistration.startsWith('/')
  //       ? userRegistration.substring(1)
  //       : userRegistration;
  //   final sanitizedPdfName = pdfName.startsWith('/')
  //       ? pdfName.substring(1)
  //       : pdfName;

  //   final String uniteInformation =
  //       "$sanitizedUserRegistration/$sanitizedPdfName";
  //   final String finalURL = _cloudStorageURL.endsWith('/')
  //       ? '${_cloudStorageURL.substring(0, _cloudStorageURL.length - 1)}/$uniteInformation'
  //       : '$_cloudStorageURL/$uniteInformation';
  //   return finalURL;
  // }
}
