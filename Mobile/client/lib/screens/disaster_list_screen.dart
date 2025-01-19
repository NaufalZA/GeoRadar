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
    // final response = await http.get(Uri.parse('https://georadar.onrender.com/api/bencana'));
    final response = await http.get(Uri.parse('http://10.0.2.2:3000/api/bencana'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      data.sort((a, b) {
        String dateStrA = a['tanggal'];
        String dateStrB = b['tanggal'];
                
        try {
          DateTime dateA = DateFormat('dd-MM-yyyy').parse(dateStrA);
          DateTime dateB = DateFormat('dd-MM-yyyy').parse(dateStrB);
          return dateB.compareTo(dateA);
        } catch (e) {
          
          bool isYearsAgoA = dateStrA.contains('tahun lalu');
          bool isYearsAgoB = dateStrB.contains('tahun lalu');
                    
          if (isYearsAgoA && isYearsAgoB) {
            int yearsA = extractYears(dateStrA);
            int yearsB = extractYears(dateStrB);
            return yearsA.compareTo(yearsB); 
          }
                    
          if (isYearsAgoA) return 1;
          if (isYearsAgoB) return -1;
          return 0;
        }
      });
      setState(() {
        disasters = data;
      });
    }
  }

  int extractYears(String dateStr) {
    final numbers = dateStr.replaceAll(RegExp(r'[^0-9]'), '');
    final value = int.tryParse(numbers) ?? 0;
    
    if (dateStr.contains('juta')) {
      return value * 1000000;
    } else {
      return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hari Pasca Bencana'),
      ),
      body: ListView.builder(
        itemCount: disasters.length,
        itemBuilder: (context, index) {
          final disaster = disasters[index];
          
          // Format days display
          String daysDisplay = '';
          int days = disaster['hari'];
          daysDisplay = '$days hari';
          
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              title: Text(
                'Hari Pasca ${disaster['kategori']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    daysDisplay,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  Text(
                    'Terakhir: ${disaster['nama']} di ${disaster['lokasi']}, pada ${disaster['tanggal']}',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
