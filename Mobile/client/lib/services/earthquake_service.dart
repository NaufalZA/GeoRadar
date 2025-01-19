import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/earthquake.dart';
import '../models/earthquake_stats.dart';

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

  Future<EarthquakeStats> getEarthquakeStats() async {
    final response = await http.get(Uri.parse('https://georadar.onrender.com/api/gempa'));
    
    if (response.statusCode == 200) {
      return EarthquakeStats.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load earthquake statistics');
    }
  }
}
