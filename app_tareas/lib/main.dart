import 'package:app_tareas/login_screen.dart'; // Importa un archivo donde está definida la pantalla de inicio de sesión
import 'package:flutter/material.dart'; // Importa las herramientas necesarias de Flutter para construir la interfaz
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const MainApp(),
  ); // Función principal: ejecuta la aplicación usando el widget MainApp
}

class MainApp extends StatelessWidget {
  // Define una clase MainApp que no puede cambiar (es inmutable)
  const MainApp({
    super.key,
  }); // Constructor de la clase, que permite usar claves únicas para el widget

  @override
  Widget build(BuildContext context) {
    // Define cómo se ve el widget
    return MaterialApp(
      title: "Biblioteca Digital", // Título de la aplicación
      home:
          const LoginScreen(), // La primera pantalla que se muestra es LoginScreen
    );
  }
}
