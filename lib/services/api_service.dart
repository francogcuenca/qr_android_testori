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

  static Future<List<Map<String, dynamic>>> getMovimientos({
    int? creadorId,
    String? dateFrom,
    String? dateTo,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    // Armar query params
    final params = <String, String>{};
    if (creadorId != null) params['creador_id'] = creadorId.toString();
    if (dateFrom != null) params['dateFrom'] = dateFrom;
    if (dateTo != null) params['dateTo'] = dateTo;

    final uri = Uri.parse(
      "$baseUrl/movimientos/ver",
    ).replace(queryParameters: params.isEmpty ? null : params);

    final res = await http.get(
      uri,
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);

      // Asegura lista casteada correctamente
      return List<Map<String, dynamic>>.from(decoded['movimientos'] ?? []);
    } else {
      print("Error al obtener movimientos: ${res.statusCode} -> ${res.body}");
      return [];
    }
  }
}
