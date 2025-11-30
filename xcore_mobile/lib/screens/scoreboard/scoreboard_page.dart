import 'package:flutter/material.dart';
import 'package:xcore_mobile/models/scoreboard_entry.dart';
import 'package:xcore_mobile/screens/forum/forum_page.dart';
import 'package:xcore_mobile/screens/scoreboard/admin/add_match_page.dart';
import 'package:xcore_mobile/screens/scoreboard/admin/edit_match_page.dart';
import 'package:xcore_mobile/screens/scoreboard/scoreboard_service.dart';
import 'package:xcore_mobile/screens/statistik/match_statistik.dart';
import 'package:xcore_mobile/screens/prediction/prediction_page.dart';
import 'package:xcore_mobile/screens/scoreboard/scoreboard_card.dart';
import 'package:xcore_mobile/screens/scoreboard/admin/add_match_page.dart';
import 'package:xcore_mobile/screens/forum/forum_page.dart';
import 'package:xcore_mobile/screens/login.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

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
      backgroundColor: const Color(0xFFF7F8FA),

      // ------------------------------
      // APPBAR
      // ------------------------------
      appBar: AppBar(
        title: const Text(
          "⚽ Xcore",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.add, color: Colors.teal),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddMatchPage(),
                  ),
                );
              },
            ),
        ],
      ),

      // ------------------------------
      // BODY
      // ------------------------------
      body: FutureBuilder(
        future: futureScoreboard,
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No scoreboard found"));
          }

          final matches = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final item = matches[index];

              return Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      final status = item.status.toLowerCase();

                      if (status == "upcoming") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PredictionPage(matchId: item.id),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MatchStatisticsPage(matchId: item.id, homeTeam: item.homeTeam, awayTeam:item.awayTeam, homeTeamCode: item.homeTeamCode, awayTeamCode: item.awayTeamCode),
                          ),
                        );
                      }
                    },

                    // UI CARD
                    child: ScoreboardMatchCard(
                      homeTeam: item.homeTeam,
                      awayTeam: item.awayTeam,
                      homeCode: item.homeTeamCode,
                      awayCode: item.awayTeamCode,
                      status: item.status,
                      homeScore: item.homeScore,
                      awayScore: item.awayScore,
                      stadium: item.stadium,
                      group: item.group,
                    ),
                  ),

                  const SizedBox(height: 8),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.forum, color: Colors.white),
                      label: const Text("Edit Match", style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditMatchPage(matchId: item.id),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ------------------------------
                  // FORUM BUTTON
                  // ------------------------------
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.forum, color: Colors.white),
                      label: const Text("Open Match Forum", style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ForumPage(matchId: item.id),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
