import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/earthquake.dart';
import '../services/earthquake_service.dart';
import '../services/earthquake_alert_service.dart';
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
      await _checkLocationPermission();
      if (_isLocationPermissionGranted) {
        await _getCurrentLocation();
      } else {
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
      Position position = await EarthquakeAlertService.getCurrentLocation();
      setState(() {
        _userLocation = position;
        _isLocationPermissionGranted = position.latitude != _defaultLat || 
                                     position.longitude != _defaultLong;
      });
    } catch (e) {
      debugPrint('Error getting location: $e');
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
                        child: EarthquakeMap(
                          earthquake: latestQuake,
                          userLocation: _userLocation,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                // Magnitudo
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.graphic_eq, color: Colors.orange, size: 20),
                                        const SizedBox(width: 4),
                                        Text(
                                          latestQuake.magnitude,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Magnitudo',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                                // Kedalaman
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.arrow_downward, color: Colors.green, size: 20),
                                        const SizedBox(width: 4),
                                        Text(
                                          latestQuake.kedalaman,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Kedalaman',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                                // Koordinat
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.place, color: Colors.red, size: 20),
                                        const SizedBox(width: 4),
                                        Text(
                                          latestQuake.lintang,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      latestQuake.bujur,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 16),
                            // Waktu
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 24, color: Colors.grey),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Waktu',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${latestQuake.tanggal}, ${latestQuake.jam}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Lokasi
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 24, color: Colors.orange),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Lokasi Gempa',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        latestQuake.wilayah,
                                        style: const TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (latestQuake.dirasakan.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  const Icon(Icons.info, size: 24, color: Colors.blue),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Wilayah Dirasakan',
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          latestQuake.dirasakan,
                                          style: const TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Icon(Icons.directions, size: 24, color: Colors.green),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Jarak',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _getDistanceText(latestQuake),
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
