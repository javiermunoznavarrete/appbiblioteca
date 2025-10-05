import 'package:app_tareas/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController {
  AuthController(this._repo);
  final AuthRepository _repo;

  Future<String?> login(String email, String password) async {
    try {
      await _repo.signIn(email, password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapErrorCode(e.code);
    }
  }

  String _mapErrorCode(String code) {
    switch (code) {
      case 'wrong-password':
        return 'Usuario o contraseña incorrecta';
      case 'user-not-found':
        return 'Usuario no encontrado';
      case 'invalid-email':
        return 'Email inválido';
      case 'user-disabled':
        return 'Usuario no habilitado';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde';
      case 'operation-not-allowed':
        return 'El método de autenticación no está habilitado en Firebase';
      default:
        return 'No se puede iniciar sesión ($code)';
    }
  }
}
