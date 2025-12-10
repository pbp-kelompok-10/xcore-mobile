import 'package:flutter/material.dart';

class TeamsPage extends StatelessWidget {
  const TeamsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F6F4),
      appBar: AppBar(
        title: const Text(
          "Teams",
          style: TextStyle(
            fontFamily: 'Nunito Sans',
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 2,
        backgroundColor: const Color(0xFF4AA69B),
        foregroundColor: const Color(0xFFFFFFFF),
        
        // --- BAGIAN INI YANG PENTING ---
        // Set ke false agar tombol back/drawer TIDAK MUNCUL di halaman ini
        automaticallyImplyLeading: false, 
        // -------------------------------
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.people,
              size: 80,
              color: Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 24),
            const Text(
              "Teams Page (Root)",
              style: TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B8E8A),
              ),
            ),
            const SizedBox(height: 24),
            
            // Contoh Tombol untuk masuk ke Detail
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4AA69B),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                // Navigasi ke halaman detail
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TeamDetailPage()),
                );
              },
              child: const Text("Lihat Detail Team"),
            ),
          ],
        ),
      ),
    );
  }
}


class TeamDetailPage extends StatelessWidget {
  const TeamDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F6F4),
      appBar: AppBar(
        title: const Text("Detail Team"),
        backgroundColor: const Color(0xFF4AA69B),
        foregroundColor: Colors.white,
        // Di sini automaticallyImplyLeading defaultnya TRUE.
        // Jadi Flutter otomatis kasih tombol back karena ada history navigasi.
      ),
      body: const Center(
        child: Text("Sekarang ada tombol back di kiri atas!"),
      ),
    );
  }
}