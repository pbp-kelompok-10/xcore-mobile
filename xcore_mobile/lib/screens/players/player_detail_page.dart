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
  bool _isAdmin = PlayerService.getIsAdmin();

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Player updated successfully')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _deletePlayer() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Player'),
        content: const Text('Are you sure you want to delete this player?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);

              try {
                await PlayerDetailService.deletePlayer(widget.playerId);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Player deleted successfully'),
                    ),
                  );
                  Navigator.pop(context, true);
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  setState(() => _isLoading = false);
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Player Details'),
        backgroundColor: Colors.green[700],
        actions: [
          if (!_isEditing && _isAdmin)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (_isEditing && _isAdmin)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _isEditing = false),
            ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _playerDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No player data found'));
          }

          final playerData = snapshot.data!;
          if (!_isEditing) {
            _initializeControllers(playerData);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Player Name
                _buildField('Nama', _namaController, enabled: _isEditing),
                const SizedBox(height: 16),

                // Origin
                _buildField('Asal', _asalController, enabled: _isEditing),
                const SizedBox(height: 16),

                // Age
                _buildField(
                  'Umur',
                  _umurController,
                  enabled: _isEditing,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                // Jersey Number
                _buildField(
                  'Nomor Jersey',
                  _nomorController,
                  enabled: _isEditing,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                // Team Name
                if (_isEditing)
                  FutureBuilder<List<Team>>(
                    future: _teams,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('No teams available');
                      }
                      final teams = snapshot.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tim',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
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
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  )
                else
                  _buildField(
                    'Tim',
                    TextEditingController(text: _selectedTeamName ?? ''),
                    enabled: false,
                  ),
                const SizedBox(height: 32),

                // Action Buttons (only show if admin)
                if (_isEditing && _isAdmin)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _savePlayer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text('Save'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _deletePlayer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('Delete'),
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            filled: !enabled,
            fillColor: !enabled ? Colors.grey[200] : null,
          ),
        ),
      ],
    );
  }
}
