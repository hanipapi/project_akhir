// Lokasi File: lib/pages/toolkit_page.dart

import 'auth_page.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:dart_suncalc/suncalc.dart';
import 'package:intl/intl.dart';

class ToolkitPage extends StatefulWidget {
  const ToolkitPage({super.key});

  @override
  State<ToolkitPage> createState() => _ToolkitPageState();
}

class _ToolkitPageState extends State<ToolkitPage> {
  // --- Branding Colors ---
  static const Color primaryGreen = Color(0xFF2ECC71);
  static const Color primaryBlack = Color(0xFF1F1F1F);
  static const Color lightGrey = Color(0xFFF2F2F2);
  static const Color darkGrey = Color(0xFF6E6E6E);

  // --- State untuk Golden Hour ---
  bool _isLoadingLocation = true;
  String _locationStatus = 'Mencari lokasi...';
  String _sunriseTime = '...';
  String _goldenHourTime = '...';
  String _sunsetTime = '...';
  String _goldenHourDuskTime = '...';
  final DateFormat _timeFormat = DateFormat('HH:mm');

  // --- State untuk Palet Warna ---
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  List<Color> _paletteColors = [];
  bool _isLoadingPalette = false;

  @override
  void initState() {
    super.initState();
    _initLocation(); // Panggil logika LBS
  }

  // --- 1. Logika Kalkulator Golden Hour ---
  Future<void> _initLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    setState(() { _isLoadingLocation = true; });

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() { _locationStatus = 'Servis lokasi mati'; _isLoadingLocation = false; });
      return;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() { _locationStatus = 'Izin lokasi ditolak'; _isLoadingLocation = false; });
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      setState(() { _locationStatus = 'Izin ditolak permanen'; _isLoadingLocation = false; });
      return;
    }

    // Jika semua OK, ambil lokasi & hitung jam
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
      
      // [PERBAIKAN 2] Panggil SunCalc dengan parameter 'lat:' dan 'lng:'
      var times = SunCalc.getTimes(
        DateTime.now(), 
        lat: position.latitude, 
        lng: position.longitude
      );
      
      setState(() {
        // [PERBAIKAN 3] Tambahkan 'null check' (!) karena datanya nullable
        _sunriseTime = _timeFormat.format(times.sunrise!.toLocal());
        _goldenHourTime = _timeFormat.format(times.goldenHourEnd!.toLocal());
        _sunsetTime = _timeFormat.format(times.sunset!.toLocal());
        _goldenHourDuskTime = _timeFormat.format(times.goldenHour!.toLocal());
        _locationStatus = 'Lokasi Ditemukan';
        _isLoadingLocation = false;
      });

    } catch (e) {
      print('Error calculating sun times: $e');
      setState(() { _locationStatus = 'Gagal kalkulasi data LBS'; _isLoadingLocation = false; });
    }
  }

  // --- 2. Logika Ekstraktor Palet Warna ---
  Future<void> _pickImageAndExtractPalette() async {
    setState(() { _isLoadingPalette = true; _imageFile = null; _paletteColors = []; });
    
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      setState(() { _isLoadingPalette = false; });
      return; // User membatalkan
    }
    
    final File file = File(image.path);
    
    // Generate palet
    final PaletteGenerator palette = await PaletteGenerator.fromImageProvider(
      FileImage(file),
      size: const Size(200, 200), // Ukuran sampling
      maximumColorCount: 6, // Ambil 6 warna
    );
    
    setState(() {
      _imageFile = file;
      _paletteColors = palette.colors.toList();
      _isLoadingPalette = false;
    });
  }

  // --- 3. UI (Build Method) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Creative Toolkit', style: TextStyle(color: primaryBlack)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: primaryBlack),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- Bagian 1: Kalkulator Golden Hour ---
          _buildGroupHeader('Fotografi'),
          Card(
            elevation: 0,
            color: lightGrey,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kalkulator Golden Hour',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryBlack),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isLoadingLocation ? _locationStatus : 'Berhasil: Menampilkan data untuk lokasi Anda',
                    style: TextStyle(color: _isLoadingLocation ? Colors.orange[700] : primaryGreen),
                  ),
                  const Divider(height: 24),
                  
                  // Tampilkan hasil
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildTimeInfo(Icons.wb_sunny_outlined, 'Sunrise', _sunriseTime, primaryGreen),
                      _buildTimeInfo(Icons.wb_sunny, 'Golden Hour', _goldenHourTime, primaryGreen),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildTimeInfo(Icons.dark_mode_outlined, 'Sunset', _sunsetTime, darkGrey),
                      _buildTimeInfo(Icons.dark_mode, 'Blue Hour', _goldenHourDuskTime, darkGrey),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // --- Bagian 2: Ekstraktor Palet Warna ---
          _buildGroupHeader('Inspirasi'),
          Card(
            elevation: 0,
            color: lightGrey,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Ekstraktor Palet Warna',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryBlack),
                  ),
                  const SizedBox(height: 16),
                  
                  // Tampilkan gambar & palet
                  if (_isLoadingPalette)
                    const Center(child: CircularProgressIndicator(color: primaryGreen)),
                  
                  if (_imageFile != null && _paletteColors.isNotEmpty)
                    Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: Image.file(_imageFile!, height: 200, fit: BoxFit.cover),
                        ),
                        const SizedBox(height: 16),
                        // Tampilkan Palet
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: _paletteColors.map((color) {
                            return Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.black26, width: 0.5)
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    
                  if (_imageFile == null && !_isLoadingPalette)
                    const Center(child: Text('Pilih gambar untuk melihat palet warnanya.', style: TextStyle(color: darkGrey))),

                  const SizedBox(height: 16),
                  
                  // Tombol Aksi
                  ElevatedButton.icon(
                    onPressed: _pickImageAndExtractPalette,
                    icon: const Icon(Icons.image_outlined),
                    label: Text(_imageFile == null ? 'Pilih Gambar' : 'Pilih Gambar Lain'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlack,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper untuk UI Jam
  Widget _buildTimeInfo(IconData icon, String label, String time, Color iconColor) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 30),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: darkGrey, fontSize: 12)),
        Text(
          _isLoadingLocation ? '--:--' : time,
          style: const TextStyle(color: primaryBlack, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // Helper untuk UI Judul Grup
  Widget _buildGroupHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, top: 16.0, bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: darkGrey,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}