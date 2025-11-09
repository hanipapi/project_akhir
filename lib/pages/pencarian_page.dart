// Lokasi File: lib/pages/pencarian_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:project_akhir/models/photo_model.dart';
import 'package:project_akhir/pages/detail_foto_page.dart';
import 'package:project_akhir/services/unsplash_service.dart';

class PencarianPage extends StatefulWidget {
  const PencarianPage({super.key});

  @override
  State<PencarianPage> createState() => _PencarianPageState();
}

class _PencarianPageState extends State<PencarianPage> {
  // --- Branding Colors ---
  static const Color primaryGreen = Color(0xFF2ECC71);
  static const Color primaryBlack = Color(0xFF1F1F1F);
  static const Color lightGrey = Color(0xFFF2F2F2);
  static const Color darkGrey = Color(0xFF6E6E6E);

  // --- State ---
  final UnsplashService _service = UnsplashService();
  final TextEditingController _searchController = TextEditingController();
  final PageController _pageController = PageController();

  List<Photo> _photos = []; // Untuk grid "Ide" atau "Hasil Pencarian"
  List<Photo> _carouselPhotos = []; // [BARU] Untuk carousel
  bool _isLoading = true; // Loading untuk grid
  bool _isLoadingCarousel = true; // [BARU] Loading untuk carousel
  bool _hasSearched = false;
  int _currentPageIndex = 0; // Untuk indikator carousel

  @override
  void initState() {
    super.initState();
    _fetchDiscoverPhotos(); // Panggil foto untuk grid "Ide"
    _fetchCarouselPhotos(); // [BARU] Panggil foto untuk carousel
  }

  // [BARU] Ambil foto untuk carousel
  Future<void> _fetchCarouselPhotos() async {
    setState(() {
      _isLoadingCarousel = true;
    });
    try {
     
      final results = await _service.getPopularPhotos(); 
      setState(() {
        _carouselPhotos = results;
        _isLoadingCarousel = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCarousel = false;
      }); // Gagal diam-diam
    }
  }

  // Ambil foto untuk "Ide yang mungkin Anda sukai"
  Future<void> _fetchDiscoverPhotos() async {
    setState(() {
      _isLoading = true;
      _hasSearched = false;
    });
    try {
      final results = await _service.getNewPhotos(1);
      setState(() {
        _photos = results;
        _isLoading = false;
      });
    } catch (e) {
      _showSnackBar('Gagal memuat ide. Cek koneksi Anda.', isError: true);
    }
  }

  // Fungsi untuk mencari
  Future<void> _doSearch() async {
    final query = _searchController.text;
    if (query.isEmpty) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _photos = [];
    });

    try {
      final results = await _service.searchPhotos(query, 1);
      setState(() {
        _photos = results;
        _isLoading = false;
      });
    } catch (e) {
      _showSnackBar('Gagal melakukan pencarian. Cek koneksi Anda.', isError: true);
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: _buildSearchBar(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // [MODIFIKASI] Tampilkan carousel HANYA jika tidak mencari
          if (!_hasSearched) ...[
            _buildSlideBar(), // Panggil carousel
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Text(
                'Ide yang mungkin Anda sukai',
                style: TextStyle(
                  color: primaryBlack,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          Expanded(
            child: _buildResultsBody(),
          ),
        ],
      ),
    );
  }

  // Widget Search Bar (Tidak berubah)
  Widget _buildSearchBar() {
    return Container(
      height: 48,
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: primaryBlack),
        decoration: InputDecoration(
          hintText: 'Cari ide...',
          hintStyle: TextStyle(color: darkGrey),
          prefixIcon: Icon(Icons.search, color: darkGrey),
          filled: true,
          fillColor: lightGrey,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(color: primaryGreen, width: 2),
          ),
        ),
        onSubmitted: (value) => _doSearch(),
      ),
    );
  }

  // [PEROMBAKAN TOTAL] Widget untuk "Slide Bar" (Carousel Foto)
  Widget _buildSlideBar() {
    if (_isLoadingCarousel) {
      return Container(
        height: 200,
        child: Center(child: CircularProgressIndicator(color: primaryGreen)),
      );
    }
    if (_carouselPhotos.isEmpty) {
      return const SizedBox.shrink(); // Jangan tampilkan jika API gagal
    }

    return Container(
      height: 200,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _carouselPhotos.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPageIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final photo = _carouselPhotos[index];
                // UI Carousel: Foto + Gradient + Teks
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24.0),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Gambar
                        Image.network(
                          photo.imageUrl,
                          fit: BoxFit.cover,
                        ),
                        // Gradient (Bayangan)
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.center,
                              colors: [
                                Colors.black.withOpacity(0.7),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        // Teks (Deskripsi Foto)
                        Positioned(
                          bottom: 20,
                          left: 20,
                          right: 20,
                          child: Text(
                            photo.description.isNotEmpty
                                ? photo.description
                                : "Inspirasi Hari Ini", // Fallback
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(blurRadius: 4.0, color: Colors.black54)
                                ]),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Indikator titik
          const SizedBox(height: 12.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_carouselPhotos.length, (index) {
              return Container(
                width: 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPageIndex == index ? primaryBlack : Colors.grey[300],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // Widget Grid Hasil (Tidak berubah)
  Widget _buildResultsBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: primaryGreen));
    }
    if (_photos.isEmpty) {
      return Center(
        child: Text(
          _hasSearched
              ? 'Tidak ada hasil yang ditemukan.'
              : 'Tidak ada ide untuk ditampilkan.',
          style: TextStyle(color: darkGrey),
        ),
      );
    }
    // Tampilkan Grid
    return MasonryGridView.count(
      padding: const EdgeInsets.all(8.0),
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      itemCount: _photos.length,
      itemBuilder: (context, index) {
        final photo = _photos[index];
        // UI Item (Sama seperti Beranda)
        return InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => DetailFotoPage(photo: photo)),
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
                      child: Center(
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
                    style: TextStyle(color: primaryBlack, fontWeight: FontWeight.w600, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 2.0, left: 4.0, right: 4.0, bottom: 8.0),
                child: Text(
                  photo.creatorName,
                  style: TextStyle(color: darkGrey, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}