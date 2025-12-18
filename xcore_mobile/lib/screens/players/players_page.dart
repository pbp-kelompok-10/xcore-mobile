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
  List<Player> _filteredPlayers = [];
  bool _loading = true;
  String _error = '';
  bool _fabOpen = false;
  String _searchQuery = '';

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
        _filteredPlayers = players;
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

  void _filterPlayers(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredPlayers = _players;
      } else {
        _filteredPlayers = _players
            .where(
              (player) =>
                  player.nama.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  // GROUP BY TEAM NAME
  Map<String, List<Player>> groupByTeam(List<Player> players) {
    final Map<String, List<Player>> grouped = {};

    for (var player in players) {
      final teamName = player.teamName;

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
    final zipFile = await PlayerService.pickPlayersZip();
    if (zipFile == null) return;

    // Show progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final result = await PlayerService.uploadPlayersZip(zipFile);

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      // Parse results
      final added = result['added'] as List? ?? [];
      final skipped = result['skipped'] as List? ?? [];
      final missingTeams = result['missing_teams'] as List? ?? [];
      final invalidFiles = result['invalid_files'] as List? ?? [];

      // Build summary message
      String message = "Upload complete!\n";
      message += "✓ Added: ${added.length}\n";

      if (skipped.isNotEmpty) {
        message += "⚠ Skipped: ${skipped.length}\n";
      }
      if (missingTeams.isNotEmpty) {
        message += "✗ Missing teams: ${missingTeams.join(', ')}\n";
      }
      if (invalidFiles.isNotEmpty) {
        message += "✗ Invalid files: ${invalidFiles.length}\n";
      }

      // Show result
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
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
          child: Text(_error, style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    final grouped = groupByTeam(_filteredPlayers);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Players"),
        backgroundColor: const Color(0xFF1e423b),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: _filterPlayers,
              decoration: InputDecoration(
                hintText: 'Search player',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _filterPlayers(''),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          Expanded(
            child: _filteredPlayers.isEmpty
                ? const Center(
                    child: Text(
                      "No players available",
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadPlayers,
                    child: ListView(
                      children:
                          (grouped.entries.toList()
                                ..sort((a, b) => a.key.compareTo(b.key)))
                              .map((entry) {
                                final teamName = entry.key;
                                final players = entry.value;

                                return ExpansionTile(
                                  leading: Image.network(
                                    'https://flagcdn.com/24x18/${players.first.teamCode.toLowerCase()}.png',
                                    width: 32,
                                    height: 24,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.flag),
                                  ),
                                  title: Text(
                                    teamName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  children: players.map((player) {
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.green[700],
                                        child: Text(
                                          player.nomor.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      title: Text(player.nama),
                                      subtitle: Text(
                                        "${player.asal} · Age ${player.umur}",
                                      ),
                                      onTap: () {
                                        // TODO navigate to player detail
                                      },
                                    );
                                  }).toList(),
                                );
                              })
                              .toList(),
                    ),
                  ),
          ),
        ],
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
    );
  }
}
