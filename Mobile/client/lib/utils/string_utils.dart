String formatEarthquakeLocation(String location) {
  final regex = RegExp(r'pusat gempa berada di (laut|darat)\s*', caseSensitive: false);
  return location.replaceFirst(regex, '');
}
