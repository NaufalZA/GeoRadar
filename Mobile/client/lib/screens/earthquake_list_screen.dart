import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/earthquake.dart';
import '../models/earthquake_stats.dart';
import '../services/earthquake_service.dart';
import '../services/earthquake_alert_service.dart';
import '../utils/string_utils.dart';

class EarthquakeListScreen extends StatefulWidget {
  const EarthquakeListScreen({Key? key}) : super(key: key);

  @override
  State<EarthquakeListScreen> createState() => _EarthquakeListScreenState();
}

class _EarthquakeListScreenState extends State<EarthquakeListScreen> {
  final EarthquakeService _service = EarthquakeService();
  late Future<List<Earthquake>> _earthquakes;
  late Future<EarthquakeStats> _stats;
  bool _isLocationPermissionGranted = false;
  Position? _userLocation;
  final double _defaultLat = -6.89801698411407;
  final double _defaultLong = 107.63581353819215;

  @override
  void initState() {
    super.initState();
    _earthquakes = _service.getRecentEarthquakes();
    _stats = _service.getEarthquakeStats();
    _userLocation = Position(
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
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      Position position = await EarthquakeAlertService.getCurrentLocation();
      setState(() {
        _userLocation = position;
        _isLocationPermissionGranted = position.latitude != _defaultLat || 
                                     position.longitude != _defaultLong;
      });
    } catch (e) {
      debugPrint('Location initialization error: $e');
    }
  }

  String _getDistanceText(Earthquake earthquake) {
    String lat = earthquake.lintang.replaceAll('°', '').trim();
    double latitude = double.parse(lat.replaceAll(RegExp(r'[A-Za-z]'), ''));
    if (lat.contains('LS')) latitude *= -1;

    String lon = earthquake.bujur.replaceAll('°', '').trim();
    double longitude = double.parse(lon.replaceAll(RegExp(r'[A-Za-z]'), ''));

    double distanceInMeters = Geolocator.distanceBetween(
      _userLocation!.latitude,
      _userLocation!.longitude,
      latitude,
      longitude,
    );
    
    String locationLabel = _isLocationPermissionGranted ? 'lokasi kamu' : 'ITENAS';
    
    if (distanceInMeters >= 1000) {
      return '${(distanceInMeters / 1000).toStringAsFixed(1)} km dari $locationLabel';
    } else {
      return '${distanceInMeters.toStringAsFixed(0)} m dari $locationLabel';
    }
  }

  Widget _buildEarthquakeCard(Earthquake quake) {
    Color magnitudeColor = Colors.green;
    if (double.parse(quake.magnitude) >= 5.0) {
      magnitudeColor = Colors.red;
    } else if (double.parse(quake.magnitude) >= 4.0) {
      magnitudeColor = Colors.orange;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: magnitudeColor.withOpacity(0.2),
                border: Border.all(color: magnitudeColor, width: 2),
              ),
              child: Center(
                child: Text(
                  quake.magnitude,
                  style: TextStyle(
                    color: magnitudeColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatEarthquakeLocation(quake.wilayah),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_month_outlined, size: 16, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text(
                        '${quake.tanggal} ${quake.jam}'
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.explore_outlined, size: 16, color: Colors.red),
                      const SizedBox(width: 4),
                      Text(
                        _getDistanceText(quake),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gempa Dirasakan'),
        actions: [
          if (!_isLocationPermissionGranted)
            IconButton(
              icon: const Icon(Icons.location_disabled),
              onPressed: _initializeLocation,
              tooltip: 'Enable Location',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _earthquakes = _service.getRecentEarthquakes();
                _stats = _service.getEarthquakeStats();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          FutureBuilder<EarthquakeStats>(
            future: _stats,
            builder: (context, statsSnapshot) {
              if (statsSnapshot.hasData) {
                return Card(
                  margin: const EdgeInsets.all(12),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 247, 32, 32).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.radar_outlined,
                                color: Color.fromARGB(255, 247, 32, 32),
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              statsSnapshot.data!.averageMagnitude.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 247, 32, 32),
                              ),
                            ),
                            const Text(
                              'Rata-Rata',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const Text(
                              'Magnitudo',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          height: 80,
                          width: 1,
                          color: Colors.grey.withOpacity(0.3),
                        ),
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.waves_outlined,
                                color: Colors.blue,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${statsSnapshot.data!.averageDepth.toStringAsFixed(1)}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const Text(
                              'Rata-Rata',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const Text(
                              'Kedalaman',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          Expanded(
            child: FutureBuilder<List<Earthquake>>(
              future: _earthquakes,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading data'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return _buildEarthquakeCard(snapshot.data![index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
