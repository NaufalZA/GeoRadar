import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../models/earthquake.dart';

class EarthquakeMap extends StatefulWidget {
  final Earthquake earthquake;
  final Position? userLocation;

  const EarthquakeMap({
    Key? key, 
    required this.earthquake,
    this.userLocation,
  }) : super(key: key);

  @override
  State<EarthquakeMap> createState() => _EarthquakeMapState();
}

class _EarthquakeMapState extends State<EarthquakeMap> {
  late final MapController _mapController;
  
  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(EarthquakeMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userLocation != widget.userLocation) {
      final quakeLocation = _parseCoordinates();
      final center = _calculateCenter(quakeLocation);
      final zoom = _calculateZoom(quakeLocation);
      
      debugPrint('Location changed, updating map center to: ${center.latitude}, ${center.longitude}');
      _mapController.move(center, zoom);
    }
  }

  LatLng _parseCoordinates() {
    double lat = double.parse(widget.earthquake.lintang.replaceAll(' LU', '').replaceAll(' LS', ''));
    if (widget.earthquake.lintang.contains('LS')) lat = -lat;
    
    double lng = double.parse(widget.earthquake.bujur.replaceAll(' BT', '').replaceAll(' BB', ''));
    if (widget.earthquake.bujur.contains('BB')) lng = -lng;
    
    return LatLng(lat, lng);
  }

  LatLng _calculateCenter(LatLng quakeLocation) {
    if (widget.userLocation == null) return quakeLocation;
    
    return LatLng(
      (quakeLocation.latitude + widget.userLocation!.latitude) / 2,
      (quakeLocation.longitude + widget.userLocation!.longitude) / 2,
    );
  }

  double _calculateZoom(LatLng quakeLocation) {
    if (widget.userLocation == null) return 6;

    // Calculate distance between points
    final distance = Geolocator.distanceBetween(
      quakeLocation.latitude,
      quakeLocation.longitude,
      widget.userLocation!.latitude,
      widget.userLocation!.longitude,
    );

    // Adjust zoom based on distance (in kilometers)
    if (distance < 100000) return 8; // Less than 100km
    if (distance < 500000) return 7; // Less than 500km
    if (distance < 1000000) return 6; // Less than 1000km
    return 4; // For very large distances
  }

  @override
  Widget build(BuildContext context) {
    final quakeLocation = _parseCoordinates();
    final center = _calculateCenter(quakeLocation);
    final zoom = _calculateZoom(quakeLocation);
    
    return SizedBox(
      height: 300,
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: center,
          initialZoom: zoom,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all,
          ),
          minZoom: 3,
          maxZoom: 18,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
            maxZoom: 18,
            minZoom: 3,
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: quakeLocation,
                width: 80,
                height: 80,
                child: Icon(
                  Icons.location_on,
                  color: Colors.red[700],
                  size: 40,
                ),
              ),
              if (widget.userLocation != null)
                Marker(
                  point: LatLng(widget.userLocation!.latitude, widget.userLocation!.longitude),
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
