// Lokasi File: lib/pages/detail_foto_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:project_akhir/models/photo_model.dart';
import 'package:project_akhir/services/koleksi_service.dart';
import 'package:project_akhir/services/unsplash_service.dart';

class DetailFotoPage extends StatefulWidget {
  final Photo photo;
  const DetailFotoPage({super.key, required this.photo});

  @override
  State<DetailFotoPage> createState() => _DetailFotoPageState();
}

class _DetailFotoPageState extends State<DetailFotoPage> {
  // --- Branding Colors ---
  static const Color primaryGreen = Color(0xFF2ECC71);
  static const Color primaryBlack = Color(0xFF1F1F1F);
  static const Color lightGrey = Color(0xFFF2F2F2);
  static const Color darkGrey = Color(0xFF6E6E6E);

  // --- State ---
  final KoleksiService _koleksiService = KoleksiService();
  final UnsplashService _unsplashService = UnsplashService(); // [BARU]
  bool _sudahDisimpan = false;
  bool _apakahAdaPerubahan = false;

  // State untuk Foto Serupa
  late Future<List<Photo>> _relatedPhotosFuture;

  @override
  void initState() {
    super.initState();
    _cekStatusFoto();
    
    _relatedPhotosFuture = _fetchRelatedPhotos(); 
  }

  void _cekStatusFoto() async {
    bool status = await _koleksiService.cekApakahSudahDisimpan(widget.photo.id);
    if (mounted) {
      setState(() {
        _sudahDisimpan = status;
      });
    }
  }

  // Fungsi untuk mengambil foto serupa
  Future<List<Photo>> _fetchRelatedPhotos() async {
    try {
      final photos = await _unsplashService.getRelatedPhotos(widget.photo.id);
      return photos;
    } catch (e) {
      
      return []; 
    }
  }

  void _toggleSimpan() async {
    if (_sudahDisimpan) {
      await _koleksiService.hapusFoto(widget.photo.id);
      _showSnackBar('Foto dihapus dari koleksi', isError: true);
    } else {
      await _koleksiService.simpanFoto(widget.photo);
      _showSnackBar('Foto disimpan ke koleksi', isError: false);
    }
    setState(() {
      _apakahAdaPerubahan = true;
    });
    _cekStatusFoto();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Kirim 'true' jika ada perubahan simpan/hapus
      onPopInvoked: (didPop) {
        if (didPop) return;
        Navigator.of(context).pop(_apakahAdaPerubahan);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: primaryBlack),
            onPressed: () {
              Navigator.of(context).pop(_apakahAdaPerubahan);
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Gambar Utama
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24.0),
                  child: Image.network(
                    widget.photo.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              
              // 2. Info Penulis & Tombol Simpan
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Info Penulis
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.photo.description.isNotEmpty)
                            Text(
                              widget.photo.description,
                              style: const TextStyle(
                                color: primaryBlack,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          Text(
                            'oleh ${widget.photo.creatorName}',
                            style: const TextStyle(color: darkGrey, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Tombol Simpan
                    ElevatedButton(
                      onPressed: _toggleSimpan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _sudahDisimpan ? primaryGreen : primaryBlack,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text(
                        _sudahDisimpan ? 'Tersimpan' : 'Simpan',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(color: lightGrey),

              // 3. Bagian Foto Serupa
              _buildRelatedPhotosGrid(),
            ],
          ),
        ),
      ),
    );
  }
  
  // [WIDGET BARU]
  Widget _buildRelatedPhotosGrid() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lainnya untuk dijelajahi',
            style: TextStyle(
              color: primaryBlack,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Gunakan FutureBuilder untuk menangani state loading/error/data
          FutureBuilder<List<Photo>>(
            future: _relatedPhotosFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: primaryGreen));
              }
              
              if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Tidak ada foto serupa.', style: TextStyle(color: darkGrey)));
              }

              final photos = snapshot.data!;

              // Gunakan StaggeredGrid agar rapi
              return MasonryGridView.count(
                physics: const NeverScrollableScrollPhysics(), // Non-scrollable
                shrinkWrap: true, // Agar menyatu dengan SingleChildScrollView
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                itemCount: photos.length,
                itemBuilder: (context, index) {
                  final photo = photos[index];
                  
                  return InkWell(
                    onTap: () {
                      // [PENTING] Navigasi ke Halaman Detail yang baru
                      // Ini akan 'menumpuk' halaman detail di atas halaman detail
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => DetailFotoPage(photo: photo),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: Image.network(
                            photo.imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                color: lightGrey,
                                height: 200 + (index % 2 * 100),
                                child: const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2, color: primaryGreen),
                                ),
                              );
                            },
                          ),
                        ),
                        if (photo.description.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0, left: 4.0, right: 4.0),
                            child: Text(
                              photo.description,
                              style: const TextStyle(color: primaryBlack, fontWeight: FontWeight.w600, fontSize: 14),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0, left: 4.0, right: 4.0, bottom: 8.0),
                          child: Text(
                            photo.creatorName,
                            style: const TextStyle(color: darkGrey, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}