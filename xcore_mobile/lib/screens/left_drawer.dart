import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:xcore_mobile/screens/scoreboard/scoreboard_page.dart';
import 'package:xcore_mobile/screens/prediction/prediction_page.dart';
import 'package:xcore_mobile/screens/teams/teams_page.dart';
import 'package:xcore_mobile/screens/players/players_page.dart';
import 'package:xcore_mobile/screens/profile/profile_page.dart';
import 'package:xcore_mobile/screens/login.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Pantau status login user
    final request = context.watch<CookieRequest>();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer Header
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.green[700]!, Colors.green[500]!],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.sports_soccer,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Xcore Football',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                // Tampilkan info status user di header (Opsional, biar keren)
                Text(
                  request.loggedIn ? 'Welcome, User!' : 'Guest Mode',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),

          // Menu Items
          _buildDrawerItem(
            context,
            icon: Icons.home,
            title: 'Home',
            onTap: () {
              Navigator.pop(context); // Tutup drawer
            },
          ),

          _buildDrawerItem(
            context,
            icon: Icons.scoreboard,
            title: 'Scoreboard',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ScoreboardPage()),
              );
            },
          ),

          _buildDrawerItem(
            context,
            icon: Icons.analytics,
            title: 'Prediction',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PredictionPage()),
              );
            },
          ),

          _buildDrawerItem(
            context,
            icon: Icons.people,
            title: 'Teams',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TeamsPage()),
              );
            },
          ),

          _buildDrawerItem(
            context,
            icon: Icons.person,
            title: 'Players',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PlayersPage()),
              );
            },
          ),

          // Divider
          Divider(color: Colors.grey[300]),

          // Profile Menu (Only for logged in users)
          if (request.loggedIn)
            _buildDrawerItem(
              context,
              icon: Icons.account_circle,
              title: 'Profile',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            ),

          // 2. LOGIKA TOMBOL LOGIN / LOGOUT
          if (request.loggedIn) ...[
            // JIKA SUDAH LOGIN -> TAMPILKAN LOGOUT
            _buildDrawerItem(
              context,
              icon: Icons.logout,
              title: 'Logout',
              onTap: () {
                Navigator.pop(context);
                _showLogoutDialog(context);
              },
            ),
          ] else ...[
            // JIKA BELUM LOGIN (GUEST) -> TAMPILKAN LOGIN
            _buildDrawerItem(
              context,
              icon: Icons.login,
              title: 'Login',
              onTap: () {
                Navigator.pop(context);
                // Arahkan ke halaman Login
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        VoidCallback? onTap,
      }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green[50],
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.green[600], size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[800]),
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
      onTap: onTap,
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green[600],
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Apakah Anda yakin ingin logout?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performLogout(context);
              },
              child: const Text("Logout", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _performLogout(BuildContext context) async {
    final request = context.read<CookieRequest>();

    String snackbarMessage = "Logout berhasil!";

    try {
      final response = await request.logout(
        "https://localhost:8000/auth/logout/",
      );
    } catch (e) {
      print("Logout network error: $e");
      snackbarMessage =
      "Logout berhasil secara lokal, tetapi gagal menghubungi server.";
    }

    if (context.mounted) {
      _navigateToLogin(context, snackbarMessage);
    }
  }

  void _navigateToLogin(BuildContext context, String message) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green[600],
          duration: const Duration(seconds: 2),
        ),
      );
  }
}