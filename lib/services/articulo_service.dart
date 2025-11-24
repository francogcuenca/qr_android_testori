import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ArticuloService {
  static Future<String?> getArticuloDescripcion(String codigo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final url = Uri.parse("http://192.168.50.66:11011/api/isis/art/$codigo");

      final res = await http.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      );

      print('DEBUG: Body -> ${res.body}');

      final data = jsonDecode(res.body);

      if (data is List && data.isNotEmpty) {
        return data[0]["DescripcionArti"] as String?;
      }

      return null;
    } catch (e) {
      print('ERROR en getArticuloDescripcion: $e');
      return null;
    }
  }
}
