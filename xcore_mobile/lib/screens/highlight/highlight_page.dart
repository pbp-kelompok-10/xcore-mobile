import 'package:flutter/material.dart';

class HighlightPage extends StatelessWidget {
  final String matchId;

  const HighlightPage({super.key, required this.matchId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Highlight")),
      body: Center(child: Text("Highlight for match: $matchId")),
    );
  }
}