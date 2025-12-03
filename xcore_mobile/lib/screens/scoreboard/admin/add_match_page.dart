import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:xcore_mobile/screens/scoreboard/scoreboard_service.dart';

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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _matchDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _matchDate) {
      setState(() {
        _matchDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_matchDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tolong pilih tanggal pertandingan!')),
        );
        return;
      }

      final request = context.read<CookieRequest>();
      
      final Map<String, dynamic> data = {
        "home_team_code": _homeTeamCode.toLowerCase(), 
        "away_team_code": _awayTeamCode.toLowerCase(),
        "home_score": _homeScore,
        "away_score": _awayScore,
        "match_date": DateFormat('yyyy-MM-dd').format(_matchDate!),
        "stadium": _stadium,
        "round": _round,
        "group": _group,
        "status": _status,
      };

      try {
        bool success = await ScoreboardService.addMatch(request, data);

        if (success) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Match berhasil ditambahkan!')),
          );
          Navigator.pop(context, true); 
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan match: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Match Baru'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Kolom Pilihan Tim Home (DropdownButtonFormField)
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Home Team'),
                value: _homeTeamCode,
                items: _countryChoices
                    .map<DropdownMenuItem<String>>((Map<String, String> item) {
                  return DropdownMenuItem<String>(
                    value: item['code'], 
                    child: Text(item['name']!), 
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _homeTeamCode = newValue!;
                  });
                },
                onSaved: (value) => _homeTeamCode = value!,
                validator: (value) => value == null ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              
              // Kolom Pilihan Tim Away (DropdownButtonFormField)
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Away Team'),
                value: _awayTeamCode,
                items: _countryChoices
                    .map<DropdownMenuItem<String>>((Map<String, String> item) {
                  return DropdownMenuItem<String>(
                    value: item['code'],
                    child: Text(item['name']!),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _awayTeamCode = newValue!;
                  });
                },
                onSaved: (value) => _awayTeamCode = value!,
                validator: (value) => value == null ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              // Kolom Skor
              Row(
                children: [
                  Expanded(child: TextFormField(
                    decoration: const InputDecoration(labelText: 'Home Score'),
                    keyboardType: TextInputType.number,
                    onSaved: (value) => _homeScore = int.tryParse(value!) ?? 0,
                    validator: (value) => value!.isEmpty || int.tryParse(value) == null ? 'Angka' : null,
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: TextFormField(
                    decoration: const InputDecoration(labelText: 'Away Score'),
                    keyboardType: TextInputType.number,
                    onSaved: (value) => _awayScore = int.tryParse(value!) ?? 0,
                    validator: (value) => value!.isEmpty || int.tryParse(value) == null ? 'Angka' : null,
                  )),
                ],
              ),
              
              const SizedBox(height: 12),
              // Match Date
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Match Date',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                validator: (value) => _matchDate == null ? 'Tanggal wajib diisi' : null,
              ),
              
              // Stadium
              TextFormField(
                decoration: const InputDecoration(labelText: 'Stadium'),
                onSaved: (value) => _stadium = value!,
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),

              // Round dan Group
              Row(
                children: [
                  Expanded(child: TextFormField(
                    initialValue: _round.toString(),
                    decoration: const InputDecoration(labelText: 'Round'),
                    keyboardType: TextInputType.number,
                    onSaved: (value) => _round = int.tryParse(value!) ?? 1,
                    validator: (value) => value!.isEmpty || int.tryParse(value) == null ? 'Angka' : null,
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: TextFormField(
                    decoration: const InputDecoration(labelText: 'Group (e.g. Group A)'),
                    onSaved: (value) => _group = value!,
                    validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                  )),
                ],
              ),

              // Status Dropdown 
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Status'),
                value: _status,
                items: <String>['upcoming', 'live', 'finished']
                    .map<DropdownMenuItem<String>>((String value) {
                  String displayText = value[0].toUpperCase() + value.substring(1); 
                  return DropdownMenuItem<String>(
                    value: value, 
                    child: Text(displayText), 
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _status = newValue!;
                  });
                },
                onSaved: (value) => _status = value!,
              ),
              const SizedBox(height: 20),
              
              // Submit Button
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Tambah Match'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}