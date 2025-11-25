import 'package:flutter/material.dart';

class AddMatchPage extends StatelessWidget {
  const AddMatchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Match")),
      body: Center(
        child: Text("Add match"),
      ),
    );
  }
}
