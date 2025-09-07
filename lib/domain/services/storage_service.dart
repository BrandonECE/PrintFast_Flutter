import 'dart:typed_data';

abstract class StorageService {
  Future<Uint8List?> getPdfFileFromCloudStorage(String fileUrl);
}
