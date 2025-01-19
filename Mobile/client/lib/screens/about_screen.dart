import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  void _launchURL(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch URL')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to open URL')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'GeoRadar',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Developed by:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            const Text('Naufal Zaidan Agista - 152022168'),
            const Text('Daffa Faris - 152022000'),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.youtube_searched_for),
                  onPressed: () => _launchURL(context, 'https://www.youtube.com/watch?v=nn3NB5IRiDg'),
                  tooltip: 'Watch on YouTube',
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.code),
                  onPressed: () => _launchURL(context, 'https://github.com/NaufalZA/GeoRadar'),
                  tooltip: 'View on GitHub',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
