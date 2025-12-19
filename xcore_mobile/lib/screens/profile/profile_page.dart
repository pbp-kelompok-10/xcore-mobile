import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:xcore_mobile/screens/landing_page.dart';
import 'package:xcore_mobile/screens/login.dart';
import 'package:xcore_mobile/services/auth_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Apakah Anda yakin ingin keluar?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performLogout(context);
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // --- FUNGSI LOGOUT DIPERBAIKI ---
  Future<void> _performLogout(BuildContext context) async {
    final request = context.read<CookieRequest>();

    try {
      // Ganti URL sesuai device (10.0.2.2 untuk emulator Android)
      final response = await request.logout(
        "https://alvin-christian-xcore.pbp.cs.ui.ac.id/auth/logout/",
      );

      debugPrint("✅ Logout response: $response");

      // Clear stored user data
      await AuthService.clearUserData();
      debugPrint("✅ User data cleared");

      if (!context.mounted) return;

      String message = response['message'] ?? "Logout berhasil!";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFF4AA69B),
          duration: const Duration(seconds: 1),
        ),
      );

      debugPrint("✅ Navigating to LandingPage...");

      // Navigate immediately without delay - the logout() call should have already updated the state
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LandingPage()),
          (Route<dynamic> route) => false,
        );
        debugPrint("✅ Navigation completed");
      }
    } catch (e) {
      debugPrint("❌ Logout error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal logout: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // WATCH: Ini kuncinya. Kalau status login berubah, build akan jalan ulang.
    final request = context.watch<CookieRequest>();
    final bool isLoggedIn = request.loggedIn;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: const Color(0xFF4AA69B),
        foregroundColor: Colors.white,

        // --- BAGIAN INI YANG PENTING ---
        // Set ke false agar tombol back/drawer TIDAK MUNCUL di halaman ini
        automaticallyImplyLeading: false,
        // -------------------------------
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          // Logika Switch Tampilan
          child: isLoggedIn
              ? _buildLoggedInView(context, request) // Tampilan Profil User
              : _buildLoggedOutView(context), // Tampilan Tombol Login
        ),
      ),
    );
  }

  // TAMPILAN 1: SUDAH LOGIN
  Widget _buildLoggedInView(BuildContext context, CookieRequest request) {
    // Ambil username kalau ada di jsonData, kalau tidak pakai default
    String username = request.jsonData['username'] ?? 'User';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundColor: Color(0xFF4AA69B),
          child: Icon(Icons.person, size: 50, color: Colors.white),
        ),
        const SizedBox(height: 24),
        Text(
          username, // Nama dinamis dari Django
          style: const TextStyle(
            fontFamily: 'Nunito Sans',
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Selamat datang di Xcore',
          style: const TextStyle(
            fontFamily: 'Nunito Sans',
            fontSize: 16,
            color: Color(0xFF9CA3AF),
          ),
        ),
        const SizedBox(height: 48),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _showLogoutDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  // TAMPILAN 2: BELUM LOGIN (GUEST)
  Widget _buildLoggedOutView(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.person_off_outlined, size: 100, color: Colors.grey[400]),
        const SizedBox(height: 24),
        Text(
          'Anda Belum Login',
          style: TextStyle(
            fontFamily: 'Nunito Sans',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Silakan masuk untuk mengakses fitur profil',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Nunito Sans',
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 48),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            // TOMBOL INI YANG AKAN REDIRECT KE LOGIN PAGE
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4AA69B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Login / Masuk',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
