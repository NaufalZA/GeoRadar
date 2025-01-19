import 'package:flutter/material.dart';
import '../models/earthquake.dart';
import '../models/earthquake_stats.dart';
import '../services/earthquake_service.dart';

class EarthquakeListScreen extends StatefulWidget {
  const EarthquakeListScreen({Key? key}) : super(key: key);

  @override
  State<EarthquakeListScreen> createState() => _EarthquakeListScreenState();
}

class _EarthquakeListScreenState extends State<EarthquakeListScreen> {
  final EarthquakeService _service = EarthquakeService();
  late Future<List<Earthquake>> _earthquakes;
  late Future<EarthquakeStats> _stats;

  @override
  void initState() {
    super.initState();
    _earthquakes = _service.getRecentEarthquakes();
    _stats = _service.getEarthquakeStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Gempa Dirasakan'),
        actions: [
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
                            Text('Kedalaman: ${quake.kedalaman}'),
                            if (quake.dirasakan.isNotEmpty)
                              Text('Dirasakan: ${quake.dirasakan}'),
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
