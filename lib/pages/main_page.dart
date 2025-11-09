// Lokasi File: lib/pages/main_page.dart
import 'package:flutter/material.dart';
import 'package:project_akhir/pages/beranda_page.dart';
// [INI BAGIAN PENTING] Pastikan import ini ada
import 'package:project_akhir/pages/koleksi_page.dart';
import 'package:project_akhir/pages/pencarian_page.dart';
import 'package:project_akhir/pages/profil_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // --- Branding Colors ---
  static const Color primaryGreen = Color(0xFF2ECC71);
  static const Color primaryBlack = Color(0xFF1F1F1F);
  static const Color darkGrey = Color(0xFF6E6E6E);

  // Variabel untuk menyimpan indeks tab yang sedang aktif
  int _selectedIndex = 0;

  // Daftar halaman yang akan ditampilkan sesuai tab
  static const List<Widget> _pages = <Widget>[
    BerandaPage(),
    PencarianPage(),
    KoleksiPage(), // <-- Ini yang menyebabkan error jika import tidak ada
    ProfilPage(),
  ];

  // Fungsi untuk mengubah tab
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Cari',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.collections_bookmark_outlined),
            activeIcon: Icon(Icons.collections_bookmark),
            label: 'Koleksi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: primaryBlack,
        unselectedItemColor: darkGrey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 1.0,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }
}
