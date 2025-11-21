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
    setState(() => loading = true);
    final token = await ApiService.login(userCtrl.text, passCtrl.text);

    setState(() => loading = false);

    if (token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      Navigator.pushReplacementNamed(context, '/scanner');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Usuario o contraseña incorrectos")),
      );
    }
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
