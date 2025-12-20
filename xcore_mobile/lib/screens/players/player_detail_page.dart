import 'package:flutter/material.dart';
import 'player_detail_service.dart';
import '../teams/team_service.dart';
import '../../models/player_entry.dart';
import '../../models/team_entry.dart';
import 'player_service.dart';

class PlayerDetailPage extends StatefulWidget {
  final int playerId;

  const PlayerDetailPage({Key? key, required this.playerId}) : super(key: key);

  @override
  State<PlayerDetailPage> createState() => _PlayerDetailPageState();
}

class _PlayerDetailPageState extends State<PlayerDetailPage> {
  late Future<Map<String, dynamic>> _playerDetails;
  late TextEditingController _namaController;
  late TextEditingController _asalController;
  late TextEditingController _umurController;
  late TextEditingController _nomorController;
  late Future<List<Team>> _teams;

  String? _selectedTeamName;

  bool _isEditing = false;
  bool _isLoading = false;
  bool _isAdmin = false;
  String? _error;

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
    _playerDetails = PlayerDetailService.getPlayerDetails(widget.playerId);
    _teams = TeamService.getTeams();
    _namaController = TextEditingController();
    _asalController = TextEditingController();
    _umurController = TextEditingController();
    _nomorController = TextEditingController();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _asalController.dispose();
    _umurController.dispose();
    _nomorController.dispose();
    super.dispose();
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

  void _initializeControllers(Map<String, dynamic> playerData) {
    _namaController.text = playerData['nama'] ?? '';
    _asalController.text = playerData['asal'] ?? '';
    _umurController.text = playerData['umur']?.toString() ?? '';
    _nomorController.text = playerData['nomor']?.toString() ?? '';
    _selectedTeamName = playerData['team_name'];
  }

  void _savePlayer() async {
    if (_namaController.text.isEmpty ||
        _asalController.text.isEmpty ||
        _nomorController.text.isEmpty) {
      _showSnackBar('⚠️ Please fill all required fields', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final umur = _umurController.text.isEmpty
          ? null
          : int.parse(_umurController.text);
      await PlayerDetailService.updatePlayer(
        playerId: widget.playerId,
        nama: _namaController.text,
        asal: _asalController.text,
        umur: umur,
        nomor: int.parse(_nomorController.text),
        teamName: _selectedTeamName,
      );

      if (mounted) {
        _showSnackBar('✅ Player updated successfully', isError: false);
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('❌ Error: $e', isError: true);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _deletePlayer() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: whiteColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          'Delete Player',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: darkTextColor,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this player?',
          style: TextStyle(
            color: mutedTextColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: mutedTextColor,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);

              try {
                await PlayerDetailService.deletePlayer(widget.playerId);
                if (mounted) {
                  _showSnackBar('✅ Player deleted successfully', isError: false);
                  Navigator.pop(context, true);
                }
              } catch (e) {
                if (mounted) {
                  _showSnackBar('❌ Error: $e', isError: true);
                  setState(() => _isLoading = false);
                }
              }
            },
            child: Text(
              'Delete',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red[600] : primaryColor,
          duration: Duration(seconds: 2),
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
            'Loading Player Details...',
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

  Widget _buildErrorState(String error) {
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
                'Error Loading Player',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 8),
              Text(
                error,
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
          'Player Details',
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
        actions: [
          if (!_isEditing && _isAdmin)
            IconButton(
              icon: Icon(Icons.edit, color: whiteColor),
              onPressed: () => setState(() => _isEditing = true),
              tooltip: 'Edit Player',
            ),
          if (_isEditing && _isAdmin)
            IconButton(
              icon: Icon(Icons.close, color: whiteColor),
              onPressed: () => setState(() => _isEditing = false),
              tooltip: 'Cancel Edit',
            ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _playerDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          if (!snapshot.hasData) {
            return _buildErrorState('No player data found');
          }

          final playerData = snapshot.data!;
          if (!_isEditing) {
            _initializeControllers(playerData);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Player Info Card
                Container(
                  padding: EdgeInsets.all(20),
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
                    children: [
                      // Header with icon
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isEditing ? Icons.edit : Icons.person,
                              size: 24,
                              color: primaryColor,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isEditing ? 'Edit Player' : 'Player Information',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: darkTextColor,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  _isEditing
                                      ? 'Update player information'
                                      : 'View player details',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: mutedTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 24),
                      Divider(height: 1, color: mutedTextColor.withOpacity(0.3)),
                      SizedBox(height: 24),

                      // Player Name
                      _buildField('Name', _namaController,
                          enabled: _isEditing,
                          icon: Icons.badge),
                      const SizedBox(height: 20),

                      // Origin
                      _buildField('Origin', _asalController,
                          enabled: _isEditing,
                          icon: Icons.public),
                      const SizedBox(height: 20),

                      // Age
                      _buildField(
                        'Age',
                        _umurController,
                        enabled: _isEditing,
                        keyboardType: TextInputType.number,
                        icon: Icons.calendar_today,
                      ),
                      const SizedBox(height: 20),

                      // Jersey Number
                      _buildField(
                        'Jersey Number',
                        _nomorController,
                        enabled: _isEditing,
                        keyboardType: TextInputType.number,
                        icon: Icons.sports,
                      ),
                      const SizedBox(height: 20),

                      // Team Name
                      if (_isEditing)
                        FutureBuilder<List<Team>>(
                          future: _teams,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                                  strokeWidth: 2,
                                ),
                              );
                            }
                            if (snapshot.hasError) {
                              return Text(
                                'Error loading teams: ${snapshot.error}',
                                style: TextStyle(color: Colors.red, fontSize: 12),
                              );
                            }
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return Text(
                                'No teams available',
                                style: TextStyle(color: mutedTextColor),
                              );
                            }
                            final teams = snapshot.data!;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.group, size: 18, color: primaryColor),
                                    SizedBox(width: 8),
                                    Text(
                                      'Team',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: darkTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                DropdownButtonFormField<String>(
                                  value: _selectedTeamName,
                                  items: teams.map((team) {
                                    return DropdownMenuItem(
                                      value: team.name,
                                      child: Text(team.name),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() => _selectedTeamName = value);
                                  },
                                  decoration: InputDecoration(
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
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    fillColor: scaffoldBgColor,
                                    filled: true,
                                  ),
                                ),
                              ],
                            );
                          },
                        )
                      else
                        _buildField(
                          'Team',
                          TextEditingController(text: _selectedTeamName ?? ''),
                          enabled: false,
                          icon: Icons.group,
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Action Buttons (only show if admin and editing)
                if (_isEditing && _isAdmin)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _savePlayer,
                          icon: _isLoading
                              ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(whiteColor),
                            ),
                          )
                              : Icon(Icons.save, size: 20),
                          label: Text(
                            _isLoading ? 'Saving...' : 'Save Changes',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: whiteColor,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            disabledBackgroundColor: mutedTextColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _deletePlayer,
                          icon: Icon(Icons.delete, size: 20),
                          label: Text(
                            'Delete',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[600],
                            foregroundColor: whiteColor,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            disabledBackgroundColor: mutedTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildField(
      String label,
      TextEditingController controller, {
        bool enabled = true,
        TextInputType keyboardType = TextInputType.text,
        IconData? icon,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: primaryColor),
              SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: darkTextColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          style: TextStyle(fontSize: 14),
          decoration: InputDecoration(
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
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: mutedTextColor.withOpacity(0.2)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            filled: true,
            fillColor: enabled ? scaffoldBgColor : lightBgColor,
          ),
        ),
      ],
    );
  }
}