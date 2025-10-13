import 'dart:typed_data';

abstract class StorageService {
  Future<Uint8List?> getPdfFileFromCloudStorage(String fileUrl);
    Future<String> uploadPdfBytes({
    required Uint8List bytes,
    required String userRegistration,
    required String pdfName,
  });

  /// Borra archivo por ruta relativa en bucket ("orders/...")
  Future<void> deleteFileByPath(String path);
}
