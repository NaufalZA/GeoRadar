import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/disaster.dart';

class ApiService {
  // static const String baseUrl = 'http://10.0.2.2:3000';
  static const String baseUrl = 'https://georadar.onrender.com';

  Future<List<Disaster>> getDisasters() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/bencana'));
      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Disaster.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load disasters');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }
}
