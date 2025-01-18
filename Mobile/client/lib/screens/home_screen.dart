import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/earthquake.dart';
import '../services/earthquake_service.dart';
import '../widgets/earthquake_map.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final EarthquakeService _service = EarthquakeService();
  late Future<List<Earthquake>> _earthquakes;
  bool _isLocationPermissionGranted = false;
  Position? _userLocation;
  final double _defaultLat = -6.89801698411407;
  final double _defaultLong = 107.63581353819215;

  @override
  void initState() {
    super.initState();
    _earthquakes = _service.getRecentEarthquakes();
    // Initialize with default location
    _userLocation = Position(
      latitude: _defaultLat,
      longitude: _defaultLong,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 0,  // Add this line
      headingAccuracy: 0, // Add this line
    );
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      await _checkLocationPermission();
      if (_isLocationPermissionGranted) {
        await _getCurrentLocation();
      } else {
        // Set default location (ITENAS) if permission not granted
        setState(() {
          _userLocation = Position(
            latitude: _defaultLat,
            longitude: _defaultLong,
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            heading: 0,
            speed: 0,
            speedAccuracy: 0,
            altitudeAccuracy: 0,  // Add this line
            headingAccuracy: 0, // Add this line
          );
        });
      }
    } catch (e) {
      debugPrint('Location initialization error: $e');
    }
  }

  Future<void> _checkLocationPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location services are disabled.')),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permissions are denied.')),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permissions are permanently denied.'),
            ),
          );
        }
        return;
      }

      setState(() {
        _isLocationPermissionGranted = true;
      });
    } catch (e) {
      debugPrint('Permission check error: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      ).then((Position position) {
        setState(() {
          _userLocation = position;
        });
      }).catchError((e) {
        debugPrint('Position error: $e');
      });
    } catch (e) {
      debugPrint('Error getting location: $e');
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
    
    // Check if using default location (ITENAS)
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
        title: const Text('GeoRadar'),
        actions: [
          if (!_isLocationPermissionGranted)
            IconButton(
              icon: const Icon(Icons.location_disabled),
              onPressed: () {
                _checkLocationPermission().then((_) {
                  if (_isLocationPermissionGranted) {
                    _getCurrentLocation();
                  }
                });
              },
              tooltip: 'Enable Location',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _earthquakes = _service.getRecentEarthquakes();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Earthquake>>(
        future: _earthquakes,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final latestQuake = snapshot.data!.first;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gempa Terkini',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                Card(
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: EarthquakeMap(earthquake: latestQuake),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Magnitude ${latestQuake.magnitude}',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              latestQuake.wilayah,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text('Waktu: ${latestQuake.tanggal} ${latestQuake.jam}'),
                            Text('Koordinat: ${latestQuake.lintang}, ${latestQuake.bujur}'),
                            Text('Kedalaman: ${latestQuake.kedalaman}'),
                            if (latestQuake.dirasakan.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Text(
                                'Dirasakan:',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(latestQuake.dirasakan),
                            ],
                            const SizedBox(height: 8),
                            Text(_getDistanceText(latestQuake)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
