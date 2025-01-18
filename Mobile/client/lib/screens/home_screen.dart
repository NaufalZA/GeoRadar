import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _earthquakes = _service.getRecentEarthquakes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GeoRadar'),
        actions: [
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
