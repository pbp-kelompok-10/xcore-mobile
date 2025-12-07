import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:xcore_mobile/models/statistik_entry.dart';
import 'package:xcore_mobile/screens/statistik/statistik_service.dart';

class EditStatistikPage extends StatefulWidget {
  final StatistikEntry statistik;
  final Function() onStatistikUpdated;

  const EditStatistikPage({
    super.key,
    required this.statistik,
    required this.onStatistikUpdated,
  });

  @override
  _EditStatistikPageState createState() => _EditStatistikPageState();
}

class _EditStatistikPageState extends State<EditStatistikPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  
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
  void initState() {
    super.initState();
    // Initialize controllers dengan data dari statistik
    _homePassesController.text = widget.statistik.homePasses.toString();
    _awayPassesController.text = widget.statistik.awayPasses.toString();
    _homeShotsController.text = widget.statistik.homeShots.toString();
    _awayShotsController.text = widget.statistik.awayShots.toString();
    _homeShotsOnTargetController.text = widget.statistik.homeShotsOnTarget.toString();
    _awayShotsOnTargetController.text = widget.statistik.awayShotsOnTarget.toString();
    _homePossessionController.text = widget.statistik.homePossession.toString();
    _awayPossessionController.text = widget.statistik.awayPossession.toString();
    _homeRedCardsController.text = widget.statistik.homeRedCards.toString();
    _awayRedCardsController.text = widget.statistik.awayRedCards.toString();
    _homeYellowCardsController.text = widget.statistik.homeYellowCards.toString();
    _awayYellowCardsController.text = widget.statistik.awayYellowCards.toString();
    _homeOffsidesController.text = widget.statistik.homeOffsides.toString();
    _awayOffsidesController.text = widget.statistik.awayOffsides.toString();
    _homeCornersController.text = widget.statistik.homeCorners.toString();
    _awayCornersController.text = widget.statistik.awayCorners.toString();
  }

  @override
  void dispose() {
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
        title: Text('Edit Statistik'),
        backgroundColor: Colors.blue[700],
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
                  CircularProgressIndicator(color: Colors.blue[700]),
                  SizedBox(height: 16),
                  Text(
                    'Mengupdate statistik...',
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
                    // Header info match
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.statistik.homeTeam,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green[100],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${widget.statistik.homeScore} - ${widget.statistik.awayScore}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    widget.statistik.awayTeam,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.right,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Divider(height: 1),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    widget.statistik.stadium,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                                SizedBox(width: 4),
                                Text(
                                  widget.statistik.matchDate,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Statistics form dalam card yang lebih kecil
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Home team statistics
                            _buildTeamStatisticsSection(widget.statistik.homeTeam, true),
                            SizedBox(height: 20),
                            Divider(),
                            SizedBox(height: 20),
                            // Away team statistics
                            _buildTeamStatisticsSection(widget.statistik.awayTeam, false),
                          ],
                        ),
                      ),
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
                            : Icon(Icons.save, size: 20),
                        label: Text(
                          _isSubmitting ? 'MENGUPDATE...' : 'UPDATE STATISTIK',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: _isSubmitting ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          elevation: 4,
                          disabledBackgroundColor: Colors.blue[400],
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

  Widget _buildTeamStatisticsSection(String teamName, bool isHome) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isHome ? Colors.green[50] : Colors.blue[50],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isHome ? Colors.green[200]! : Colors.blue[200]!,
                ),
              ),
              child: Text(
                isHome ? 'HOME TEAM' : 'AWAY TEAM',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isHome ? Colors.green[800] : Colors.blue[800],
                  letterSpacing: 0.5,
                ),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                teamName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 3.0,
          children: isHome
              ? [
                  _buildNumberFieldWithButtons('Passes', _homePassesController),
                  _buildNumberFieldWithButtons('Shots', _homeShotsController),
                  _buildNumberFieldWithButtons('Shots on Target', _homeShotsOnTargetController),
                  _buildPossessionField('Possession (%)', _homePossessionController),
                  _buildNumberFieldWithButtons('Red Cards', _homeRedCardsController),
                  _buildNumberFieldWithButtons('Yellow Cards', _homeYellowCardsController),
                  _buildNumberFieldWithButtons('Offsides', _homeOffsidesController),
                  _buildNumberFieldWithButtons('Corners', _homeCornersController),
                ]
              : [
                  _buildNumberFieldWithButtons('Passes', _awayPassesController),
                  _buildNumberFieldWithButtons('Shots', _awayShotsController),
                  _buildNumberFieldWithButtons('Shots on Target', _awayShotsOnTargetController),
                  _buildPossessionField('Possession (%)', _awayPossessionController),
                  _buildNumberFieldWithButtons('Red Cards', _awayRedCardsController),
                  _buildNumberFieldWithButtons('Yellow Cards', _awayYellowCardsController),
                  _buildNumberFieldWithButtons('Offsides', _awayOffsidesController),
                  _buildNumberFieldWithButtons('Corners', _awayCornersController),
                ],
        ),
      ],
    );
  }

  Widget _buildNumberFieldWithButtons(String label, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
        color: Colors.white,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4),
            Row(
              children: [
                // Decrement button
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.remove, size: 16),
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      int currentValue = int.tryParse(controller.text) ?? 0;
                      if (currentValue > 0) {
                        setState(() {
                          controller.text = (currentValue - 1).toString();
                        });
                      }
                    },
                  ),
                ),
                SizedBox(width: 8),
                // Text field
                Expanded(
                  child: Container(
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: TextFormField(
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
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '';
                        }
                        final intVal = int.tryParse(value);
                        if (intVal == null) {
                          return '';
                        }
                        if (intVal < 0) {
                          return '';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                SizedBox(width: 8),
                // Increment button
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.green[300]!),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.add, size: 16, color: Colors.green[700]),
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      int currentValue = int.tryParse(controller.text) ?? 0;
                      setState(() {
                        controller.text = (currentValue + 1).toString();
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPossessionField(String label, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
        color: Colors.white,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 4),
            Row(
              children: [
                // Decrement button
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.remove, size: 16),
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      double currentValue = double.tryParse(controller.text) ?? 50.0;
                      if (currentValue > 0) {
                        setState(() {
                          controller.text = (currentValue - 1).toStringAsFixed(0);
                        });
                      }
                    },
                  ),
                ),
                SizedBox(width: 8),
                // Text field with %
                Expanded(
                  child: Container(
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.blue[300]!),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: controller,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 8),
                              counterText: '',
                              hintText: '0',
                            ),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[800],
                            ),
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '';
                              }
                              final doubleVal = double.tryParse(value);
                              if (doubleVal == null) {
                                return '';
                              }
                              if (doubleVal < 0 || doubleVal > 100) {
                                return '';
                              }
                              return null;
                            },
                          ),
                        ),
                        Container(
                          width: 30,
                          alignment: Alignment.center,
                          child: Text(
                            '%',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 8),
                // Increment button
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.blue[300]!),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.add, size: 16, color: Colors.blue[700]),
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      double currentValue = double.tryParse(controller.text) ?? 50.0;
                      if (currentValue < 100) {
                        setState(() {
                          controller.text = (currentValue + 1).toStringAsFixed(0);
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              'Total kedua tim harus 100%',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
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
          'match': widget.statistik.matchId,
          'home_passes': int.tryParse(_homePassesController.text) ?? 0,
          'away_passes': int.tryParse(_awayPassesController.text) ?? 0,
          'home_shots': int.tryParse(_homeShotsController.text) ?? 0,
          'away_shots': int.tryParse(_awayShotsController.text) ?? 0,
          'home_shots_on_target': int.tryParse(_homeShotsOnTargetController.text) ?? 0,
          'away_shots_on_target': int.tryParse(_awayShotsOnTargetController.text) ?? 0,
          'home_possession': double.tryParse(_homePossessionController.text) ?? 0.0,
          'away_possession': double.tryParse(_awayPossessionController.text) ?? 0.0,
          'home_red_cards': int.tryParse(_homeRedCardsController.text) ?? 0,
          'away_red_cards': int.tryParse(_awayRedCardsController.text) ?? 0,
          'home_yellow_cards': int.tryParse(_homeYellowCardsController.text) ?? 0,
          'away_yellow_cards': int.tryParse(_awayYellowCardsController.text) ?? 0,
          'home_offsides': int.tryParse(_homeOffsidesController.text) ?? 0,
          'away_offsides': int.tryParse(_awayOffsidesController.text) ?? 0,
          'home_corners': int.tryParse(_homeCornersController.text) ?? 0,
          'away_corners': int.tryParse(_awayCornersController.text) ?? 0,
        };
        
        print('=== MENGUPDATE STATISTIK ===');
        print('Data: $formData');
        
        final success = await StatistikService.updateStatistik(
          context, 
          widget.statistik.matchId, 
          formData
        );
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Statistik berhasil diupdate'),
              backgroundColor: Colors.green[700],
              duration: Duration(seconds: 2),
            )
          );
          widget.onStatistikUpdated();
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Gagal mengupdate statistik'),
              backgroundColor: Colors.red[600],
              duration: Duration(seconds: 3),
            )
          );
        }
      } catch (e) {
        print('❌ Error updating statistik: $e');
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