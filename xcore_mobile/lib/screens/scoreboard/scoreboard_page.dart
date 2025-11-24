import 'package:flutter/material.dart';
import 'package:xcore_mobile/models/scoreboard_entry.dart';
import 'package:xcore_mobile/screens/scoreboard/scoreboard_service.dart';

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

              return ListTile(
                title: Text("${item.homeTeam} vs ${item.awayTeam}"),
                subtitle: Text(
                    "${item.homeScore} - ${item.awayScore} | ${item.stadium}"
                ),
              );
            },
          );
        },
      ),
    );
  }
}
