import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/earthquake.dart';
import '../services/earthquake_service.dart';
import '../services/earthquake_alert_service.dart';  // Add this import
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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _earthquakes = _service.getRecentEarthquakes();
    _initializeLocation().then((_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _initializeLocation() async {
    try {
      debugPrint('Initializing location...');
      await _checkLocationPermission();
      debugPrint('Permission granted: $_isLocationPermissionGranted');
      
      if (_isLocationPermissionGranted) {
        await _getCurrentLocation();
      } else {
        _setDefaultLocation();
      }
    } catch (e) {
      debugPrint('Location initialization error: $e');
      _setDefaultLocation();
    }
  }

  void _setDefaultLocation() {
    debugPrint('Setting default location (ITENAS)');
    if (mounted) {
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
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
        _isLocationPermissionGranted = false;
      });
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
      debugPrint('Getting current location...');
      final position = await EarthquakeAlertService.getCurrentLocation();
      
      if (mounted) {
        setState(() {
          _userLocation = position;
          _isLocationPermissionGranted = position.latitude != _defaultLat || 
                                       position.longitude != _defaultLong;
        });
      }
      debugPrint('Location set to: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      debugPrint('Error getting location: $e');
      _setDefaultLocation();
    }
  }

  String _getDistanceText(Earthquake earthquake) {
    if (_userLocation == null) return '';
    
    try {
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
    } catch (e) {
      debugPrint('Error calculating distance: $e');
      return '';
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
                        child: _isLoading 
                          ? const SizedBox(
                              height: 300,
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : EarthquakeMap(
                              earthquake: latestQuake,
                              userLocation: _userLocation,
                            ),
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
                            _isLoading 
                              ? const Text('Menghitung jarak...')
                              : Text(_getDistanceText(latestQuake)),
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
