import 'package:app_tareas/controllers/auth_controller.dart';
import 'package:app_tareas/repositories/auth_repository.dart';
import 'package:app_tareas/book_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; // Importa las herramientas visuales de Flutter

// Define un widget con estado (porque hay campos que cambian, como contraseña oculta o cargando)
class LoginFields extends StatefulWidget {
  const LoginFields({super.key}); // Constructor del widget con clave opcional

  @override
  State<LoginFields> createState() => _LoginFieldsState(); // Crea el estado del widget
}

class _LoginFieldsState extends State<LoginFields> {
  final _formKey =
      GlobalKey<FormState>(); // Llave para manejar el formulario y validaciones
  final _emailCtrl =
      TextEditingController(); // Controlador para el campo de email
  final _passCtrl =
      TextEditingController(); // Controlador para el campo de contraseña

  bool _obscure = true; // Para ocultar o mostrar la contraseña
  bool _loading =
      false; // Para indicar si está cargando (ej. al enviar el formulario)
  String? _error; // Para guardar y mostrar un posible mensaje de error

  final AuthController _auth = AuthController(AuthRepository());

  @override
  void dispose() {
    // Libera los recursos de los controladores cuando el widget se destruye
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Lógica para enviar el formulario
    FocusScope.of(context).unfocus(); // Oculta el teclado
    final ok = _formKey.currentState?.validate() ?? false; // Valida los campos
    if (!ok) return; //Si no es válido no continua

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final email = _emailCtrl.text.trim();
      final password = _passCtrl.text.trim();

      final errorMessage = await _auth.login(email, password);

      if (!mounted) {
        return; // Seguridad: evita usar context si el widget se removió.
      }

      if (errorMessage == null) {}

      if (errorMessage == null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const BookScreen()),
        );
      } else {
        setState(() => _error = errorMessage);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Construye la parte visual del widget
    return AutofillGroup(
      // Agrupa campos que permiten autocompletar
      child: Form(
        key: _formKey, // Usa la llave definida antes para validar
        autovalidateMode: AutovalidateMode
            .onUserInteraction, // Valida automáticamente mientras el usuario escribe
        child: Column(
          // Organiza los widgets en una columna
          crossAxisAlignment:
              CrossAxisAlignment.stretch, // Estira el contenido horizontalmente
          mainAxisSize: MainAxisSize.min, // Ocupa el mínimo espacio necesario
          children: [
            Center(
              // Centra la imagen
              child: Image.network(
                "https://i.ibb.co/gbM1xQbB/logo-inacap.jpg", // Logo de Inacap
                height: 100,
                fit: BoxFit.contain, // Ajusta la imagen sin recortarla
              ),
            ),
            const SizedBox(height: 16), // Espacio vertical

            const Text(
              "Bienvenido Inacapino", // Mensaje de bienvenida
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ), // Estilo del texto
              textAlign: TextAlign.center, // Centra el texto
            ),
            TextFormField(
              // Campo de texto para el email
              enabled:
                  !_loading, // Está deshabilitado si _loading es falso (esto parece un error lógico, debería ser !loading)
              controller: _emailCtrl, // Controlador del campo
              keyboardType: TextInputType
                  .emailAddress, // Tipo de teclado: correo electrónico
              textCapitalization:
                  TextCapitalization.none, // No capitaliza automáticamente
              autocorrect: false, // No corrige automáticamente
              enableSuggestions: true, // Permite sugerencias del teclado
              autofillHints: const [
                AutofillHints.email,
              ], // Sugerencia para autocompletar email
              decoration: const InputDecoration(
                labelText: "Email", // Etiqueta del campo
                hintText: "ejemplo@ejemplo.com", // Texto de ayuda
                prefixIcon: Icon(Icons.email_outlined), // Ícono al inicio
                border: OutlineInputBorder(), // Borde alrededor del campo
              ),
              validator: (v) {
                final value = v?.trim() ?? '';
                if (value.isEmpty) return "Ingresa tu email";
                final emailOk = RegExp(r'^\S+@\S+\.\S+$').hasMatch(value);
                return emailOk ? null : "Email inválido";
              },
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
            ),
            const SizedBox(height: 12),

            TextFormField(
              enabled: !_loading,
              controller: _passCtrl,
              obscureText: _obscure,
              enableSuggestions: false,
              autocorrect: false,
              autofillHints: const [AutofillHints.password],
              decoration: InputDecoration(
                labelText: "Contraseña",
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(
                    _obscure ? Icons.visibility : Icons.visibility_off,
                  ),
                  tooltip: _obscure ? "Mostrar" : "Ocultar",
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return "Ingrese la contraseña";
                if (v.length < 6) return "Mínimo 6 caracteres";
                return null; //valida
              },
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 8),

            if (_error != null)
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 16),
            //--------------------Boton------------------------------------
            SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text("Ingresar"),
              ),
            ),
            const SizedBox(height: 8),

            TextButton(
              onPressed: _loading ? null : () {},
              child: const Text("¿Olvidaste tu contraseña?"),
            ),
            const SizedBox(height: 8),
            const SizedBox(height: 8),
            // Botón para registrar un usuario nuevo mediante un diálogo
            SizedBox(
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: _loading
                    ? null
                    : () async {
                        final repo = AuthRepository();
                        final result = await showDialog<Map<String, String>?>(
                          context: context,
                          builder: (context) {
                            final eCtrl = TextEditingController();
                            final pCtrl = TextEditingController();
                            return AlertDialog(
                              title: const Text('Registrar usuario'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    controller: eCtrl,
                                    decoration: const InputDecoration(labelText: 'Email'),
                                  ),
                                  TextField(
                                    controller: pCtrl,
                                    decoration: const InputDecoration(labelText: 'Password'),
                                    obscureText: true,
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(null),
                                  child: const Text('Cancelar'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.of(context).pop({'e': eCtrl.text.trim(), 'p': pCtrl.text.trim()}),
                                  child: const Text('Registrar'),
                                ),
                              ],
                            );
                          },
                        );

                        if (result == null) return;
                        final email = result['e'] ?? '';
                        final pass = result['p'] ?? '';
                        if (email.isEmpty || pass.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email y password requeridos')));
                          return;
                        }
                        setState(() {
                          _loading = true;
                          _error = null;
                        });
                        try {
                          await repo.register(email, pass);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuario registrado con éxito')));
                        } on FirebaseAuthException catch (e) {
                          if (!mounted) return;
                          final msg = e.message ?? 'Error al registrar usuario';
                          setState(() => _error = msg);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                        } finally {
                          if (mounted) setState(() => _loading = false);
                        }
                      },
                child: const Text('Registrar usuario'),
              ),
            ),
            const SizedBox(height: 8),
            // Botón para eliminar la cuenta actualmente autenticada (si existe)
            SizedBox(
              height: 44,
              child: OutlinedButton(
                onPressed: _loading
                    ? null
                    : () async {
                        setState(() {
                          _loading = true;
                          _error = null;
                        });
                        final repo = AuthRepository();
                        try {
                          await repo.deleteCurrentUser();
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuario eliminado')));
                        } on FirebaseAuthException catch (e) {
                          if (!mounted) return;
                          final msg = e.message ?? 'Error al eliminar usuario';
                          setState(() => _error = msg);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                        } catch (e) {
                          if (!mounted) return;
                          final msg = 'Error inesperado: $e';
                          setState(() => _error = msg);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                        } finally {
                          if (mounted) setState(() => _loading = false);
                        }
                      },
                child: const Text('Eliminar cuenta actual'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
