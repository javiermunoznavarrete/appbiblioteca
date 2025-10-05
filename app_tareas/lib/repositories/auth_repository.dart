import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  AuthRepository({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  Future<UserCredential> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Crea un usuario con email y contraseña usando Firebase Authentication.
  ///
  /// Lanza FirebaseAuthException en caso de error (email in use, weak-password, etc.).
  Future<UserCredential> register(String email, String password) {
    return _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  /// Elimina el usuario actualmente autenticado (si existe).
  /// Lanza [FirebaseAuthException] si la operación falla (por ejemplo requiere reauth).
  Future<void> deleteCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(code: 'user-not-signed-in', message: 'No hay usuario autenticado');
    }
    await user.delete();
  }
}
