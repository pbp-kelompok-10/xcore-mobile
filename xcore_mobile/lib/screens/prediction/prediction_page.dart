import 'package:flutter/material.dart';

class PredictionPage extends StatelessWidget {
  final String matchId;

  const PredictionPage({super.key, required this.matchId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Match Prediction")),
      body: Center(
        child: Text("Prediction for match: $matchId"),
      ),
    );
  }
}
