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

  String _sanitizeFileName(String name) {
    // Reemplaza slash/backslash y múltiples espacios por "_" para no crear subfolders
    return name.replaceAll(RegExp(r'[\\/]+'), '_').trim();
  }

  @override
  Future<String> uploadPdfBytes({
    required Uint8List bytes,
    required String userRegistration,
    required String pdfName,
  }) async {
    try {
      final sanitized = _sanitizeFileName(pdfName);
      print('$userRegistration/$sanitized');
      final path =
          '$userRegistration/$sanitized'; // <-- aquí: carpeta por matrícula EXACTA
      final ref = _storage.ref().child(path);
      final metadata = SettableMetadata(contentType: 'application/pdf');

      final uploadTask = ref.putData(bytes, metadata);
      final snap = await uploadTask.whenComplete(() {});
      if (snap.state != TaskState.success) {
        return Future.error('Upload failed: ${snap.state}');
      }

      // devolvemos fullPath relativo (ej: '1974238/mayor3970.pdf')
      return ref.fullPath;
    } on FirebaseException catch (e) {
      return Future.error(e);
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  Future<void> deleteFileByPath(String path) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.delete();
    } on FirebaseException catch (e) {
      return Future.error(e);
    } catch (e) {
      return Future.error(e);
    }
  }
}
