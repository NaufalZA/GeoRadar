import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/earthquake.dart';
import '../models/earthquake_stats.dart';
import '../services/earthquake_service.dart';
import '../services/earthquake_alert_service.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Gempa Dirasakan'),
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
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text('Rata-rata Magnitudo'),
                            Text(
                              statsSnapshot.data!.averageMagnitude.toStringAsFixed(2),
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('Rata-rata Kedalaman'),
                            Text(
                              '${statsSnapshot.data!.averageDepth.toStringAsFixed(2)} km',
                              style: Theme.of(context).textTheme.titleLarge,
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
                    final quake = snapshot.data![index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text('M${quake.magnitude} - ${quake.wilayah}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${quake.tanggal} ${quake.jam}'),
                            Text(_getDistanceText(quake)),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
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
