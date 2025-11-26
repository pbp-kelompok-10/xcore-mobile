import 'package:flutter/material.dart';

class EditMatchPage extends StatelessWidget {
  final String matchId;

  const EditMatchPage({super.key, required this.matchId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Match")),
      body: Center(
        child: Text("Edit match: $matchId"),
      ),
    );
  }
}
