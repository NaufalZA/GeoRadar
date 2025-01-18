import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DisasterListScreen extends StatefulWidget {
  const DisasterListScreen({Key? key}) : super(key: key);

  @override
  State<DisasterListScreen> createState() => _DisasterListScreenState();
}

class _DisasterListScreenState extends State<DisasterListScreen> {
  List<dynamic> disasters = [];

  @override
  void initState() {
    super.initState();
    fetchDisasters();
  }

  Future<void> fetchDisasters() async {
    final response = await http.get(Uri.parse('https://georadar.onrender.com/api/bencana'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      data.sort((a, b) {
        String dateStrA = a['tanggal'];
        String dateStrB = b['tanggal'];
        
        // Try parsing as regular date first
        try {
          DateTime dateA = DateFormat('dd-MM-yyyy').parse(dateStrA);
          DateTime dateB = DateFormat('dd-MM-yyyy').parse(dateStrB);
          return dateB.compareTo(dateA);
        } catch (e) {
          // If parsing fails, handle text descriptions
          if (dateStrA.contains('tahun lalu') && dateStrB.contains('tahun lalu')) {
            // Extract numbers from strings like "35 juta tahun lalu"
            int yearsA = int.tryParse(dateStrA.split(' ')[0]) ?? 0;
            int yearsB = int.tryParse(dateStrB.split(' ')[0]) ?? 0;
            return yearsB.compareTo(yearsA);
          }
          // Put numeric dates before text descriptions
          if (dateStrA.contains('tahun lalu')) return 1;
          if (dateStrB.contains('tahun lalu')) return -1;
          return 0;
        }
      });
      setState(() {
        disasters = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Bencana'),
      ),
      body: ListView.builder(
        itemCount: disasters.length,
        itemBuilder: (context, index) {
          final disaster = disasters[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              title: Text(
                disaster['nama'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${disaster['lokasi']}\n${disaster['tanggal']}',
              ),
              leading: const Icon(Icons.warning_amber_rounded),
              trailing: Text(
                disaster['kategori'],
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}
