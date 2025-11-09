// Lokasi File: lib/models/photo_model.dart

class Photo {
  final String id;
  final String imageUrl;
  final String creatorName;
  final String description; // <-- [BARU] Tambahkan field deskripsi

  Photo({
    required this.id,
    required this.imageUrl,
    required this.creatorName,
    required this.description, // <-- [BARU] Tambahkan di constructor
  });

  // Constructor 1: Untuk membaca dari API Unsplash
  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'],
      imageUrl: json['urls']['regular'],
      creatorName: json['user']['name'] ?? 'Unknown Creator',
      // [DIUBAH] Ambil deskripsi. Gunakan alt_description jika deskripsi null
      description: json['alt_description'] ?? json['description'] ?? '',
    );
  }

  // Constructor 2: Untuk membaca dari database Hive
  factory Photo.fromHiveMap(Map<dynamic, dynamic> map) {
    return Photo(
      id: map['id'],
      imageUrl: map['imageUrl'],
      creatorName: map['creatorName'],
      // [DIUBAH] Ambil deskripsi dari Hive
      description: map['description'] ?? '',
    );
  }
}