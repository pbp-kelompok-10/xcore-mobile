import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:xcore_mobile/screens/scoreboard/scoreboard_page.dart';
import 'package:xcore_mobile/screens/prediction/prediction_page.dart';
import 'package:xcore_mobile/screens/teams/teams_page.dart';
import 'package:xcore_mobile/screens/players/players_page.dart';
import 'package:xcore_mobile/screens/login.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
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
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.sports_soccer,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Xcore Football',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Complete Football Stats',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
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
              _showSnackBar(context, "Kembali ke Home");
              Navigator.pop(context);
            },
          ),

          _buildDrawerItem(
            context,
            icon: Icons.scoreboard,
            title: 'Scoreboard',
            onTap: () {
              _showSnackBar(context, "Membuka Scoreboard");
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ScoreboardPage()),
              );
            },
          ),

          _buildDrawerItem(
            context,
            icon: Icons.analytics,
            title: 'Prediction',
            onTap: () {
              _showSnackBar(context, "Membuka Prediction");
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PredictionPage.selectMatch(),
                ),
              );
            },
          ),

          _buildDrawerItem(
            context,
            icon: Icons.people,
            title: 'Teams',
            onTap: () {
              _showSnackBar(context, "Membuka Teams");
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TeamsPage()),
              );
            },
          ),

          _buildDrawerItem(
            context,
            icon: Icons.person,
            title: 'Players',
            onTap: () {
              _showSnackBar(context, "Membuka Players");
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PlayersPage()),
              );
            },
          ),

          // Divider
          Divider(color: Colors.grey[300]),

          // Logout
          _buildDrawerItem(
            context,
            icon: Icons.logout,
            title: 'Logout',
            onTap: () {
              Navigator.pop(context);
              _showLogoutDialog(context);
            },
          ),
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
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green[50],
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.green[600], size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.grey[800],
        ),
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
}