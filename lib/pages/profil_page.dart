// Lokasi File: lib/pages/profil_page.dart

import 'package:flutter/material.dart';
import 'package:project_akhir/pages/auth_page.dart';
import 'package:project_akhir/pages/toolkit_page.dart';
import 'package:project_akhir/services/auth_service.dart';
import 'package:project_akhir/services/saran_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  // --- Branding Colors ---
  static const Color primaryGreen = Color(0xFF2ECC71);
  static const Color primaryBlack = Color(0xFF1F1F1F);
  static const Color lightGrey = Color(0xFFF2F2F2);
  static const Color darkGrey = Color(0xFF6E6E6E);

  // --- State ---
  final AuthService _authService = AuthService();
  final SaranService _saranService = SaranService();
  String _username = "Memuat...";
  String _email = "Memuat...";
  final TextEditingController _saranController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await _authService.getCurrentUser();
    if (user != null) {
      setState(() {
        _username = user['username'];
        _email = user['email'];
      });
    }
  }

  Future<void> _kirimSaran() async {
    final saran = _saranController.text;
    if (saran.isEmpty) {
      _showSnackBar('Saran tidak boleh kosong.', isError: true);
      return;
    }
    FocusScope.of(context).unfocus();
    try {
      await _saranService.simpanSaran(saran);
      _saranController.clear();
      _showSnackBar('Saran Anda telah terkirim. Terima kasih!', isError: false);
    } catch (e) {
      _showSnackBar('Gagal mengirim saran.', isError: true);
    }
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('currentUserEmail');
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AuthPage()),
    );
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Akun Anda',
          style: TextStyle(color: primaryBlack, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          // --- 1. Bagian Info User ---
          ListTile(
            leading: CircleAvatar(
              radius: 30,
              backgroundColor: lightGrey,
              child: Icon(Icons.person, size: 30, color: darkGrey),
            ),
            title: Text(
              _username,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: primaryBlack,
              ),
            ),
            subtitle: Text(
              _email,
              style: const TextStyle(color: darkGrey),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          
          // --- 2. Grup Toolkit ---
          _buildGroupHeader('Toolkit'),
          ListTile(
            leading: const Icon(Icons.construction_outlined, color: primaryBlack),
            title: const Text('Creative Toolkit'),
            subtitle: const Text('Kalkulator Golden Hour & Palet'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ToolkitPage()),
              );
            },
          ),
          
          
          // --- 3. Grup Saran & Kesan ---
          _buildGroupHeader('Masukan'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _saranController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Tulis masukan Anda untuk aplikasi ini...',
                filled: true,
                fillColor: lightGrey,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: _kirimSaran,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: const Text('Kirim Saran'),
            ),
          ),
          
          const SizedBox(height: 24),

          // --- 4. Tombol Logout ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: () => _logout(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[50],
                foregroundColor: Colors.red[700],
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // Helper untuk judul grup
  Widget _buildGroupHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 24.0, bottom: 8.0),
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