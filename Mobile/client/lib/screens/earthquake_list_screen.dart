import 'package:flutter/material.dart';
import '../models/earthquake.dart';
import '../services/earthquake_service.dart';

class EarthquakeListScreen extends StatefulWidget {
  const EarthquakeListScreen({Key? key}) : super(key: key);

  @override
  State<EarthquakeListScreen> createState() => _EarthquakeListScreenState();
}

class _EarthquakeListScreenState extends State<EarthquakeListScreen> {
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
        title: const Text('Daftar Gempa Dirasakan'),
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
    );
  }
}
