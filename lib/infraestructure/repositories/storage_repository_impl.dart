import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:printfast_rebuild/domain/repositories/storage_repository.dart';
import 'package:printfast_rebuild/domain/services/storage_service.dart';

class StorageRepositoryImpl extends StorageRepository {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final StorageService storageService;
  StorageRepositoryImpl({required this.storageService});

  /// Obtiene el PDF desde Firebase Storage usando la URL
  /// Retorna los bytes del archivo que luego puedes mostrar en un PDF Viewer
  @override
  Future<Uint8List?> getPdfFileFromCloudStorage(String fileUrl) async {
    try {
      return await storageService.getPdfFileFromCloudStorage(fileUrl);
    } on FirebaseException catch (e) {
      return Future.error(e);
    }
  }
}
