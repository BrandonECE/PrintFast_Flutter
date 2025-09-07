import 'dart:typed_data';

abstract class StorageRepository {
  Future<Uint8List?> getPdfFileFromCloudStorage(String fileUrl);
}
