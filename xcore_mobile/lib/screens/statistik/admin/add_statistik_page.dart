import 'package:flutter/material.dart';
import 'package:xcore_mobile/screens/statistik/statistik_service.dart';

class AddStatistikPage extends StatefulWidget {
  final String matchId;
  final String homeTeam;
  final String awayTeam;
  final Function() onStatistikAdded;

  const AddStatistikPage({
    super.key,
    required this.matchId,
    required this.homeTeam,
    required this.awayTeam,
    required this.onStatistikAdded,
  });

  @override
  _AddStatistikPageState createState() => _AddStatistikPageState();
}

class _AddStatistikPageState extends State<AddStatistikPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Gunakan TextEditingController untuk semua field
  final TextEditingController _homePassesController = TextEditingController();
  final TextEditingController _awayPassesController = TextEditingController();
  final TextEditingController _homeShotsController = TextEditingController();
  final TextEditingController _awayShotsController = TextEditingController();
  final TextEditingController _homeShotsOnTargetController = TextEditingController();
  final TextEditingController _awayShotsOnTargetController = TextEditingController();
  final TextEditingController _homePossessionController = TextEditingController();
  final TextEditingController _awayPossessionController = TextEditingController();
  final TextEditingController _homeRedCardsController = TextEditingController();
  final TextEditingController _awayRedCardsController = TextEditingController();
  final TextEditingController _homeYellowCardsController = TextEditingController();
  final TextEditingController _awayYellowCardsController = TextEditingController();
  final TextEditingController _homeOffsidesController = TextEditingController();
  final TextEditingController _awayOffsidesController = TextEditingController();
  final TextEditingController _homeCornersController = TextEditingController();
  final TextEditingController _awayCornersController = TextEditingController();

  @override
  void dispose() {
    // Dispose semua controllers
    _homePassesController.dispose();
    _awayPassesController.dispose();
    _homeShotsController.dispose();
    _awayShotsController.dispose();
    _homeShotsOnTargetController.dispose();
    _awayShotsOnTargetController.dispose();
    _homePossessionController.dispose();
    _awayPossessionController.dispose();
    _homeRedCardsController.dispose();
    _awayRedCardsController.dispose();
    _homeYellowCardsController.dispose();
    _awayYellowCardsController.dispose();
    _homeOffsidesController.dispose();
    _awayOffsidesController.dispose();
    _homeCornersController.dispose();
    _awayCornersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Statistik - ${widget.homeTeam} vs ${widget.awayTeam}'),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Header info match
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Match: ${widget.homeTeam} vs ${widget.awayTeam}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Match ID: ${widget.matchId}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Catatan: Home Score, Away Score, Stadium, dan Match Date diambil dari data match',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 20),
              
              // Statistics fields
              _buildNumberField('Home Passes', _homePassesController),
              _buildNumberField('Away Passes', _awayPassesController),
              _buildNumberField('Home Shots', _homeShotsController),
              _buildNumberField('Away Shots', _awayShotsController),
              _buildNumberField('Home Shots on Target', _homeShotsOnTargetController),
              _buildNumberField('Away Shots on Target', _awayShotsOnTargetController),
              _buildNumberField('Home Possession (%)', _homePossessionController, isDouble: true),
              _buildNumberField('Away Possession (%)', _awayPossessionController, isDouble: true),
              _buildNumberField('Home Red Cards', _homeRedCardsController),
              _buildNumberField('Away Red Cards', _awayRedCardsController),
              _buildNumberField('Home Yellow Cards', _homeYellowCardsController),
              _buildNumberField('Away Yellow Cards', _awayYellowCardsController),
              _buildNumberField('Home Offsides', _homeOffsidesController),
              _buildNumberField('Away Offsides', _awayOffsidesController),
              _buildNumberField('Home Corners', _homeCornersController),
              _buildNumberField('Away Corners', _awayCornersController),
              
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Tambah Statistik'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberField(String label, TextEditingController controller, {bool isDouble = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        keyboardType: TextInputType.numberWithOptions(decimal: isDouble),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Field ini harus diisi';
          }
          if (isDouble) {
            if (double.tryParse(value) == null) {
              return 'Masukkan angka yang valid';
            }
            final doubleVal = double.parse(value);
            if (label.contains('Possession') && (doubleVal < 0 || doubleVal > 100)) {
              return 'Possession harus antara 0-100%';
            }
          } else {
            if (int.tryParse(value) == null) {
              return 'Masukkan angka bulat yang valid';
            }
            final intVal = int.parse(value);
            if (intVal < 0) {
              return 'Nilai tidak boleh negatif';
            }
          }
          return null;
        },
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Data yang dikirim SESUAI dengan model Django Statistik
      final Map<String, dynamic> formData = {
        'match': widget.matchId,
        'home_passes': int.tryParse(_homePassesController.text) ?? 0,
        'away_passes': int.tryParse(_awayPassesController.text) ?? 0,
        'home_shots': int.tryParse(_homeShotsController.text) ?? 0,
        'away_shots': int.tryParse(_awayShotsController.text) ?? 0,
        'home_shots_on_target': int.tryParse(_homeShotsOnTargetController.text) ?? 0,
        'away_shots_on_target': int.tryParse(_awayShotsOnTargetController.text) ?? 0,
        'home_possession': double.tryParse(_homePossessionController.text) ?? 50.0,
        'away_possession': double.tryParse(_awayPossessionController.text) ?? 50.0,
        'home_red_cards': int.tryParse(_homeRedCardsController.text) ?? 0,
        'away_red_cards': int.tryParse(_awayRedCardsController.text) ?? 0,
        'home_yellow_cards': int.tryParse(_homeYellowCardsController.text) ?? 0,
        'away_yellow_cards': int.tryParse(_awayYellowCardsController.text) ?? 0,
        'home_offsides': int.tryParse(_homeOffsidesController.text) ?? 0,
        'away_offsides': int.tryParse(_awayOffsidesController.text) ?? 0,
        'home_corners': int.tryParse(_homeCornersController.text) ?? 0,
        'away_corners': int.tryParse(_awayCornersController.text) ?? 0,
      };
      
      try {
        final success = await StatistikService.createStatistik(formData);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Statistik berhasil ditambahkan'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            )
          );
          widget.onStatistikAdded();
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menambahkan statistik'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            )
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          )
        );
      }
    }
  }
}