import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const baseUrl = "http://192.168.50.66:11011/api";

  static Future<String?> login(String user, String pass) async {
    final url = "$baseUrl/login";
    print("Llamando a: $url");

    final bodyJson = jsonEncode({"user": user, "pass": pass});
    print("Body enviado: $bodyJson");

    final res = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: bodyJson,
    );

    print("Status code: ${res.statusCode}");
    print("Body recibido: ${res.body}");

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      print("JSON parseado: $json");

      return json["token"]; // si este campo no existe => null
    }

    return null;
  }

  static Future<List> getAlmacenes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      print("=== DEBUG getAlmacenes ===");
      print("Token: $token");

      final res = await http.get(
        Uri.parse("$baseUrl/almacenes"),
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
      );

      print("Status: ${res.statusCode}");
      print("Body: ${res.body}");

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        print("Decoded: $data");
        print("=== FIN DEBUG ===");
        return data;
      }

      print("Respuesta no OK, devolviendo lista vacía");
      print("=== FIN DEBUG ===");
      return [];
    } catch (e) {
      print("ERROR getAlmacenes: $e");
      return [];
    }
  }

  static Future<http.Response> postMovimiento({
    required String almacenOrigen,
    required String almacenDestino,
    required List<Map<String, dynamic>> qrs,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final body = jsonEncode({
      'almacen_origen': almacenOrigen,
      'almacen_destino': almacenDestino,
      'qrs': qrs,
    });

    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final res = await http.post(
      Uri.parse("$baseUrl/movimientos/crear"),
      headers: headers,
      body: body,
    );

    return res;
  }

  static Future<List> getMovimientos({int? creadorId}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    String url = "$baseUrl/movimientos/ver";

    if (creadorId != null) {
      url += "?creador_id=$creadorId";
    }

    final res = await http.get(
      Uri.parse(url),
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      return decoded['movimientos'] ?? [];
    }

    return [];
  }
}
