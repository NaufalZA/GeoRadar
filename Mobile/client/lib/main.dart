import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/earthquake_list_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/disaster_list_screen.dart';
import 'services/earthquake_alert_service.dart';
import 'widgets/earthquake_alert_overlay.dart';
import 'services/earthquake_service.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GeoRadar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  bool _showAlert = false;
  Map<String, dynamic>? _latestEarthquake;
  final EarthquakeService _earthquakeService = EarthquakeService();
  StreamSubscription? _alertSubscription;
  
  @override
  void initState() {
    super.initState();
    _selectedIndex = 0; // Ensure initial index is valid
    _checkForNearbyEarthquakes();
    _subscribeToAlertStatus();
  }

  void _subscribeToAlertStatus() {
    debugPrint('Initializing Alert status subscription');
    _alertSubscription = EarthquakeAlertService.getAlertStatus().listen(
      (showAlert) {
        debugPrint('Received alert status from Firebase: $showAlert');
        if (showAlert) {
          _checkForNearbyEarthquakes();
        } else {
          setState(() {
            _showAlert = false;
          });
        }
      },
      onError: (error) {
        debugPrint('Error in alert subscription: $error');
      }
    );
  }

  @override
  void dispose() {
    _alertSubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkForNearbyEarthquakes() async {
    debugPrint('Checking for nearby earthquakes...');
    final position = await EarthquakeAlertService.getCurrentLocation();
    if (position == null) {
      debugPrint('Failed to get current location');
      return;
    }

    try {
      final earthquakes = await _earthquakeService.getRecentEarthquakes();
      if (earthquakes.isEmpty) {
        debugPrint('No earthquakes data available');
        return;
      }

      final latestEarthquake = earthquakes.first;
      
      // Convert coordinates to double
      String lat = latestEarthquake.lintang.replaceAll('°', '').trim();
      double latitude = double.parse(lat.replaceAll(RegExp(r'[A-Za-z]'), ''));
      if (lat.contains('LS')) latitude *= -1;

      String lon = latestEarthquake.bujur.replaceAll('°', '').trim();
      double longitude = double.parse(lon.replaceAll(RegExp(r'[A-Za-z]'), ''));

      final distance = EarthquakeAlertService.calculateDistance(
        position.latitude,
        position.longitude,
        latitude,
        longitude,
      );

      if (distance <= EarthquakeAlertService.ALERT_RADIUS_KM) {
        setState(() {
          _showAlert = true;
          _latestEarthquake = {
            'magnitude': latestEarthquake.magnitude,
            'depth': double.parse(latestEarthquake.kedalaman.replaceAll(RegExp(r'[^0-9.]'), '')),
            'distance': distance,
            'wilayah': latestEarthquake.wilayah,
          };
        });
        debugPrint('Alert overlay activated with earthquake data');
      }
    } catch (e) {
      debugPrint('Error checking nearby earthquakes: $e');
    }
  }

  void _dismissAlert() {
    setState(() {
      _showAlert = false;
    });
  }

  static final List<Widget> _screens = [
    const HomeScreen(),
    const EarthquakeListScreen(),
    const DisasterListScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    if (index >= 0 && index < _screens.length) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: IndexedStack(
            index: _selectedIndex,
            children: _screens,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.list),
                label: 'Daftar Gempa',
              ),
              NavigationDestination(
                icon: Icon(Icons.warning_amber_rounded),
                label: 'Bencana',
              ),
              NavigationDestination(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
        if (_showAlert && _latestEarthquake != null)
          EarthquakeAlertOverlay(
            earthquake: _latestEarthquake!,
            onDismiss: _dismissAlert,
          ),
      ],
    );
  }
}
