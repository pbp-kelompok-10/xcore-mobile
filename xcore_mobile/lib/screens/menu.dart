import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:xcore_mobile/screens/scoreboard/scoreboard_page.dart';
import 'package:xcore_mobile/screens/prediction/prediction_page.dart';
import 'package:xcore_mobile/screens/teams/teams_page.dart';
import 'package:xcore_mobile/screens/players/players_page.dart';
import 'package:xcore_mobile/screens/login.dart';
import 'left_drawer.dart';

class MyHomePage extends StatelessWidget {
  MyHomePage({super.key});

  final List<ItemHomepage> items = [
    ItemHomepage("Scoreboard", Icons.scoreboard, const Color(0xFF56BDA9)),
    ItemHomepage("Prediction", Icons.analytics, const Color(0xFF4AA69B)),
    ItemHomepage("Teams", Icons.people, const Color(0xFF3D9B8E)),
    ItemHomepage("Players", Icons.person, const Color(0xFF28574E)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Xcore Football',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF4AA69B),
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            color: Colors.white,
            onPressed: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFFE8F6F4),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF4AA69B), Color(0xFF56BDA9)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: const Column(
                children: [
                  Text(
                    'Selamat Datang di',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Xcore Football',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Platform terbaik untuk statistik sepakbola',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'All Features',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: items.map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: _buildHorizontalButton(item),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalButton(ItemHomepage item) {
    return Builder(
      builder: (context) {
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              _handleTap(context, item);
            },
            child: Container(
              width: 80,
              height: 80,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [item.color, _darkenColor(item.color, 0.2)],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    item.icon,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleTap(BuildContext context, ItemHomepage item) {
    _showSnackBar(context, "Membuka ${item.name}");

    switch (item.name) {
      case "Scoreboard":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ScoreboardPage()),
        );
        break;
      case "Prediction":
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PredictionPage(),
          ),
        );
        break;
      case "Teams":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TeamsPage()),
        );
        break;
      case "Players":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PlayersPage()),
        );
        break;
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFF4AA69B),
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
              child: const Text(
                "Logout",
                style: TextStyle(color: Colors.red),
              ),
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
        "http://localhost:8000/auth/logout/",
      );
    } catch (e) {
      print("Logout network error: $e");
      snackbarMessage = "Logout berhasil secara lokal, tetapi gagal menghubungi server.";
    }
    
    _navigateToLogin(context, snackbarMessage);
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
          backgroundColor: const Color(0xFF4AA69B),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Color _darkenColor(Color color, double factor) {
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - factor).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}

class ItemHomepage {
  final String name;
  final IconData icon;
  final Color color;

  ItemHomepage(this.name, this.icon, this.color);
}