import 'package:app_tareas/repositories/auth_repository.dart';

class AuthController {
  AuthController(this._repo);
  final AuthRepository _repo;

  Future<String?> login(String email, String password) async {
    final errorCode = await _repo.signIn(email, password);
    if (errorCode == null) {
      return null;
    }
    return _mapErrorCode(errorCode);
  }

  String _mapErrorCode(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Email inválido';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres';
      default:
        return 'No se puede iniciar sesión';
    }
  }
}
