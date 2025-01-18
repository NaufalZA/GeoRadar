import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../models/earthquake.dart';

class EarthquakeMap extends StatelessWidget {
  final Earthquake earthquake;
  final Position? userLocation;

  const EarthquakeMap({
    Key? key, 
    required this.earthquake,
    this.userLocation,
  }) : super(key: key);

  LatLng _parseCoordinates() {
    double lat = double.parse(earthquake.lintang.replaceAll(' LU', '').replaceAll(' LS', ''));
    if (earthquake.lintang.contains('LS')) lat = -lat;
    
    double lng = double.parse(earthquake.bujur.replaceAll(' BT', '').replaceAll(' BB', ''));
    if (earthquake.bujur.contains('BB')) lng = -lng;
    
    return LatLng(lat, lng);
  }

  @override
  Widget build(BuildContext context) {
    final coordinates = _parseCoordinates();
    
    return SizedBox(
      height: 300,
      child: FlutterMap(
        mapController: MapController(),
        options: MapOptions(
          initialCenter: coordinates,
          initialZoom: 6,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: coordinates,
                width: 80,
                height: 80,
                child: Icon(
                  Icons.location_on,
                  color: Colors.red[700],
                  size: 40,
                ),
              ),
              if (userLocation != null)
                Marker(
                  point: LatLng(userLocation!.latitude, userLocation!.longitude),
                  width: 80,
                  height: 80,
                  child: const Icon(
                    Icons.person_pin_circle,
                    color: Colors.blue,
                    size: 40,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
