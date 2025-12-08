import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xcore_mobile/models/prediction_entry.dart';
import 'package:xcore_mobile/widgets/prediction_entry_card.dart';
import 'package:xcore_mobile/screens/scoreboard/scoreboard_page.dart';

class PredictionPage extends StatefulWidget {
  const PredictionPage({super.key});

  @override
  State<PredictionPage> createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage> {
  // Variabel untuk menyimpan hasil fetch
  late Future<List<Prediction>> futurePredictions;

  @override
  void initState() {
    super.initState();
    futurePredictions = fetchPredictions();
  }

  // --- FUNGSI AMBIL SEMUA DATA ---
  Future<List<Prediction>> fetchPredictions() async {
    // ⚠️ GANTI URL SESUAI DEVICE
    // Web (Chrome): 'http://127.0.0.1:8000/json-prediction/'
    // Android Emulator: 'http://10.0.2.2:8000/json-prediction/'
    var url = Uri.parse('http://127.0.0.1:8000/prediction/json/');

    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        // Langsung return SEMUA list tanpa filter-filteran
        return predictionFromJson(response.body);
      } else {
        throw Exception('Gagal load prediction. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error koneksi: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Background agak abu biar card nonjol
      appBar: AppBar(
        title: const Text("Prediction Center"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black, // Warna teks hitam
        elevation: 0,
      ),
      body: FutureBuilder<List<Prediction>>(
        future: futurePredictions,
        builder: (context, snapshot) {
          // A. Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // B. Error
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    "Gagal memuat data.\n${snapshot.error}",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        futurePredictions = fetchPredictions();
                      });
                    },
                    child: const Text("Coba Lagi"),
                  )
                ],
              ),
            );
          }

          // C. Data Kosong
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.analytics_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    "Belum ada prediksi pertandingan.",
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Navigasi ke Scoreboard kalau user mau liat match biasa
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ScoreboardPage()),
                      );
                    },
                    icon: const Icon(Icons.scoreboard),
                    label: const Text("Lihat Scoreboard"),
                  )
                ],
              ),
            );
          }

          // D. Data Ada -> Tampilkan LIST
          final listData = snapshot.data!;
          
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                futurePredictions = fetchPredictions();
              });
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: listData.length,
              itemBuilder: (context, index) {
                final prediction = listData[index];
                
                // Tampilkan Card
                return PredictionEntryCard(
                  prediction: prediction,
                  onTap: () {
                    // Nanti disini logika Vote
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Kamu memilih match: ${prediction.homeTeam} vs ${prediction.awayTeam}")),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}