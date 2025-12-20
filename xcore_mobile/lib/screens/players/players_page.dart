import 'package:flutter/material.dart';
import 'player_service.dart';
import 'player_detail_service.dart';
import 'player_detail_page.dart';
import 'add_player_page.dart';
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
  bool _isAdmin = false;
  bool _isLoading = true;

  // Warna konsisten dengan MatchStatisticsPage dan ForumPage
  static const Color primaryColor = Color(0xFF4AA69B);
  static const Color scaffoldBgColor = Color(0xFFE8F6F4);
  static const Color darkTextColor = Color(0xFF2C5F5A);
  static const Color mutedTextColor = Color(0xFF6B8E8A);
  static const Color accentColor = Color(0xFF34C6B8);
  static const Color lightBgColor = Color(0xFFD1F0EB);
  static const Color whiteColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    try {
      final admin_status = await PlayerService.fetchAdminStatus(context);
      setState(() {
        _isAdmin = admin_status;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
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
      builder: (_) => Center(
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                strokeWidth: 3,
              ),
              SizedBox(height: 16),
              Text(
                'Uploading...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: darkTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
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
      _showSnackBar(message, isError: false);

      // Auto refresh data
      await _loadPlayers();
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);

      _showSnackBar("❌ Upload failed: $e", isError: true);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red[600] : primaryColor,
          duration: Duration(seconds: isError ? 2 : 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            strokeWidth: 2,
          ),
          SizedBox(height: 16),
          Text(
            'Loading Players...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: mutedTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.error_outline, size: 40, color: Colors.red),
              ),
              SizedBox(height: 20),
              Text(
                'Failed to Load Players',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 8),
              Text(
                _error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: mutedTextColor,
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadPlayers,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: whiteColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Container(
          padding: EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: primaryColor.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.people_outline, size: 40, color: primaryColor),
              ),
              SizedBox(height: 20),
              Text(
                'No Players Available',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: darkTextColor,
                ),
              ),
              SizedBox(height: 8),
              Text(
                _searchQuery.isEmpty
                    ? 'No players found in the database'
                    : 'No players match your search',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: mutedTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        title: Text(
          "Players",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: whiteColor,
            fontSize: 18,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: _loading
          ? _buildLoadingState()
          : _error.isNotEmpty
          ? _buildErrorState()
          : Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: whiteColor,
              border: Border(
                bottom: BorderSide(color: primaryColor.withOpacity(0.2)),
              ),
            ),
            child: TextField(
              onChanged: _filterPlayers,
              style: TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search player by name...',
                hintStyle: TextStyle(color: mutedTextColor),
                prefixIcon: Icon(Icons.search, color: primaryColor),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear, color: mutedTextColor),
                  onPressed: () {
                    _filterPlayers('');
                    // Clear the text field
                    setState(() => _searchQuery = '');
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: mutedTextColor.withOpacity(0.3)),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                fillColor: scaffoldBgColor,
                filled: true,
              ),
            ),
          ),

          // Players List
          Expanded(
            child: _filteredPlayers.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
              onRefresh: _loadPlayers,
              color: primaryColor,
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 8),
                children: (groupByTeam(_filteredPlayers).entries.toList()
                  ..sort((a, b) => a.key.compareTo(b.key)))
                    .map((entry) {
                  final teamName = entry.key;
                  final players = entry.value;

                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: whiteColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: primaryColor.withOpacity(0.2)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                      ),
                      child: ExpansionTile(
                        leading: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: lightBgColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.network(
                            'https://flagcdn.com/24x18/${players.first.teamCode.toLowerCase()}.png',
                            width: 32,
                            height: 24,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.flag, size: 24, color: mutedTextColor),
                          ),
                        ),
                        title: Text(
                          teamName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: darkTextColor,
                          ),
                        ),
                        trailing: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${players.length}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        children: players.map((player) {
                          return Container(
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: primaryColor.withOpacity(0.1),
                                ),
                              ),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: primaryColor,
                                child: Text(
                                  player.nomor.toString(),
                                  style: TextStyle(
                                    color: whiteColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              title: Text(
                                player.nama,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: darkTextColor,
                                ),
                              ),
                              subtitle: Row(
                                children: [
                                  if (player.asal.isNotEmpty) ...[
                                    Icon(Icons.public, size: 12, color: mutedTextColor),
                                    SizedBox(width: 4),
                                    Text(
                                      player.asal,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: mutedTextColor,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                  ],
                                  Icon(Icons.calendar_today, size: 12, color: mutedTextColor),
                                  SizedBox(width: 4),
                                  Text(
                                    "Age ${player.umur}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: mutedTextColor,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Icon(
                                Icons.chevron_right,
                                color: mutedTextColor,
                              ),
                              onTap: () async {
                                final refreshNeeded =
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        PlayerDetailPage(
                                          playerId: player.id,
                                        ),
                                  ),
                                );
                                if (refreshNeeded == true) {
                                  _loadPlayers();
                                }
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),

      // FLOATING EXPANDING BUTTONS
      floatingActionButton: _isAdmin
          ? Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_fabOpen) ...[
            FloatingActionButton.extended(
              heroTag: "addPlayerFAB",
              backgroundColor: accentColor,
              foregroundColor: whiteColor,
              label: const Text("Add Player", style: TextStyle(fontWeight: FontWeight.bold)),
              icon: const Icon(Icons.person_add),
              onPressed: () async {
                final refreshNeeded = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddPlayerPage(),
                  ),
                );
                if (refreshNeeded == true) {
                  _loadPlayers();
                }
              },
            ),
            const SizedBox(height: 12),
            FloatingActionButton.extended(
              heroTag: "uploadPlayerFAB",
              backgroundColor: primaryColor,
              foregroundColor: whiteColor,
              label: const Text("Upload ZIP", style: TextStyle(fontWeight: FontWeight.bold)),
              icon: const Icon(Icons.upload_file),
              onPressed: () => _uploadPlayersZip(context),
            ),
            const SizedBox(height: 12),
          ],
          FloatingActionButton(
            heroTag: "toggleFAB",
            backgroundColor: primaryColor,
            foregroundColor: whiteColor,
            child: Icon(_fabOpen ? Icons.close : Icons.add),
            onPressed: () {
              setState(() => _fabOpen = !_fabOpen);
            },
          ),
        ],
      )
          : null,
    );
  }
}