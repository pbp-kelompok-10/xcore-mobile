import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:xcore_mobile/screens/scoreboard/scoreboard_service.dart';

// Data negara dipindahkan ke variabel const agar lebih rapi
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

class AddMatchPage extends StatefulWidget {
  const AddMatchPage({super.key});

  @override
  State<AddMatchPage> createState() => _AddMatchPageState();
}

class _AddMatchPageState extends State<AddMatchPage> {
  final _formKey = GlobalKey<FormState>();
  String _homeTeamCode = _countryChoices.first['code']!; 
  String _awayTeamCode = _countryChoices.first['code']!; 
  int _homeScore = 0;
  int _awayScore = 0;
  DateTime? _matchDate;
  String _stadium = "";
  int _round = 1;
  String _group = "";
  String _status = "upcoming";

  final TextEditingController _dateController = TextEditingController();

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  // Fungsi baru: Memilih Tanggal DAN Jam
  Future<void> _selectDateTime(BuildContext context) async {
    // 1. Pick Date
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _matchDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: Colors.green[700]!),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return;

    // 2. Pick Time (Jika Date dipilih)
    if (!mounted) return;
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_matchDate ?? DateTime.now()),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: Colors.green[700]!),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime == null) return;

    // 3. Gabungkan Date & Time
    final DateTime finalDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      _matchDate = finalDateTime;
      // Format lengkap dengan Jam
      _dateController.text = DateFormat('yyyy-MM-dd HH:mm').format(finalDateTime);
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_matchDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tolong pilih tanggal dan jam pertandingan!')),
        );
        return;
      }

      final request = context.read<CookieRequest>();
      
      final Map<String, dynamic> data = {
        "home_team_code": _homeTeamCode.toLowerCase(), 
        "away_team_code": _awayTeamCode.toLowerCase(),
        "home_score": _homeScore,
        "away_score": _awayScore,
        // Kirim format lengkap ke backend
        "match_date": DateFormat('yyyy-MM-dd HH:mm').format(_matchDate!), 
        "stadium": _stadium,
        "round": _round,
        "group": _group,
        "status": _status,
      };

      try {
        // Tampilkan loading dialog atau indikator jika perlu
        bool success = await ScoreboardService.addMatch(request, data);

        if (success) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Match berhasil ditambahkan!'),
              backgroundColor: Colors.green[600],
            ),
          );
          Navigator.pop(context, true); 
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menambahkan match: ${e.toString()}'),
            backgroundColor: Colors.red[600],
          ),
        );
      }
    }
  }

  // Widget Helper untuk styling Input
  InputDecoration _buildInputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, color: Colors.green[700]) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.green[700]!, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text(
          'Tambah Match Baru',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.green[700],
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Section Teams
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text("Informasi Tim", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: _buildInputDecoration('Home Team', icon: Icons.flag),
                        value: _homeTeamCode,
                        items: _countryChoices.map<DropdownMenuItem<String>>((Map<String, String> item) {
                          return DropdownMenuItem<String>(
                            value: item['code'], 
                            child: Text(item['name']!), 
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
                            child: Text(item['name']!),
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

              // Section Score & Status
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text("Detail Skor", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration: _buildInputDecoration('Home Score'),
                              keyboardType: TextInputType.number,
                              onSaved: (value) => _homeScore = int.tryParse(value!) ?? 0,
                              validator: (value) => value!.isEmpty ? 'Isi 0 jika belum' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              decoration: _buildInputDecoration('Away Score'),
                              keyboardType: TextInputType.number,
                              onSaved: (value) => _awayScore = int.tryParse(value!) ?? 0,
                              validator: (value) => value!.isEmpty ? 'Isi 0 jika belum' : null,
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
                            child: Text(value.toUpperCase()), 
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

              // Section Match Details
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text("Detail Pertandingan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 16),
                      // Input Tanggal dengan Jam
                      TextFormField(
                        controller: _dateController,
                        readOnly: true,
                        decoration: _buildInputDecoration('Waktu Kick-off', icon: Icons.calendar_month).copyWith(
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.access_time_filled, color: Colors.blueAccent),
                            onPressed: () => _selectDateTime(context),
                          ),
                        ),
                        onTap: () => _selectDateTime(context),
                        validator: (value) => _matchDate == null ? 'Waktu wajib diisi' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
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
              const SizedBox(height: 24),
              
              // Submit Button
              ElevatedButton.icon(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                icon: const Icon(Icons.save_rounded),
                label: const Text(
                  'SIMPAN MATCH',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}