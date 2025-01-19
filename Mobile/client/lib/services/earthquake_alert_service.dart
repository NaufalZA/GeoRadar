import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';

class EarthquakeAlertService {
  static const double ALERT_RADIUS_KM = 100.0;
  static final DatabaseReference _database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://georadar-401bb-default-rtdb.asia-southeast1.firebasedatabase.app',
  ).ref();
  
  static const double _defaultLat = -6.89801698411407;
  static const double _defaultLong = 107.63581353819215;

  static Stream<bool> getAlertStatus() {
    final alertRef = _database.child('Alert');
    debugPrint('Subscribing to Alert status from Firebase');
    
    alertRef.onValue.listen((event) {
      debugPrint('Alert status changed: ${event.snapshot.value}');
    }, onError: (error) {
      debugPrint('Error listening to Alert status: $error');
    });

    return alertRef.onValue.map((event) {
      return event.snapshot.value as bool? ?? false;
    });
  }
  
  static Future<Position> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      debugPrint('Location service enabled: $serviceEnabled');
      
      if (!serviceEnabled) {
        debugPrint('Using default location (service disabled)');
        return _getDefaultPosition();
      }

      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint('Initial permission status: $permission');
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        debugPrint('Permission after request: $permission');
        if (permission == LocationPermission.denied) {
          debugPrint('Using default location (permission denied)');
          return _getDefaultPosition();
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Using default location (permission denied forever)');
        return _getDefaultPosition();
      }

      final position = await Geolocator.getCurrentPosition();
      debugPrint('Got current location: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      debugPrint('Error getting location: $e');
      return _getDefaultPosition();
    }
  }

  static Position _getDefaultPosition() {
    return Position(
      latitude: _defaultLat,
      longitude: _defaultLong,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );
  }

  static double calculateDistance(double lat1, double lon1, dynamic lat2, dynamic lon2) {
    // Convert dynamic types to double
    final latitude2 = lat2 is num ? lat2.toDouble() : 0.0;
    final longitude2 = lon2 is num ? lon2.toDouble() : 0.0;
    
    return Geolocator.distanceBetween(lat1, lon1, latitude2, longitude2) / 1000;
  }
}
