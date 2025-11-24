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
        useMaterial3: false, // ← IMPORTANTE para evitar colores raros
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0), // ← tu azul
          primary: const Color(0xFF1565C0),
        ),
        primaryColor: const Color(0xFF1565C0),

        scaffoldBackgroundColor: const Color(0xFFF5F7FA),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1565C0),
          elevation: 2,
          titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1565C0),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}
