// lineup/create_edit_lineup_screen.dart
import 'package:flutter/material.dart';
import 'package:xcore_mobile/services/lineup_service.dart';
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
        _showSnackBar('⚠️ Maksimal 11 pemain untuk ${widget.match.homeTeam}');
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
        _showSnackBar('⚠️ Maksimal 11 pemain untuk ${widget.match.awayTeam}');
      }
    });
  }

  Future<void> _saveLineup() async {
    // Validate selections
    if (_selectedHomePlayers.length != 11) {
      _showSnackBar('⚠️ ${widget.match.homeTeam} harus memiliki tepat 11 pemain (${_selectedHomePlayers.length} terpilih)');
      return;
    }

    if (_selectedAwayPlayers.length != 11) {
      _showSnackBar('⚠️ ${widget.match.awayTeam} harus memiliki tepat 11 pemain (${_selectedAwayPlayers.length} terpilih)');
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
        _showSnackBar(widget.isEdit ? '✅ Lineup berhasil diupdate!' : '✅ Lineup berhasil dibuat!');
        Navigator.pop(context, true);
      } else {
        _showSnackBar('❌ ${errorMessage ?? 'Gagal menyimpan lineup'}');
      }
    } catch (e) {
      print('Error saving lineup: $e');
      _showSnackBar('❌ Error: ${e.toString()}');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: message.contains('❌') || message.contains('⚠️')
              ? Colors.red[600]
              : primaryColor,
          duration: Duration(seconds: 3),
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
        padding: EdgeInsets.all(24),
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

  Widget _buildTeamSelectionSection({
    required String teamName,
    required String teamCode,
    required List<Player> availablePlayers,
    required List<Player> selectedPlayers,
    required Function(Player) onPlayerTapped,
  }) {
    return Card(
      elevation: 2,
      color: whiteColor,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.sports_soccer, size: 20, color: primaryColor),
                SizedBox(width: 8),
                Text(
                  teamName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: darkTextColor,
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: selectedPlayers.length == 11 ? primaryColor : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${selectedPlayers.length}/11',
                    style: TextStyle(
                      color: whiteColor,
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
                color: mutedTextColor,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 12),

            if (availablePlayers.isEmpty)
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: scaffoldBgColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: primaryColor.withOpacity(0.2)),
                ),
                child: Center(
                  child: Text(
                    'Tidak ada data pemain untuk tim ini',
                    style: TextStyle(color: mutedTextColor),
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
          color: isSelected ? primaryColor.withOpacity(0.1) : scaffoldBgColor,
          border: Border.all(
            color: isSelected ? primaryColor : mutedTextColor.withOpacity(0.3),
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
                color: isSelected ? primaryColor : mutedTextColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  player.nomor.toString(),
                  style: TextStyle(
                    color: whiteColor,
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
                      color: darkTextColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (player.asal.isNotEmpty)
                    Text(
                      player.asal,
                      style: TextStyle(
                        fontSize: 11,
                        color: mutedTextColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),

            // Selection Indicator
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? primaryColor : mutedTextColor,
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
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        title: Text(
          widget.isEdit ? 'Edit Lineup' : 'Create Lineup',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: whiteColor,
            fontSize: 18,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: whiteColor),
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
              color: whiteColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.stadium, size: 20, color: primaryColor),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${widget.match.homeTeam} vs ${widget.match.awayTeam}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: darkTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Divider(height: 1, color: mutedTextColor.withOpacity(0.3)),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.home, size: 16, color: mutedTextColor),
                        SizedBox(width: 6),
                        Text(
                          'Home: ${widget.match.homeTeam}',
                          style: TextStyle(
                            fontSize: 14,
                            color: darkTextColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.flight_takeoff, size: 16, color: mutedTextColor),
                        SizedBox(width: 6),
                        Text(
                          'Away: ${widget.match.awayTeam}',
                          style: TextStyle(
                            fontSize: 14,
                            color: darkTextColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.calendar_today, size: 12, color: primaryColor),
                          SizedBox(width: 4),
                          Text(
                            '${_formatDate(widget.match.matchDate)} • ${widget.match.stadium}',
                            style: TextStyle(
                              fontSize: 11,
                              color: primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
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
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
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
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(height: 4),
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
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: whiteColor,
            border: Border(
              top: BorderSide(color: primaryColor.withOpacity(0.2)),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveLineup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: whiteColor,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    widget.isEdit ? 'UPDATE LINEUP' : 'SAVE LINEUP',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
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
                    side: BorderSide(color: mutedTextColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'CANCEL',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: mutedTextColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
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