import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:xcore_mobile/models/scoreboard_entry.dart';
import 'package:xcore_mobile/services/scoreboard_service.dart';

const List<Map<String, String>> _countryChoices = [
  {'code': 'jp', 'name': 'Japan'},
  {'code': 'ir', 'name': 'Iran'},
  {'code': 'kr', 'name': 'South Korea'},
  {'code': 'au', 'name': 'Australia'},
  {'code': 'sa', 'name': 'Saudi Arabia'},
  {'code': 'uz', 'name': 'Uzbekistan'},
  {'code': 'jo', 'name': 'Jordan'},
  {'code': 'iq', 'name': 'Iraq'},
  {'code': 'ae', 'name': 'United Arab Emirates'},
  {'code': 'qa', 'name': 'Qatar'},
  {'code': 'cn', 'name': 'China'},
  {'code': 'om', 'name': 'Oman'},
  {'code': 'id', 'name': 'Indonesia'},
  {'code': 'bh', 'name': 'Bahrain'},
  {'code': 'kw', 'name': 'Kuwait'},
  {'code': 'th', 'name': 'Thailand'},
  {'code': 'kp', 'name': 'North Korea'},
  {'code': 'ps', 'name': 'Palestine'},
  {'code': 'sy', 'name': 'Syria'},
  {'code': 'vn', 'name': 'Vietnam'},
  {'code': 'my', 'name': 'Malaysia'},
  {'code': 'lb', 'name': 'Lebanon'},
  {'code': 'np', 'name': 'Nepal'},
  {'code': 'bd', 'name': 'Bangladesh'},
  {'code': 'mm', 'name': 'Myanmar'},
  {'code': 'mv', 'name': 'Maldives'},
  {'code': 'af', 'name': 'Afghanistan'},
  {'code': 'ph', 'name': 'Philippines'},
  {'code': 'hk', 'name': 'Hong Kong'},
  {'code': 'tm', 'name': 'Turkmenistan'},
  {'code': 'kg', 'name': 'Kyrgyzstan'},
  {'code': 'tj', 'name': 'Tajikistan'},
  {'code': 'tw', 'name': 'Chinese Taipei'},
  {'code': 'ye', 'name': 'Yemen'},
  {'code': 'bn', 'name': 'Brunei'},
  {'code': 'la', 'name': 'Laos'},
  {'code': 'lk', 'name': 'Sri Lanka'},
  {'code': 'kh', 'name': 'Cambodia'},
  {'code': 'bt', 'name': 'Bhutan'},
  {'code': 'gu', 'name': 'Guam'},
  {'code': 'mn', 'name': 'Mongolia'},
  {'code': 'pk', 'name': 'Pakistan'},
  {'code': 'tl', 'name': 'Timor-Leste'},
  {'code': 'mo', 'name': 'Macau'},
  {'code': 'sg', 'name': 'Singapore'},
  {'code': 'in', 'name': 'India'},
];

class EditMatchPage extends StatefulWidget {
  final ScoreboardEntry matchEntry; 

  const EditMatchPage({super.key, required this.matchEntry});

  @override
  State<EditMatchPage> createState() => _EditMatchPageState();
}

class _EditMatchPageState extends State<EditMatchPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Warna Tema
  final Color primaryColor = const Color(0xFF4AA69B);
  final Color scaffoldBgColor = const Color(0xFFE8F6F4);
  final Color errorColor = const Color(0xFFEF4444);
  
  late String _homeTeamCode;
  late String _awayTeamCode;
  late int _homeScore;
  late int _awayScore;
  late DateTime _matchDate;
  late String _stadium;
  late int _round;
  late String _group;
  late String _status;

  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _homeTeamCode = widget.matchEntry.homeTeamCode.toLowerCase();
    _awayTeamCode = widget.matchEntry.awayTeamCode.toLowerCase();
    _homeScore = widget.matchEntry.homeScore;
    _awayScore = widget.matchEntry.awayScore;
    _matchDate = widget.matchEntry.matchDate;
    _stadium = widget.matchEntry.stadium;
    _round = widget.matchEntry.round;
    _group = widget.matchEntry.group;
    _status = widget.matchEntry.status;

    _dateController.text = DateFormat('yyyy-MM-dd HH:mm').format(_matchDate);

    // Fallback jika kode negara tidak ditemukan
    if (!_countryChoices.any((c) => c['code'] == _homeTeamCode)) {
        _homeTeamCode = _countryChoices.first['code']!;
    }
    if (!_countryChoices.any((c) => c['code'] == _awayTeamCode)) {
        _awayTeamCode = _countryChoices.first['code']!;
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _matchDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor, // Custom Color
              onPrimary: Colors.white,
              onSurface: const Color(0xFF2C5F5A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return;

    if (!mounted) return;
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_matchDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor, // Custom Color
              onPrimary: Colors.white,
              onSurface: const Color(0xFF2C5F5A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime == null) return;

    final DateTime finalDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      _matchDate = finalDateTime;
      _dateController.text = DateFormat('yyyy-MM-dd HH:mm').format(finalDateTime);
    });
  }

  void _deleteMatch() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus Pertandingan',
          style: TextStyle(fontFamily: 'Nunito Sans', fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Apakah Anda yakin ingin menghapus pertandingan ini? Data tidak dapat dikembalikan.',
          style: TextStyle(fontFamily: 'Nunito Sans'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(fontFamily: 'Nunito Sans', color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Hapus', style: TextStyle(fontFamily: 'Nunito Sans', color: errorColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final request = context.read<CookieRequest>();
      try {
        bool success = await ScoreboardService.deleteMatch(request, widget.matchEntry.id);
        if (success) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Match berhasil dihapus!', style: TextStyle(fontFamily: 'Nunito Sans')),
              backgroundColor: primaryColor,
            ),
          );
          Navigator.pop(context, true); // Kembali ke ScoreboardPage dan refresh
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus: $e', style: const TextStyle(fontFamily: 'Nunito Sans')),
            backgroundColor: errorColor,
          ),
        );
      }
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final request = context.read<CookieRequest>();
      
      final Map<String, dynamic> data = {
        "home_team_code": _homeTeamCode.toLowerCase(),
        "away_team_code": _awayTeamCode.toLowerCase(),
        "home_score": _homeScore,
        "away_score": _awayScore,
        "match_date": DateFormat('yyyy-MM-dd HH:mm').format(_matchDate),
        "stadium": _stadium,
        "round": _round,
        "group": _group,
        "status": _status,
      };

      try {
        bool success = await ScoreboardService.editMatch(request, widget.matchEntry.id, data);

        if (success) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Match berhasil diubah!', style: TextStyle(fontFamily: 'Nunito Sans')),
              backgroundColor: primaryColor,
            ),
          );
          Navigator.pop(context, true); 
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengubah match: ${e.toString()}', style: const TextStyle(fontFamily: 'Nunito Sans')),
            backgroundColor: errorColor,
          ),
        );
      }
    }
  }

  InputDecoration _buildInputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontFamily: 'Nunito Sans', color: Color(0xFF6B8E8A)),
      prefixIcon: icon != null ? Icon(icon, color: primaryColor) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        title: const Text(
          'Edit Match',
          style: TextStyle(
            fontFamily: 'Nunito Sans',
            fontWeight: FontWeight.w700,
            color: Colors.white
          ),
        ),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 2,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Teams Section
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        "Tim Bertanding", 
                        style: TextStyle(
                          fontFamily: 'Nunito Sans', 
                          fontWeight: FontWeight.w700, 
                          fontSize: 16,
                          color: Color(0xFF2C5F5A)
                        )
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: _buildInputDecoration('Home Team', icon: Icons.flag),
                        value: _homeTeamCode,
                        items: _countryChoices.map<DropdownMenuItem<String>>((Map<String, String> item) {
                          return DropdownMenuItem<String>(
                            value: item['code'], 
                            child: Text(item['name']!, style: const TextStyle(fontFamily: 'Nunito Sans')), 
                          );
                        }).toList(),
                        onChanged: (newValue) => setState(() => _homeTeamCode = newValue!),
                        onSaved: (value) => _homeTeamCode = value!,
                        validator: (value) => value == null ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: _buildInputDecoration('Away Team', icon: Icons.outlined_flag),
                        value: _awayTeamCode,
                        items: _countryChoices.map<DropdownMenuItem<String>>((Map<String, String> item) {
                          return DropdownMenuItem<String>(
                            value: item['code'],
                            child: Text(item['name']!, style: const TextStyle(fontFamily: 'Nunito Sans')),
                          );
                        }).toList(),
                        onChanged: (newValue) => setState(() => _awayTeamCode = newValue!),
                        onSaved: (value) => _awayTeamCode = value!,
                        validator: (value) => value == null ? 'Wajib diisi' : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Score Section
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        "Update Skor", 
                        style: TextStyle(
                          fontFamily: 'Nunito Sans', 
                          fontWeight: FontWeight.w700, 
                          fontSize: 16,
                          color: Color(0xFF2C5F5A)
                        )
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: _homeScore.toString(),
                              decoration: _buildInputDecoration('Home Score'),
                              keyboardType: TextInputType.number,
                              onSaved: (value) => _homeScore = int.tryParse(value!) ?? 0,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              initialValue: _awayScore.toString(),
                              decoration: _buildInputDecoration('Away Score'),
                              keyboardType: TextInputType.number,
                              onSaved: (value) => _awayScore = int.tryParse(value!) ?? 0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: _buildInputDecoration('Status', icon: Icons.info_outline),
                        value: _status,
                        items: <String>['upcoming', 'live', 'finished'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value.toUpperCase(), style: const TextStyle(fontFamily: 'Nunito Sans')),
                          );
                        }).toList(),
                        onChanged: (newValue) => setState(() => _status = newValue!),
                        onSaved: (value) => _status = value!,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Details Section
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        "Info Lainnya", 
                        style: TextStyle(
                          fontFamily: 'Nunito Sans', 
                          fontWeight: FontWeight.w700, 
                          fontSize: 16,
                          color: Color(0xFF2C5F5A)
                        )
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _dateController,
                        readOnly: true,
                        decoration: _buildInputDecoration('Waktu Kick-off', icon: Icons.calendar_month).copyWith(
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.access_time_filled, color: Color(0xFF2C5F5A)),
                            onPressed: () => _selectDateTime(context),
                          ),
                        ),
                        onTap: () => _selectDateTime(context),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: _stadium,
                        decoration: _buildInputDecoration('Stadium', icon: Icons.stadium),
                        onSaved: (value) => _stadium = value!,
                        validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: _round.toString(),
                              decoration: _buildInputDecoration('Round'),
                              keyboardType: TextInputType.number,
                              onSaved: (value) => _round = int.tryParse(value!) ?? 1,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              initialValue: _group,
                              decoration: _buildInputDecoration('Group'),
                              onSaved: (value) => _group = value!,
                              validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Action Buttons (Save & Delete)
              Column(
                children: [
                  // Tombol Simpan
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text(
                        'SIMPAN PERUBAHAN',
                        style: TextStyle(
                          fontFamily: 'Nunito Sans',
                          fontSize: 16, 
                          fontWeight: FontWeight.w700
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Tombol Hapus Match
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _deleteMatch,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFEF2F2), // Background merah sangat muda
                        foregroundColor: errorColor, 
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: errorColor.withOpacity(0.3)), 
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text(
                        'HAPUS PERTANDINGAN',
                        style: TextStyle(
                          fontFamily: 'Nunito Sans',
                          fontSize: 16, 
                          fontWeight: FontWeight.w700
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}