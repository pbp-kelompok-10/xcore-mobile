import 'package:flutter/material.dart';
import 'player_service.dart';
import '../../models/player_entry.dart';

class PlayersPage extends StatefulWidget {
  const PlayersPage({super.key});

  @override
  State<PlayersPage> createState() => _PlayersPageState();
}

class _PlayersPageState extends State<PlayersPage> {
  List<Player> _players = [];
  bool _loading = true;
  String _error = '';
  bool _fabOpen = false;

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final players = await PlayerService.getPlayers();
      setState(() {
        _players = players;
      });
    } catch (e) {
      setState(() {
        _error = "Failed to load players: $e";
      });
    }

    setState(() {
      _loading = false;
    });
  }

  // GROUP BY TEAM NAME
  Map<String, List<Player>> groupByTeam(List<Player> players) {
    final Map<String, List<Player>> grouped = {};

    for (var player in players) {
      final teamName = player.tim.name;

      if (!grouped.containsKey(teamName)) {
        grouped[teamName] = [];
      }

      grouped[teamName]!.add(player);
    }

    return grouped;
  }

  // ======== ASYNC UPLOAD ZIP WITH PROGRESS ========
  Future<void> _uploadPlayersZip(BuildContext context) async {
    // Pick ZIP file
    final fileBytes = await PlayerService.pickPlayersZip();
    if (fileBytes == null) return;

    // Show progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final result = await PlayerService.uploadPlayersZip(fileBytes);

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      // Show result
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Upload complete"),
          backgroundColor: Colors.green,
        ),
      );

      // Auto refresh data
      await _loadPlayers();

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
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Players")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Players")),
        body: Center(
          child: Text(
            _error,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    final grouped = groupByTeam(_players);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Players"),
        backgroundColor: const Color(0xFF1e423b),
      ),

      // FLOATING EXPANDING BUTTONS
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_fabOpen) ...[
            FloatingActionButton.extended(
              heroTag: "addPlayerFAB",
              backgroundColor: Colors.blue,
              label: const Text("Add Player"),
              icon: const Icon(Icons.person_add),
              onPressed: () {
                // TODO: navigate to add player page
              },
            ),
            const SizedBox(height: 12),

            FloatingActionButton.extended(
              heroTag: "uploadPlayerFAB",
              backgroundColor: Colors.green,
              label: const Text("Upload ZIP"),
              icon: const Icon(Icons.upload_file),
              onPressed: () => _uploadPlayersZip(context),
            ),
            const SizedBox(height: 12),
          ],

          FloatingActionButton(
            heroTag: "toggleFAB",
            backgroundColor: const Color(0xFF1e423b),
            child: Icon(
              _fabOpen ? Icons.close : Icons.add,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() => _fabOpen = !_fabOpen);
            },
          ),
        ],
      ),

      // BODY
      body: RefreshIndicator(
        onRefresh: _loadPlayers,
        child: ListView(
          children: grouped.entries.map((entry) {
            final teamName = entry.key;
            final players = entry.value;

            return ExpansionTile(
              title: Text(
                teamName,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              children: players.map((player) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green[700],
                    child: Text(
                      player.nomor.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(player.nama),
                  subtitle: Text("${player.asal} · Age ${player.umur}"),
                  onTap: () {
                    // TODO navigate to player detail
                  },
                );
              }).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }
}
