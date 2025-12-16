import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'team_service.dart';

class TeamsPage extends StatefulWidget {
  const TeamsPage({super.key});

  @override
  State<TeamsPage> createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {
  List<Map<String, String>> teams = [];
  bool loading = true;
  bool fabOpen = false;

  @override
  void initState() {
    super.initState();
    loadTeams();
  }

  Future<void> loadTeams() async {
    if (!mounted) return;
    setState(() => loading = true);

    try {
      final response = await http.get(
        Uri.parse("http://localhost:8000/lineup/api/teams/"),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final teamsList = data['teams'] as List;
        final teamData = teamsList
            .map(
              (t) => {
                'name': t['name'].toString(),
                'code': t['code'].toString(),
                'id': t['id'].toString(),
              },
            )
            .toList();

        setState(() {
          teams = teamData.cast<Map<String, String>>();
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      print("Error: $e");
      if (mounted) setState(() => loading = false);
    }
  }

  void uploadTeamsZip(BuildContext context) async {
    final bytes = await TeamService.pickZipFile();
    if (bytes == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await TeamService.uploadTeamsZip(bytes);
      if (!mounted) return;
      Navigator.pop(context);
      await loadTeams();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Teams uploaded successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Upload failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F6F4),
      appBar: AppBar(
        title: const Text("Teams"),
        backgroundColor: const Color(0xFF4AA69B),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (fabOpen) ...[
            FloatingActionButton.extended(
              heroTag: "uploadTeamFAB",
              backgroundColor: Colors.green,
              icon: const Icon(Icons.upload_file),
              label: const Text("Upload ZIP"),
              onPressed: () => uploadTeamsZip(context),
            ),
            const SizedBox(height: 12),
          ],
          FloatingActionButton(
            heroTag: "toggleTeamFAB",
            backgroundColor: const Color(0xFF4AA69B),
            child: Icon(fabOpen ? Icons.close : Icons.add),
            onPressed: () => setState(() => fabOpen = !fabOpen),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : teams.isEmpty
          ? const Center(child: Text("No teams"))
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                for (final team in teams)
                  Card(
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Image.network(
                        'https://flagcdn.com/24x18/${team['code']?.toLowerCase() ?? ''}.png',
                        width: 32,
                        height: 24,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.flag),
                      ),
                      title: Text(
                        team['name'] ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
