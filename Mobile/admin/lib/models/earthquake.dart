class Earthquake {
  final String tanggal;
  final String jam;
  final String dateTime;
  final String coordinates;
  final String lintang;
  final String bujur;
  final String magnitude;
  final String kedalaman;
  final String wilayah;
  final String dirasakan;

  Earthquake({
    required this.tanggal,
    required this.jam,
    required this.dateTime,
    required this.coordinates,
    required this.lintang,
    required this.bujur,
    required this.magnitude,
    required this.kedalaman,
    required this.wilayah,
    required this.dirasakan,
  });

  factory Earthquake.fromJson(Map<String, dynamic> json) {
    return Earthquake(
      tanggal: json['Tanggal'],
      jam: json['Jam'],
      dateTime: json['DateTime'],
      coordinates: json['Coordinates'],
      lintang: json['Lintang'],
      bujur: json['Bujur'],
      magnitude: json['Magnitude'],
      kedalaman: json['Kedalaman'],
      wilayah: json['Wilayah'],
      dirasakan: json['Dirasakan'],
    );
  }
}
