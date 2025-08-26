import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart'; // para FirebaseException (si lo necesitas)
import 'package:printfast_rebuild/domain/entities/entities.dart';
import 'package:printfast_rebuild/domain/repositories/user_repository.dart';
import 'package:printfast_rebuild/domain/services/auth_service.dart';

class AuthServiceImpl extends AuthService {
  final FirebaseAuth _auth;
  final UserRepository _userRepository;

  AuthServiceImpl({
    FirebaseAuth? firebaseAuth,
    required UserRepository userRepository,
  }) : _auth = firebaseAuth ?? FirebaseAuth.instance,
       _userRepository = userRepository;

  // Helper: construye un "correo ficticio" a partir de la matrícula
  String _emailFromRegistration(String registration) =>
      '${registration.trim()}@uanl.edu.mx';

  // -------------------------
  // Registrar usuario (Auth + Firestore) con rollback
  // -------------------------
  @override
  Future<void> register(UserEntity userEntity) async {
    final registration = userEntity.registration.trim();
    final password = userEntity.password;
    final fakeEmail = _emailFromRegistration(registration);

    try {
      // 1) Crear usuario en Firebase Auth
      final userCred = await _auth.createUserWithEmailAndPassword(
        email: fakeEmail,
        password: password,
      );

      final firebaseUser = userCred.user;
      if (firebaseUser == null) {
        return Future.error(
          'No se pudo crear el usuario en el servicio de autenticación.',
        );
      }

      try {
        // 2) Crear datos en Firestore (o a través de tu repositorio)
        // NOTA: tu setNewUser debe usar SetOptions(merge: true) internamente si es necesario
        await _userRepository.setNewUser(userEntity);

        // opcional: mantener displayName en auth
        try {
          await firebaseUser.updateDisplayName(userEntity.name);
        } catch (_) {
          // No crítico: ignoramos si falla el update del displayName
        }

        return;
      } catch (firestoreError) {
        // Rollback: eliminar usuario creado en Auth para no dejar cuentas huérfanas
        try {
          await firebaseUser.delete();
        } catch (_) {
          // Ignoramos error al eliminar; preferimos reportar el error original
        }
        // Mapear tipo de error (si es de red o firestore)
        if (firestoreError is SocketException) {
          return Future.error(
            'Sin conexión. No se pudo guardar los datos del usuario.',
          );
        } else if (firestoreError is FirebaseException) {
          final code = firestoreError.code.toString().toLowerCase();
          if (code.contains('unavailable') ||
              code.contains('network') ||
              code.contains('deadline')) {
            return Future.error(
              'Sin conexión. Revisa tu red e inténtalo de nuevo.',
            );
          }
        }
        return Future.error('Error creando datos en la base: $firestoreError');
      }
    } on FirebaseAuthException catch (e) {
      // Mapear códigos comunes de Auth a mensajes amigables
      switch (e.code) {
        case 'email-already-in-use':
          return Future.error('La matrícula ya está registrada.');
        case 'invalid-email':
          return Future.error('Formato de matrícula inválido.');
        case 'weak-password':
          return Future.error('La contraseña es muy débil.');
        case 'operation-not-allowed':
          return Future.error(
            'Método de autenticación no permitido en la consola de Firebase.',
          );
        case 'network-request-failed':
          return Future.error(
            'Sin conexión. Revisa tu red e inténtalo de nuevo.',
          );
        default:
          return Future.error('Error de autenticación: ${e.message ?? e.code}');
      }
    } on SocketException {
      return Future.error('Sin conexión. Revisa tu red e inténtalo de nuevo.');
    } on FirebaseException catch (e) {
      final code = e.code.toString().toLowerCase();
      if (code.contains('unavailable') ||
          code.contains('network') ||
          code.contains('deadline')) {
        return Future.error(
          'Sin conexión. Revisa tu red e inténtalo de nuevo.',
        );
      }
      return Future.error('Error registrando usuario: ${e.message ?? e.code}');
    } catch (e) {
      return Future.error('Error registrando usuario: $e');
    }
  }

  // -------------------------
  // Iniciar sesión y obtener UserEntity (manejo de errores y de red)
  // -------------------------
  @override
  Future<UserEntity> signInAndGetUser({
    required String registration,
    required String password,
  }) async {
    final fakeEmail = _emailFromRegistration(registration);

    try {
      // Intentar autenticar en Firebase Auth
      final cred = await _auth.signInWithEmailAndPassword(
        email: fakeEmail,
        password: password,
      );

      final firebaseUser = cred.user;
      if (firebaseUser == null) {
        return Future.error('No se pudo iniciar sesión.');
      }

      // Si se autentica correctamente, recuperar datos desde Firestore (repositorio)
      try {
        final userEntity = await _userRepository.getUserInfo(registration);
        return userEntity;
      } on FirebaseException catch (e) {
        final code = e.code.toString().toLowerCase();
        if (code.contains('unavailable') ||
            code.contains('network') ||
            code.contains('deadline')) {
          return Future.error(
            'Sin conexión a Internet. Revisa tu red e inténtalo de nuevo.',
          );
        }
        return Future.error(
          'Sesión iniciada pero no se encontraron datos del usuario: ${e.message ?? e.code}',
        );
      } on SocketException {
        return Future.error(
          'Sin conexión a Internet. Revisa tu red e inténtalo de nuevo.',
        );
      } catch (e) {
        return Future.error(
          'Sesión iniciada pero ocurrió un error al obtener datos del usuario: $e',
        );
      }
    } on FirebaseAuthException catch (e) {
      // Mapear errores típicos de Auth a mensajes amigables
      switch (e.code) {
        case 'user-not-found':
          return Future.error('Usuario no encontrado.');
        case 'wrong-password':
          return Future.error('Contraseña incorrecta.');
        case 'invalid-email':
          return Future.error('Formato de matrícula inválido.');
        case 'user-disabled':
          return Future.error('La cuenta ha sido deshabilitada.');
        case 'too-many-requests':
          return Future.error('Demasiados intentos. Intenta más tarde.');
        case 'network-request-failed':
          return Future.error(
            'Sin conexión a Internet. Revisa tu red e inténtalo de nuevo.',
          );
        default:
          return Future.error('Error de autenticación: ${e.message ?? e.code}');
      }
    } on SocketException {
      return Future.error(
        'Sin conexión a Internet. Revisa tu red e inténtalo de nuevo.',
      );
    } on FirebaseException catch (e) {
      final code = e.code.toString().toLowerCase();
      if (code.contains('unavailable') ||
          code.contains('network') ||
          code.contains('deadline')) {
        return Future.error(
          'Sin conexión a Internet. Revisa tu red e inténtalo de nuevo.',
        );
      }
      return Future.error('Error iniciando sesión: ${e.message ?? e.code}');
    } catch (e) {
      return Future.error('Error iniciando sesión: $e');
    }
  }

  // -------------------------
  // Cerrar sesión
  // -------------------------
  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      return;
    } catch (e) {
      return Future.error('Error cerrando sesión: $e');
    }
  }

  // -------------------------
  // Eliminar usuario autenticado actualmente (Auth)
  // -------------------------
  @override
  Future<void> deleteCurrentAuthUser() async {
    final user = _auth.currentUser;
    if (user == null) return Future.error('No hay usuario autenticado.');
    try {
      await user.delete();
      return;
    } on FirebaseAuthException catch (e) {
      // control específico de errores al eliminar el usuario
      if (e.code == 'requires-recent-login') {
        return Future.error(
          'Operación restringida: necesita iniciar sesión de nuevo recientemente.',
        );
      }
      return Future.error(
        'Error eliminando usuario auth: ${e.message ?? e.code}',
      );
    } on SocketException {
      return Future.error('Sin conexión. Revisa tu red e inténtalo de nuevo.');
    } catch (e) {
      return Future.error('Error eliminando usuario auth: $e');
    }
  }
}
