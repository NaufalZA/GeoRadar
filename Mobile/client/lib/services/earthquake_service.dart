import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/earthquake.dart';

class EarthquakeService {
  static const String baseUrl = 'https://data.bmkg.go.id/DataMKG/TEWS';

  Future<List<Earthquake>> getRecentEarthquakes() async {
    final response = await http.get(Uri.parse('$baseUrl/gempadirasakan.json'));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final earthquakes = data['Infogempa']['gempa'] as List;
      return earthquakes.map((e) => Earthquake.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load earthquake data');
    }
  }
}
