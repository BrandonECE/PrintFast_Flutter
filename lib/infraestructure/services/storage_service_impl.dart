import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';

import 'package:printfast_rebuild/domain/services/storage_service.dart';

class StorageServiceImpl extends StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Obtiene el PDF desde Firebase Storage usando la URL
  /// Retorna los bytes del archivo que luego puedes mostrar en un PDF Viewer
  @override
  Future<Uint8List?> getPdfFileFromCloudStorage(String fileUrl) async {
    try {
      // Convertimos la URL en referencia de Firebase
      final ref = _storage.refFromURL(fileUrl);
      // Obtenemos los bytes del archivo (máx 100 MB en este ejemplo)
      final data = await ref.getData(100 * 1024 * 1024); 
      return data;
    } on FirebaseException catch (e) {
      print('Error al obtener PDF: $e');
      return Future.error(e);
    }
  }

  
}
