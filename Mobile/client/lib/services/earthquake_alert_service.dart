import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

class EarthquakeAlertService {
  static const double ALERT_RADIUS_KM = 100.0;
  
  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  static double calculateDistance(double lat1, double lon1, dynamic lat2, dynamic lon2) {
    // Convert dynamic types to double
    final latitude2 = lat2 is num ? lat2.toDouble() : 0.0;
    final longitude2 = lon2 is num ? lon2.toDouble() : 0.0;
    
    return Geolocator.distanceBetween(lat1, lon1, latitude2, longitude2) / 1000;
  }
}
