import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const baseUrl = "http://tu-api.com";

  static Future<String?> login(String user, String pass) async {
    final res = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"user": user, "pass": pass}),
    );

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      return json["token"];
    }

    return null;
  }

  static Future<List> getGrupos() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final res = await http.get(
      Uri.parse("$baseUrl/grupos"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      return [];
    }
  }
}
