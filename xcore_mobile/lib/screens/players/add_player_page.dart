import 'package:flutter/material.dart';
import 'player_create_service.dart';
import '../teams/team_service.dart';
import '../../models/team_entry.dart';

class AddPlayerPage extends StatefulWidget {
  const AddPlayerPage({Key? key}) : super(key: key);

  @override
  State<AddPlayerPage> createState() => _AddPlayerPageState();
}

class _AddPlayerPageState extends State<AddPlayerPage> {
  late TextEditingController _namaController;
  late TextEditingController _asalController;
  late TextEditingController _umurController;
  late TextEditingController _nomorController;
  late Future<List<Team>> _teams;

  int? _selectedTeamId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
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

  void _createPlayer() async {
    if (_namaController.text.isEmpty ||
        _asalController.text.isEmpty ||
        _nomorController.text.isEmpty ||
        _selectedTeamId == null) {
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

      await PlayerCreateService.createPlayer(
        teamId: _selectedTeamId!,
        nama: _namaController.text,
        asal: _asalController.text,
        umur: umur,
        nomor: int.parse(_nomorController.text),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Player created successfully')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Player'),
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Player Name
            _buildField('Nama', _namaController),
            const SizedBox(height: 16),

            // Origin
            _buildField('Asal', _asalController),
            const SizedBox(height: 16),

            // Age
            _buildField(
              'Umur',
              _umurController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Jersey Number
            _buildField(
              'Nomor Jersey',
              _nomorController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Team Selection
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
                    DropdownButtonFormField<int>(
                      value: _selectedTeamId,
                      items: teams.map((team) {
                        return DropdownMenuItem(
                          value: team.id,
                          child: Text(team.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedTeamId = value);
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        hintText: 'Select a team',
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),

            // Create Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createPlayer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
                    : const Text('Create Player'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
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
          keyboardType: keyboardType,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
