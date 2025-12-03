import 'package:flutter/material.dart';
import '../scoreboard/scoreboard_page.dart';

class PredictionPage extends StatelessWidget {
  final String matchId;

  const PredictionPage({super.key, required this.matchId});

  // Constructor untuk pilih match
  const PredictionPage.selectMatch({super.key}) : matchId = '';

  @override
  Widget build(BuildContext context) {
    // Jika matchId kosong, tampilkan pilihan
    if (matchId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("Select Match for Prediction")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.analytics, size: 64, color: Colors.blue),
              SizedBox(height: 16),
              Text(
                "Pilih Pertandingan",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                "Silakan pilih pertandingan dari scoreboard",
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(Icons.scoreboard),
                label: Text("Buka Scoreboard"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ScoreboardPage()),
                  );
                },
              ),
            ],
          ),
        ),
      );
    }

    // Jika ada matchId, tampilkan prediction untuk match tersebut
    return Scaffold(
      appBar: AppBar(title: Text("Prediction")),
      body: Center(child: Text("Prediction for match: $matchId")),
    );
  }
}
