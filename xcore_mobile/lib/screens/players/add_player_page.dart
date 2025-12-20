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

  // Warna konsisten dengan PlayersPage
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
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Please fill all required fields'),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
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
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('✓ Player created successfully'),
              backgroundColor: primaryColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('❌ Error: $e'),
              backgroundColor: Colors.red[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        title: Text(
          'Add Player',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: whiteColor,
            fontSize: 18,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: whiteColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
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
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: lightBgColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.person_add,
                      color: primaryColor,
                      size: 28,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'New Player',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: darkTextColor,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Fill in the player details below',
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
            ),
            SizedBox(height: 20),

            // Form Card
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Player Name
                  _buildField(
                    'Player Name',
                    _namaController,
                    icon: Icons.person,
                    required: true,
                  ),
                  SizedBox(height: 16),

                  // Origin
                  _buildField(
                    'Origin',
                    _asalController,
                    icon: Icons.public,
                    required: true,
                  ),
                  SizedBox(height: 16),

                  // Age and Jersey Number Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildField(
                          'Age',
                          _umurController,
                          keyboardType: TextInputType.number,
                          icon: Icons.calendar_today,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildField(
                          'Jersey No.',
                          _nomorController,
                          keyboardType: TextInputType.number,
                          icon: Icons.tag,
                          required: true,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Team Selection
                  FutureBuilder<List<Team>>(
                    future: _teams,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          padding: EdgeInsets.all(20),
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Error: ${snapshot.error}',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.warning_amber, color: Colors.orange),
                              SizedBox(width: 8),
                              Text(
                                'No teams available',
                                style: TextStyle(color: Colors.orange[800]),
                              ),
                            ],
                          ),
                        );
                      }

                      final teams = snapshot.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.groups, size: 16, color: mutedTextColor),
                              SizedBox(width: 6),
                              Text(
                                'Team',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: darkTextColor,
                                ),
                              ),
                              SizedBox(width: 4),
                              Text(
                                '*',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            value: _selectedTeamId,
                            items: teams.map((team) {
                              return DropdownMenuItem(
                                value: team.id,
                                child: Text(
                                  team.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: darkTextColor,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedTeamId = value);
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: mutedTextColor.withOpacity(0.3),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: primaryColor,
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: mutedTextColor.withOpacity(0.3),
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              hintText: 'Select a team',
                              hintStyle: TextStyle(
                                color: mutedTextColor,
                                fontSize: 14,
                              ),
                              fillColor: scaffoldBgColor,
                              filled: true,
                            ),
                            dropdownColor: whiteColor,
                            icon: Icon(Icons.arrow_drop_down, color: primaryColor),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Create Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createPlayer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: whiteColor,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                  disabledBackgroundColor: mutedTextColor.withOpacity(0.5),
                ),
                child: _isLoading
                    ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(whiteColor),
                  ),
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Create Player',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
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
        IconData? icon,
        bool required = false,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: mutedTextColor),
              SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: darkTextColor,
              ),
            ),
            if (required) ...[
              SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(fontSize: 14, color: darkTextColor),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: mutedTextColor.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: primaryColor, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: mutedTextColor.withOpacity(0.3)),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            fillColor: scaffoldBgColor,
            filled: true,
            hintStyle: TextStyle(color: mutedTextColor),
          ),
        ),
      ],
    );
  }
}