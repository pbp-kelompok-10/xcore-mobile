// lineup/create_edit_lineup_screen.dart
import 'package:flutter/material.dart';
import 'package:xcore_mobile/screens/lineup/lineup_service.dart';
import 'package:xcore_mobile/models/lineup_entry.dart';
import 'package:xcore_mobile/models/scoreboard_entry.dart';

class CreateEditLineupScreen extends StatefulWidget {
  final ScoreboardEntry match;
  final Lineup? homeLineup;
  final Lineup? awayLineup;
  final bool isEdit;

  const CreateEditLineupScreen({
    Key? key,
    required this.match,
    this.homeLineup,
    this.awayLineup,
    required this.isEdit,
  }) : super(key: key);

  @override
  _CreateEditLineupScreenState createState() => _CreateEditLineupScreenState();
}

class _CreateEditLineupScreenState extends State<CreateEditLineupScreen> {
  List<Player> _selectedHomePlayers = [];
  List<Player> _selectedAwayPlayers = [];
  List<Player> _availableHomePlayers = [];
  List<Player> _availableAwayPlayers = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadPlayers();
    // Initialize selected players from existing lineups
    if (widget.homeLineup != null) {
      _selectedHomePlayers = List.from(widget.homeLineup!.players);
    }
    if (widget.awayLineup != null) {
      _selectedAwayPlayers = List.from(widget.awayLineup!.players);
    }
  }

  Future<void> _loadPlayers() async {
    try {
      // Get team IDs first
      final teams = await LineupService.fetchTeamsForMatch(widget.match.id);

      Team? homeTeam;
      Team? awayTeam;

      // Find home and away teams by name
      for (var team in teams) {
        if (team.name == widget.match.homeTeam) {
          homeTeam = team;
        } else if (team.name == widget.match.awayTeam) {
          awayTeam = team;
        }
      }

      if (homeTeam == null || awayTeam == null) {
        throw Exception('Could not find team information');
      }

      // Load players using team IDs (not codes!)
      final homePlayers = await LineupService.fetchPlayersByTeam(homeTeam.id);
      final awayPlayers = await LineupService.fetchPlayersByTeam(awayTeam.id);

      setState(() {
        _availableHomePlayers = homePlayers;
        _availableAwayPlayers = awayPlayers;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading players: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _toggleHomePlayer(Player player) {
    setState(() {
      if (_selectedHomePlayers.any((p) => p.id == player.id)) {
        _selectedHomePlayers.removeWhere((p) => p.id == player.id);
      } else if (_selectedHomePlayers.length < 11) {
        _selectedHomePlayers.add(player);
      } else {
        _showSnackBar('Maksimal 11 pemain untuk ${widget.match.homeTeam}');
      }
    });
  }

  void _toggleAwayPlayer(Player player) {
    setState(() {
      if (_selectedAwayPlayers.any((p) => p.id == player.id)) {
        _selectedAwayPlayers.removeWhere((p) => p.id == player.id);
      } else if (_selectedAwayPlayers.length < 11) {
        _selectedAwayPlayers.add(player);
      } else {
        _showSnackBar('Maksimal 11 pemain untuk ${widget.match.awayTeam}');
      }
    });
  }

  Future<void> _saveLineup() async {
    // Validate selections
    if (_selectedHomePlayers.length != 11) {
      _showSnackBar('${widget.match.homeTeam} harus memiliki tepat 11 pemain (${_selectedHomePlayers.length} terpilih)');
      return;
    }

    if (_selectedAwayPlayers.length != 11) {
      _showSnackBar('${widget.match.awayTeam} harus memiliki tepat 11 pemain (${_selectedAwayPlayers.length} terpilih)');
      return;
    }

    try {
      bool success = true;
      String? errorMessage;

      if (widget.isEdit) {
        // Update existing lineups
        if (widget.homeLineup != null) {
          try {
            success = await LineupService.updateLineup(
              lineupId: widget.homeLineup!.id,
              playerIds: _selectedHomePlayers.map((p) => p.id).toList(),
            );
            if (!success) errorMessage = 'Failed to update home lineup';
          } catch (e) {
            success = false;
            errorMessage = e.toString();
          }
        }

        if (success && widget.awayLineup != null) {
          try {
            success = await LineupService.updateLineup(
              lineupId: widget.awayLineup!.id,
              playerIds: _selectedAwayPlayers.map((p) => p.id).toList(),
            );
            if (!success && errorMessage == null) errorMessage = 'Failed to update away lineup';
          } catch (e) {
            success = false;
            errorMessage = e.toString();
          }
        }
      } else {
        // Create new lineups - perlu team ID, bukan code
        final teams = await LineupService.fetchTeamsForMatch(widget.match.id);
        Team? homeTeam = teams.firstWhere((t) => t.name == widget.match.homeTeam);
        Team? awayTeam = teams.firstWhere((t) => t.name == widget.match.awayTeam);

        // Get team codes from match data
        final homeTeamCode = widget.match.homeTeamCode;
        final awayTeamCode = widget.match.awayTeamCode;

        // Create home lineup
        try {
          success = await LineupService.createLineup(
            matchId: widget.match.id,
            teamCode: homeTeamCode,
            playerIds: _selectedHomePlayers.map((p) => p.id).toList(),
          );
          if (!success) errorMessage = 'Failed to create home lineup';
        } catch (e) {
          success = false;
          errorMessage = e.toString();
        }

        // Create away lineup
        if (success) {
          try {
            success = await LineupService.createLineup(
              matchId: widget.match.id,
              teamCode: awayTeamCode,
              playerIds: _selectedAwayPlayers.map((p) => p.id).toList(),
            );
            if (!success && errorMessage == null) errorMessage = 'Failed to create away lineup';
          } catch (e) {
            success = false;
            errorMessage = e.toString();
          }
        }
      }

      if (success) {
        _showSnackBar(widget.isEdit ? 'Lineup berhasil diupdate!' : 'Lineup berhasil dibuat!');
        Navigator.pop(context, true);
      } else {
        _showSnackBar(errorMessage ?? 'Gagal menyimpan lineup');
      }
    } catch (e) {
      print('Error saving lineup: $e');
      _showSnackBar('Error: ${e.toString()}');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: message.toLowerCase().contains('error') || message.toLowerCase().contains('gagal')
              ? Colors.red
              : Colors.green[600],
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green[700]!),
          ),
          SizedBox(height: 16),
          Text(
            'Loading Players...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            SizedBox(height: 16),
            Text(
              'Failed to Load Players',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              _error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadPlayers,
              child: Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamSelectionSection({
    required String teamName,
    required String teamCode,
    required List<Player> availablePlayers,
    required List<Player> selectedPlayers,
    required Function(Player) onPlayerTapped,
  }) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  teamName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: selectedPlayers.length == 11 ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${selectedPlayers.length}/11',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Pilih 11 pemain:',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 12),

            if (availablePlayers.isEmpty)
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'Tidak ada data pemain untuk tim ini',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 3.5,
                ),
                itemCount: availablePlayers.length,
                itemBuilder: (context, index) {
                  final player = availablePlayers[index];
                  final isSelected = selectedPlayers.any((p) => p.id == player.id);

                  return _buildPlayerSelectionItem(player, isSelected, () {
                    onPlayerTapped(player);
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerSelectionItem(
      Player player,
      bool isSelected,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.green[50] : Colors.grey[50],
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            // Player Number
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected ? Colors.green : Colors.grey[400],
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  player.nomor.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),

            // Player Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    player.nama,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (player.asal.isNotEmpty)
                    Text(
                      player.asal,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),

            // Selection Indicator
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? Colors.green : Colors.grey[400],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEdit ? 'Edit Lineup' : 'Create Lineup',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green[700],
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _error.isNotEmpty
          ? _buildErrorState()
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Match Info
            Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Lineup for ${widget.match.homeTeam} vs ${widget.match.awayTeam}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Home: ${widget.match.homeTeam}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      'Away: ${widget.match.awayTeam}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${_formatDate(widget.match.matchDate)} • ${widget.match.stadium}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Home Team Selection
            _buildTeamSelectionSection(
              teamName: widget.match.homeTeam,
              teamCode: widget.match.homeTeamCode,
              availablePlayers: _availableHomePlayers,
              selectedPlayers: _selectedHomePlayers,
              onPlayerTapped: _toggleHomePlayer,
            ),

            SizedBox(height: 16),

            // Away Team Selection
            _buildTeamSelectionSection(
              teamName: widget.match.awayTeam,
              teamCode: widget.match.awayTeamCode,
              availablePlayers: _availableAwayPlayers,
              selectedPlayers: _selectedAwayPlayers,
              onPlayerTapped: _toggleAwayPlayer,
            ),

            SizedBox(height: 24),

            // Validation Summary
            if (_selectedHomePlayers.length != 11 || _selectedAwayPlayers.length != 11)
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.orange[600], size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Perhatian:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[800],
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '${widget.match.homeTeam}: ${_selectedHomePlayers.length}/11 pemain\n'
                                '${widget.match.awayTeam}: ${_selectedAwayPlayers.length}/11 pemain',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            SizedBox(height: 30),
          ],
        ),
      ),
      persistentFooterButtons: [
        // Action Buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _saveLineup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  widget.isEdit ? 'UPDATE LINEUP' : 'SAVE LINEUP',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'CANCEL',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    return '${days[date.weekday - 1]} – ${date.day} ${months[date.month - 1]} ${date.year}';
  }
}