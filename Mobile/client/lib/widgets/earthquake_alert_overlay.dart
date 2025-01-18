import 'package:flutter/material.dart';

class EarthquakeAlertOverlay extends StatelessWidget {
  final Map<String, dynamic> earthquake;
  final VoidCallback onDismiss;

  const EarthquakeAlertOverlay({
    Key? key,
    required this.earthquake,
    required this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isFirebaseAlert = earthquake['isFirebaseAlert'] ?? false;

    return Material(
      color: isFirebaseAlert ? Colors.red.withOpacity(0.9) : Colors.orange.withOpacity(0.9),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 64,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            Text(
              isFirebaseAlert ? 'PERINGATAN DARURAT!' : 'PERINGATAN GEMPA BUMI!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Gempa bumi terdeteksi:\nMagnitude: ${earthquake['magnitude']}\nJarak: ${earthquake['distance'].toStringAsFixed(1)} km\nKedalaman: ${earthquake['depth']} km\n\n${earthquake['wilayah']}',
                style: const TextStyle(color: Colors.white, fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onDismiss,
              child: const Text('Tutup Peringatan'),
            ),
          ],
        ),
      ),
    );
  }
}
