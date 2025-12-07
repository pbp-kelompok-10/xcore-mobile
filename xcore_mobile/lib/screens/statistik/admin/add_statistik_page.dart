import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
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
  bool _isSubmitting = false;
  
  // Home team controllers
  final TextEditingController _homePassesController = TextEditingController();
  final TextEditingController _homeShotsController = TextEditingController();
  final TextEditingController _homeShotsOnTargetController = TextEditingController();
  final TextEditingController _homePossessionController = TextEditingController();
  final TextEditingController _homeRedCardsController = TextEditingController();
  final TextEditingController _homeYellowCardsController = TextEditingController();
  final TextEditingController _homeOffsidesController = TextEditingController();
  final TextEditingController _homeCornersController = TextEditingController();
  
  // Away team controllers
  final TextEditingController _awayPassesController = TextEditingController();
  final TextEditingController _awayShotsController = TextEditingController();
  final TextEditingController _awayShotsOnTargetController = TextEditingController();
  final TextEditingController _awayPossessionController = TextEditingController();
  final TextEditingController _awayRedCardsController = TextEditingController();
  final TextEditingController _awayYellowCardsController = TextEditingController();
  final TextEditingController _awayOffsidesController = TextEditingController();
  final TextEditingController _awayCornersController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set nilai default
    _homePassesController.text = '0';
    _awayPassesController.text = '0';
    _homeShotsController.text = '0';
    _awayShotsController.text = '0';
    _homeShotsOnTargetController.text = '0';
    _awayShotsOnTargetController.text = '0';
    _homePossessionController.text = '50';
    _awayPossessionController.text = '50';
    _homeRedCardsController.text = '0';
    _awayRedCardsController.text = '0';
    _homeYellowCardsController.text = '0';
    _awayYellowCardsController.text = '0';
    _homeOffsidesController.text = '0';
    _awayOffsidesController.text = '0';
    _homeCornersController.text = '0';
    _awayCornersController.text = '0';
  }

  @override
  void dispose() {
    // Home team
    _homePassesController.dispose();
    _homeShotsController.dispose();
    _homeShotsOnTargetController.dispose();
    _homePossessionController.dispose();
    _homeRedCardsController.dispose();
    _homeYellowCardsController.dispose();
    _homeOffsidesController.dispose();
    _homeCornersController.dispose();
    
    // Away team
    _awayPassesController.dispose();
    _awayShotsController.dispose();
    _awayShotsOnTargetController.dispose();
    _awayPossessionController.dispose();
    _awayRedCardsController.dispose();
    _awayYellowCardsController.dispose();
    _awayOffsidesController.dispose();
    _awayCornersController.dispose();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Statistik'),
        backgroundColor: Colors.green[700],
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isSubmitting
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.green[700]),
                  SizedBox(height: 16),
                  Text(
                    'Menyimpan statistik...',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Match info (tanpa skor)
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[100]!),
                      ),
                      child: Column(
                        children: [
                          // Header "MATCH"
                          Text(
                            'MATCH',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
                              letterSpacing: 1.0,
                            ),
                          ),
                          SizedBox(height: 12),
                          
                          // Team names dengan VS di tengah
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Home team
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      widget.homeTeam,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green[800],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 4),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.green[100],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'HOME',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.green[700],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // VS di tengah
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                child: Text(
                                  'VS',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[700],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                              
                              // Away team
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      widget.awayTeam,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[800],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 4),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[100],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'AWAY',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.blue[700],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    Text(
                      'Match ID: ${widget.matchId}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    
                    SizedBox(height: 24),
                    
                    // Statistics form
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Home team column
                        Expanded(
                          child: _buildTeamColumn(
                            teamName: widget.homeTeam,
                            isHome: true,
                            passesController: _homePassesController,
                            shotsController: _homeShotsController,
                            shotsOnTargetController: _homeShotsOnTargetController,
                            possessionController: _homePossessionController,
                            redCardsController: _homeRedCardsController,
                            yellowCardsController: _homeYellowCardsController,
                            offsidesController: _homeOffsidesController,
                            cornersController: _homeCornersController,
                          ),
                        ),
                        
                        SizedBox(width: 16),
                        
                        // Away team column
                        Expanded(
                          child: _buildTeamColumn(
                            teamName: widget.awayTeam,
                            isHome: false,
                            passesController: _awayPassesController,
                            shotsController: _awayShotsController,
                            shotsOnTargetController: _awayShotsOnTargetController,
                            possessionController: _awayPossessionController,
                            redCardsController: _awayRedCardsController,
                            yellowCardsController: _awayYellowCardsController,
                            offsidesController: _awayOffsidesController,
                            cornersController: _awayCornersController,
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 24),
                    
                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: _isSubmitting 
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(Icons.save, size: 18),
                        label: Text(
                          _isSubmitting ? 'MENYIMPAN...' : 'SIMPAN STATISTIK',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: _isSubmitting ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          disabledBackgroundColor: Colors.green[400],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTeamColumn({
    required String teamName,
    required bool isHome,
    required TextEditingController passesController,
    required TextEditingController shotsController,
    required TextEditingController shotsOnTargetController,
    required TextEditingController possessionController,
    required TextEditingController redCardsController,
    required TextEditingController yellowCardsController,
    required TextEditingController offsidesController,
    required TextEditingController cornersController,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isHome ? Colors.green[200]! : Colors.blue[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Team header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isHome ? Colors.green[50] : Colors.blue[50],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isHome ? 'HOME' : 'AWAY',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isHome ? Colors.green[800] : Colors.blue[800],
                    letterSpacing: 0.5,
                  ),
                ),
                Expanded(
                  child: Text(
                    teamName,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 16),
          
          // Statistics fields dengan layout yang diperbaiki
          _buildStatField('Passes', passesController, Icons.swap_horiz),
          SizedBox(height: 12),
          _buildStatField('Shots', shotsController, Icons.sports_soccer),
          SizedBox(height: 12),
          _buildStatField('Shots on Target', shotsOnTargetController, Icons.flag),
          SizedBox(height: 12),
          _buildStatField('Possession %', possessionController, Icons.pie_chart, isPercentage: true),
          SizedBox(height: 12),
          _buildStatField('Red Cards', redCardsController, Icons.error),
          SizedBox(height: 12),
          _buildStatField('Yellow Cards', yellowCardsController, Icons.warning),
          SizedBox(height: 12),
          _buildStatField('Offsides', offsidesController, Icons.gps_not_fixed),
          SizedBox(height: 12),
          _buildStatField('Corners', cornersController, Icons.circle),
        ],
      ),
    );
  }

  Widget _buildStatField(
    String label, 
    TextEditingController controller, 
    IconData icon,
    {bool isPercentage = false}
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[300]!),
        color: Colors.grey[50],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 6),
                  // Input controls dengan posisi yang lebih baik
                  Row(
                    children: [
                      // Decrement button
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.remove, size: 16),
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            int currentValue = int.tryParse(controller.text) ?? 0;
                            if (currentValue > 0 || isPercentage) {
                              setState(() {
                                if (isPercentage) {
                                  double currentVal = double.tryParse(controller.text) ?? 0;
                                  if (currentVal > 0) {
                                    controller.text = (currentVal - 1).toString();
                                  }
                                } else {
                                  controller.text = (currentValue - 1).toString();
                                }
                              });
                            }
                          },
                        ),
                      ),
                      
                      SizedBox(width: 10),
                      
                      // Text field yang lebih lebar
                      Expanded(
                        child: Container(
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Stack(
                            children: [
                              TextFormField(
                                controller: controller,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                                  counterText: '',
                                ),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                                keyboardType: TextInputType.numberWithOptions(decimal: isPercentage),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return '';
                                  }
                                  if (isPercentage) {
                                    final doubleVal = double.tryParse(value);
                                    if (doubleVal == null) {
                                      return '';
                                    }
                                    if (doubleVal < 0 || doubleVal > 100) {
                                      return '';
                                    }
                                  } else {
                                    final intVal = int.tryParse(value);
                                    if (intVal == null) {
                                      return '';
                                    }
                                    if (intVal < 0) {
                                      return '';
                                    }
                                  }
                                  return null;
                                },
                              ),
                              // Suffix untuk percentage
                              if (isPercentage)
                                Positioned(
                                  right: 8,
                                  top: 0,
                                  bottom: 0,
                                  child: Center(
                                    child: Text(
                                      '%',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      
                      SizedBox(width: 10),
                      
                      // Increment button
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.green[300]!),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.add, size: 16, color: Colors.green[700]),
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            setState(() {
                              if (isPercentage) {
                                double currentValue = double.tryParse(controller.text) ?? 0;
                                if (currentValue < 100) {
                                  controller.text = (currentValue + 1).toString();
                                }
                              } else {
                                int currentValue = int.tryParse(controller.text) ?? 0;
                                controller.text = (currentValue + 1).toString();
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Validasi possession total = 100%
      final homePossession = double.tryParse(_homePossessionController.text) ?? 0;
      final awayPossession = double.tryParse(_awayPossessionController.text) ?? 0;
      final totalPossession = homePossession + awayPossession;
      
      if (totalPossession != 100.0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Total possession harus 100% (Saat ini: ${totalPossession.toStringAsFixed(1)}%)'),
            backgroundColor: Colors.red[600],
            duration: Duration(seconds: 3),
          )
        );
        return;
      }
      
      setState(() {
        _isSubmitting = true;
      });
      
      try {
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
        
        print('=== MENGIRIM DATA KE DJANGO ===');
        print('Data: $formData');
        
        bool success = await StatistikService.createStatistik(context, formData);
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Statistik berhasil ditambahkan'),
              backgroundColor: Colors.green[700],
              duration: Duration(seconds: 2),
            )
          );
          widget.onStatistikAdded();
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Gagal menambahkan statistik'),
              backgroundColor: Colors.red[600],
              duration: Duration(seconds: 3),
            )
          );
        }
      } catch (e) {
        print('❌ Error in submit form: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${e.toString()}'),
            backgroundColor: Colors.red[600],
            duration: Duration(seconds: 4),
          )
        );
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}