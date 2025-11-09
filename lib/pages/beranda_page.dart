// Lokasi File: lib/pages/beranda_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:project_akhir/models/photo_model.dart';
import 'package:project_akhir/pages/detail_foto_page.dart';
import 'package:project_akhir/services/unsplash_service.dart';

class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  // [BARU] Definisikan warna branding
  static const Color primaryGreen = Color(0xFF2ECC71);
  static const Color primaryBlack = Color(0xFF1F1F1F);
  static const Color darkGrey = Color(0xFF6E6E6E);

  final UnsplashService _unsplashService = UnsplashService();
  List<Photo> _photos = [];
  bool _isLoading = true;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _fetchPhotos();
  }

  Future<void> _fetchPhotos() async {
    if (_currentPage == 1) {
      setState(() { _isLoading = true; });
    }
    try {
      final newPhotos = await _unsplashService.getNewPhotos(_currentPage);
      setState(() {
        _isLoading = false;
        _photos.addAll(newPhotos);
        _currentPage++;
      });
    } catch (e) {
      setState(() { _isLoading = false; });
      _showSnackBar('Gagal memuat foto. Cek koneksi Anda.', isError: true);
    }
  }
  
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // [UI DIUBAH]
    return Scaffold(
      backgroundColor: Colors.white, // Latar belakang putih
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // Hilangkan bayangan
        title: Text(
          'ideaspark',
          style: TextStyle(
            color: primaryBlack, // Teks hitam
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: primaryBlack),
            onPressed: () {
              // Nanti bisa dihubungkan ke halaman notifikasi
            },
          )
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryGreen))
          : RefreshIndicator(
              color: primaryGreen,
              onRefresh: () async {
                setState(() {
                  _photos = [];
                  _currentPage = 1;
                });
                await _fetchPhotos();
              },
              child: MasonryGridView.count(
                padding: const EdgeInsets.all(8.0),
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                itemCount: _photos.length,
                itemBuilder: (context, index) {
                  final photo = _photos[index];
                  
                  // [UI ITEM DIUBAH]
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => DetailFotoPage(photo: photo),
                        ),
                      );
                    },
                    // Kita gunakan Column, bukan Stack lagi
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Gambar dengan sudut melengkung
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: Image.network(
                            photo.imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                color: Colors.grey[200],
                                height: 200 + (index % 2 * 100),
                                child: const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2, color: primaryGreen),
                                ),
                              );
                            },
                          ),
                        ),
                        
                        // 2. Teks (Nama Foto / Deskripsi)
                        if (photo.description.isNotEmpty) // Hanya tampilkan jika ada
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0, left: 4.0, right: 4.0),
                            child: Text(
                              photo.description,
                              style: TextStyle(
                                color: primaryBlack,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        
                        // 3. Teks (Penulis)
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0, left: 4.0, right: 4.0, bottom: 8.0),
                          child: Text(
                            photo.creatorName,
                            style: TextStyle(
                              color: darkGrey,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}