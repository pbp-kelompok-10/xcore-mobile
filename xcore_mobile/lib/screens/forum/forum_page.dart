import 'package:flutter/material.dart';

class ForumPage extends StatelessWidget {
  final String matchId;

  const ForumPage({super.key, required this.matchId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Match Forum")),
      body: Center(
        child: Text("Forum for match: $matchId"),
      ),
    );
  }
}
