import 'dart:typed_data';

abstract class StorageRepository {
  Future<Uint8List?> getPdfFileFromCloudStorage(String fileUrl);
    /// Sube bytes del PDF y devuelve la ruta relativa en el bucket, p.ej. "orders/{registration}/{pdfName}"
  /// Sube bytes y devuelve la ruta relativa dentro del bucket (ej: 'orders/{registration}/{file.pdf}')
  Future<String> uploadPdfBytes({
    required Uint8List bytes,
    required String userRegistration,
    required String pdfName,
  });

  /// Borra archivo por ruta relativa (path) dentro del bucket
  Future<void> deleteFileByPath(String path);
}
