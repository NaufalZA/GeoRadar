class EarthquakeStats {
  final double averageMagnitude;
  final double averageDepth;

  EarthquakeStats({
    required this.averageMagnitude,
    required this.averageDepth,
  });

  factory EarthquakeStats.fromJson(Map<String, dynamic> json) {
    return EarthquakeStats(
      averageMagnitude: double.parse(json['averageMagnitude']),
      averageDepth: double.parse(json['averageDepth'].toString().replaceAll(' km', '')),
    );
  }
}
