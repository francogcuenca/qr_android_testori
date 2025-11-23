import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/scanner_screen.dart';
import 'screens/movimientos_screen.dart';
import 'screens/movimiento_detalle_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QR Picker',

      // Pantalla inicial (login)
      initialRoute: '/',

      // Definición de rutas
      routes: {
        '/': (_) => LoginScreen(),
        '/home': (_) => HomeScreen(),
        '/scanner': (_) => ScannerScreen(singleMode: false),
        '/movimientos': (_) => MovimientosScreen(),
      },

      // Tema base
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
    );
  }
}
