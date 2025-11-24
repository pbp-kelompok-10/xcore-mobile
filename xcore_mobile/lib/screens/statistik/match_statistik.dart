import 'package:flutter/material.dart';

class MatchStatisticsPage extends StatelessWidget {
  final String matchId;

  const MatchStatisticsPage({super.key, required this.matchId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Match Statistics")),
      body: Center(
        child: Text("Statistics for match: $matchId"),
      ),
    );
  }
}
