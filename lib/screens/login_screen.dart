import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loading = false;

  login() async {
    print("========== LOGIN INICIADO ==========");
    print("Usuario ingresado: '${userCtrl.text}'");
    print("Password ingresado: '${passCtrl.text}'");

    setState(() => loading = true);

    final token = await ApiService.login(userCtrl.text, passCtrl.text);

    print("Respuesta del login (token): $token");

    setState(() => loading = false);

    if (token != null) {
      print("Token válido recibido. Guardando en SharedPreferences...");

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      print("Token guardado correctamente");
      print("Redirigiendo a /scanner ...");

      Navigator.pushReplacementNamed(context, '/home');
    } else {
      print("LOGIN FALLÓ: token == null");
      print("Backend devolvió error o status != 200");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Usuario o contraseña incorrectos")),
      );
    }

    print("========== FIN LOGIN ==========\n");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: userCtrl,
                decoration: InputDecoration(labelText: "Usuario"),
              ),
              TextField(
                controller: passCtrl,
                decoration: InputDecoration(labelText: "Contraseña"),
                obscureText: true,
              ),
              SizedBox(height: 20),
              loading
                  ? CircularProgressIndicator()
                  : ElevatedButton(onPressed: login, child: Text("Ingresar")),
            ],
          ),
        ),
      ),
    );
  }
}
