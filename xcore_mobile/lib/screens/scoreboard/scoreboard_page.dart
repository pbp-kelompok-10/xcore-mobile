import 'package:flutter/material.dart';
import 'package:xcore_mobile/models/scoreboard_entry.dart';
import 'package:xcore_mobile/screens/scoreboard/scoreboard_service.dart';
import 'package:xcore_mobile/screens/statistik/match_statistik.dart';

class ScoreboardPage extends StatefulWidget {
  const ScoreboardPage({super.key});

  @override
  State<ScoreboardPage> createState() => _ScoreboardPageState();
}

class _ScoreboardPageState extends State<ScoreboardPage> {
  late Future<List<ScoreboardEntry>> futureScoreboard;

  @override
  void initState() {
    super.initState();
    futureScoreboard = ScoreboardService.fetchScoreboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Scoreboard")),
      body: FutureBuilder(
        future: futureScoreboard,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No scoreboard found"));
          }

          final list = snapshot.data!;

          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];

              // DEBUG: Print untuk cek data
              print("=== SCOREBOARD ITEM ===");
              print("Home: ${item.homeTeam} (${item.homeTeamCode})");
              print("Away: ${item.awayTeam} (${item.awayTeamCode})");
              print("======================");

              return ListTile(
                title: Text("${item.homeTeam} vs ${item.awayTeam}"),
                subtitle: Text(
                  "${item.homeScore} - ${item.awayScore} | ${item.stadium}"
                ),

                // UNTUK KE STATISTIK
                onTap: () {

                  // ✅ Snackbar ditambahkan di sini
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text("Membuka Statistics..."),
                        duration: Duration(seconds: 1),
                        backgroundColor: Colors.green[700],
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );

                  // Delay sedikit supaya snackbar muncul dulu
                  Future.delayed(Duration(milliseconds: 300), () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MatchStatisticsPage(
                          matchId: item.id,
                          homeTeam: item.homeTeam,
                          awayTeam: item.awayTeam,
                          homeTeamCode: item.homeTeamCode, // TAMBAH INI
                          awayTeamCode: item.awayTeamCode, // TAMBAH INI
                        ),
                      ),
                    );
                  });
                },
              );
            },
          );
        },
      ),
    );
  }
}
