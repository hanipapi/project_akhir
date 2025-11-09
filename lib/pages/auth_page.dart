// Lokasi File: lib/pages/auth_page.dart

import 'package:flutter/material.dart';
import 'package:project_akhir/services/auth_service.dart';
import 'package:project_akhir/pages/main_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  // Definisikan warna branding kita
  static const Color primaryGreen = Color(0xFF2ECC71); // <-- Warna hijau "ea"
  static const Color primaryBlack = Color(0xFF1F1F1F); // <-- Warna hitam "id"
  static const Color lightGrey = Color(0xFFF2F2F2);
  static const Color darkGrey = Color(0xFF6E6E6E);


  bool _isLoginMode = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
    });
  }

  void _handleAuthAction() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text;
    final password = _passwordController.text;

    if (_isLoginMode) {
      // --- LOGIKA LOGIN ---
      if (email.isEmpty || password.isEmpty) {
        _showSnackBar('Email dan Password harus diisi', isError: true);
        setState(() { _isLoading = false; });
        return;
      }
      bool success = await _authService.loginUser(email, password);
      if (success && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainPage()),
        );
      } else if (mounted) {
        _showSnackBar('Login Gagal. Cek kembali email dan password Anda.', isError: true);
      }
    } else {
      // --- LOGIKA REGISTER ---
      final username = _usernameController.text;
      if (email.isEmpty || password.isEmpty || username.isEmpty) {
        _showSnackBar('Semua kolom harus diisi', isError: true);
        setState(() { _isLoading = false; });
        return;
      }
      bool success = _authService.registerUser(username, email, password);
      if (success) {
        _showSnackBar('Registrasi berhasil! Silakan login.', isError: false);
        _toggleMode();
        _usernameController.clear();
        _emailController.clear();
        _passwordController.clear();
      } else {
        _showSnackBar('Registrasi gagal. Email mungkin sudah terdaftar.', isError: true);
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
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
    // [UI BARU SESUAI BRANDING]
    return Scaffold(
      // 1. Latar belakang putih bersih
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 2. Logo (Mirip logo Anda)
                Icon(
                  Icons.lightbulb_outline, // Ikon bolam lampu
                  size: 80,
                  color: primaryGreen, // Warna hijau
                ),
                const SizedBox(height: 16),
                
                // 3. Nama Aplikasi
                Text(
                  'ideaspark',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: primaryBlack, // Warna hitam
                  ),
                ),
                const SizedBox(height: 8),

                // 4. Judul
                Text(
                  _isLoginMode ? 'Welcome Back' : 'Create Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: primaryBlack,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isLoginMode
                      ? 'Enter your details below'
                      : 'Sign up to get started',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: darkGrey,
                  ),
                ),
                const SizedBox(height: 40),

                // 5. Form Fields
                if (!_isLoginMode) ...[
                  _buildTextField(
                    controller: _usernameController,
                    label: 'Username',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),
                ],

                _buildTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Icons.lock_outline,
                  isPassword: true,
                ),
                const SizedBox(height: 32),

                // 6. Tombol Aksi (Login/Daftar)
                _isLoading
                    ? Center(child: CircularProgressIndicator(color: primaryGreen))
                    : ElevatedButton(
                        onPressed: _handleAuthAction,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: primaryBlack, // Tombol hitam
                          foregroundColor: Colors.white, // Teks putih
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        child: Text(
                          _isLoginMode ? 'Sign In' : 'Sign Up',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                const SizedBox(height: 16),

                // 7. Tombol Ganti Mode
                TextButton(
                  onPressed: _toggleMode,
                  child: Text(
                    _isLoginMode
                        ? "Don't have an account? Get Started"
                        : 'Already have an account? Sign In',
                    style: TextStyle(color: darkGrey),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // [UI BARU] Helper widget untuk TextField
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      style: TextStyle(color: primaryBlack), // Teks input hitam
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: darkGrey),
        prefixIcon: Icon(icon, color: darkGrey),
        filled: true,
        fillColor: lightGrey, // Latar belakang abu-abu muda
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(color: primaryGreen, width: 2), // Fokus hijau
        ),
      ),
    );
  }
}