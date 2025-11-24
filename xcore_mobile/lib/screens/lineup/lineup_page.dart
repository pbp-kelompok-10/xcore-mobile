import 'package:flutter/material.dart';

class LineupPage extends StatelessWidget {
  final String matchId;

  const LineupPage({super.key, required this.matchId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Lineup")),
      body: Center(child: Text("Lineup for match: $matchId")),
    );
  }
}