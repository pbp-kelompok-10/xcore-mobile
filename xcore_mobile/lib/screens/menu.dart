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
    ItemHomepage("Scoreboard", Icons.scoreboard, Colors.orange[400]!),
    ItemHomepage("Prediction", Icons.analytics, Colors.blue[400]!),
    ItemHomepage("Teams", Icons.people, Colors.purple[400]!),
    ItemHomepage("Players", Icons.person, Colors.teal[400]!),
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
        backgroundColor: Colors.green[700],
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          // Logout Button di AppBar
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _showLogoutDialog(context);
            },
          ),
          
        ],
      ),
      drawer: LeftDrawer(),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header dengan gradien hijau
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.green[700]!, Colors.green[500]!],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Welcome text
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

            SizedBox(height: 20),

            // Tombol Horizontal
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
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
                  SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: items.map((item) {
                        return Padding(
                          padding: EdgeInsets.only(right: 12),
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
              width: 80, // Ukuran lebih kecil
              height: 80, // Ukuran lebih kecil
              padding: EdgeInsets.all(8),
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
                    size: 24, // Icon lebih kecil
                  ),
                  SizedBox(height: 6),
                  Text(
                    item.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 10, // Font lebih kecil
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
    // Tampilkan snackbar pemberitahuan
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
            builder: (context) => PredictionPage.selectMatch(),
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
          backgroundColor: Colors.green[600],
          duration: Duration(seconds: 2),
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
          title: Text("Logout"),
          content: Text("Apakah Anda yakin ingin logout?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performLogout(context);
              },
              child: Text(
                "Logout",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  // Lokasi: lib/screens/left_drawer.dart (dan lib/screens/menu.dart)

void _performLogout(BuildContext context) async {
  final request = context.read<CookieRequest>();
  
  // Tentukan pesan default
  String snackbarMessage = "Logout berhasil!";
  
  try {
    // Coba logout ke Django
    final response = await request.logout(
      "http://localhost:8000/auth/logout/",
    );

  } catch (e) {
    print("Logout network error: $e");
    snackbarMessage = "Logout berhasil secara lokal, tetapi gagal menghubungi server.";
  }
  
  // Navigasi ke login page setelah upaya logout, berhasil atau gagal.
  _navigateToLogin(context, snackbarMessage);
}

  void _navigateToLogin(BuildContext context, String message) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
    
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green[600],
          duration: Duration(seconds: 2),
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