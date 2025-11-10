// Lokasi File: lib/pages/koleksi_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:project_akhir/models/photo_model.dart';
import 'package:project_akhir/pages/detail_foto_page.dart';
import 'package:project_akhir/services/koleksi_service.dart';

class KoleksiPage extends StatefulWidget {
  const KoleksiPage({super.key});

  @override
  State<KoleksiPage> createState() => _KoleksiPageState();
}

class _KoleksiPageState extends State<KoleksiPage> {
  // --- Branding Colors ---
  static const Color primaryGreen = Color(0xFF2ECC71);
  static const Color primaryBlack = Color(0xFF1F1F1F);
  static const Color lightGrey = Color(0xFFF2F2F2);
  static const Color darkGrey = Color(0xFF6E6E6E);

  final KoleksiService _koleksiService = KoleksiService();
  
  bool _isLoading = true;
  List<Photo> _koleksiFoto = [];

  @override
  void initState() {
    super.initState();
    // 2. Ambil data saat halaman pertama kali dibuka
    _loadKoleksi();
  }

  // 3. Buat fungsi untuk mengambil data
  Future<void> _loadKoleksi() async {
    setState(() {
      _isLoading = true;
    });
    
    final foto = await _koleksiService.getKoleksi();
    
    setState(() {
      _koleksiFoto = foto;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: Colors.white,
      // Kita gunakan NestedScrollView agar search bar bisa scroll bersama grid
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          // Bagian atas halaman (Search, Filter, Title)
          return <Widget>[
            SliverAppBar(
              backgroundColor: Colors.white,
              floating: true, // AppBar akan muncul saat scroll ke atas
              pinned: false,
              elevation: 0,
              automaticallyImplyLeading: false, // Hilangkan tombol back
              
              // Search Bar
              title: Container(
                height: 48,
                child: TextField(
                  readOnly: true, // Kita buat dummy dulu
                  decoration: InputDecoration(
                    hintText: 'Cari Pin Anda...',
                    hintStyle: TextStyle(color: darkGrey),
                    prefixIcon: Icon(Icons.search, color: darkGrey),
                    filled: true,
                    fillColor: lightGrey,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
            
            // Filter Buttons
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    _buildFilterChip('Favorit', true), // "Favorit" aktif
                    const SizedBox(width: 8),
                    _buildFilterChip('Dibuat oleh Anda', false), // (dummy)
                  ],
                ),
              ),
            ),
            
            // Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Text(
                  'Pin yang Anda simpan',
                  style: TextStyle(
                    color: primaryBlack,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ];
        },
        // Bagian body (Grid Foto)
        body: _isLoading
            ? Center(child: CircularProgressIndicator(color: primaryGreen))
            : _koleksiFoto.isEmpty
                ? _buildEmptyState()
                : _buildGrid(),
      ),
    );
  }

  // Helper untuk tombol filter
  Widget _buildFilterChip(String label, bool isActive) {
    return FilterChip(
      label: Text(label),
      selected: isActive,
      onSelected: (bool selected) {
        // Logika filter bisa ditambahkan di sini nanti (next aja)
      },
      backgroundColor: lightGrey,
      selectedColor: primaryBlack,
      labelStyle: TextStyle(color: isActive ? Colors.white : primaryBlack),
      showCheckmark: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
        side: BorderSide(color: Colors.transparent),
      ),
    );
  }
  
  // Helper untuk state kosong
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.collections_bookmark_outlined, size: 80, color: darkGrey),
            const SizedBox(height: 16),
            Text(
              'Anda belum menyimpan ide apapun',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: primaryBlack,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ide yang Anda simpan akan muncul di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(color: darkGrey, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  //Grid dipisah ke widget helper
  Widget _buildGrid() {
    return RefreshIndicator(
      color: primaryGreen,
      onRefresh: _loadKoleksi,
      child: MasonryGridView.count(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        itemCount: _koleksiFoto.length,
        itemBuilder: (context, index) {
          final photo = _koleksiFoto[index];
          // UI Item (Sama seperti Beranda)
          return InkWell(
            onTap: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => DetailFotoPage(photo: photo),
                ),
              );
              if (result == true && mounted) {
                _loadKoleksi();
              }
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
      ),
    );
  }
}