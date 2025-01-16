class Disaster {
  final String kategori;
  final String nama;
  final String? lokasi;
  final String? deskripsi;
  final String tanggal;

  Disaster({
    required this.kategori,
    required this.nama,
    this.lokasi,
    this.deskripsi,
    required this.tanggal,
  });

  factory Disaster.fromJson(Map<String, dynamic> json) {
    return Disaster(
      kategori: json['kategori'] ?? '',
      nama: json['nama'] ?? '',
      lokasi: json['lokasi'],
      deskripsi: json['deskripsi'],
      tanggal: json['tanggal'] ?? '',
    );
  }
}
