// Lokasi File: lib/services/auth_service.dart

import 'package:bcrypt/bcrypt.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
// [BARU] 1. Import Notification Service
import 'package:project_akhir/services/notification_service.dart';

class AuthService {
  final Box _userBox = Hive.box('userBox');

  // --- Fungsi Register (Dengan perbaikan Bcrypt) ---
  bool registerUser(String username, String email, String password) {
    try {
      if (_userBox.containsKey(email)) {
        return false;
      }
      // [PERBAIKAN] Menggunakan 'Bcrypt' (huruf kecil)
      String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());
      _userBox.put(email, {
        'username': username,
        'email': email,
        'password': hashedPassword,
      });
      return true;
    } catch (e) {
      print('Error registering user: $e');
      return false;
    }
  }

  // --- Fungsi Login (Dengan Notifikasi) ---
  Future<bool> loginUser(String email, String password) async {
    try {
      if (!_userBox.containsKey(email)) {
        return false;
      }

      // [PERBAIKAN] Menggunakan Map<dynamic, dynamic>
      final user = _userBox.get(email) as Map<dynamic, dynamic>;
      final String hashedPassword = user['password'];

      // [PERBAIKAN] Menggunakan 'Bcrypt' (huruf kecil)
      bool passwordMatch = BCrypt.checkpw(password, hashedPassword);

      if (passwordMatch) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('currentUserEmail', email);
        
        // [BARU] 2. Panggil notifikasi setelah login sukses
        String username = user['username']; // Ambil username
        NotificationService.showSimpleNotification(
          'Login Berhasil!',
          'Selamat datang kembali di ideaspark, $username.',
        );
        
        return true; // Login berhasil
      } else {
        return false; // Password salah
      }
    } catch (e) {
      print('Error logging in: $e');
      return false;
    }
  }

  // --- Fungsi Get User (Dengan perbaikan Map) ---
  Future<Map<dynamic, dynamic>?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('currentUserEmail');

      if (email == null) {
        return null;
      }
      
      if (_userBox.containsKey(email)) {
        // [PERBAIKAN] Menggunakan Map<dynamic, dynamic>
        return _userBox.get(email) as Map<dynamic, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }
}