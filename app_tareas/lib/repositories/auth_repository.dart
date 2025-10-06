class AuthRepository {
  /// Login mock que solo valida formato.
  /// Retorna null si es exitoso, o un mensaje de error si falla la validación.
  Future<String?> signIn(String email, String password) async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 300));

    // Validar formato de email
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return 'invalid-email';
    }

    // Validar longitud de contraseña (mínimo 6 caracteres)
    if (password.length < 6) {
      return 'weak-password';
    }

    // Login exitoso
    return null;
  }
}
