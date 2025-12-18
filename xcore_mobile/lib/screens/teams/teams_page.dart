import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'team_service.dart';
import 'team_create_update_service.dart';

const List<Map<String, String>> countryChoices = [
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

class TeamsPage extends StatefulWidget {
  const TeamsPage({super.key});

  @override
  State<TeamsPage> createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {
  List<Map<String, String>> teams = [];
  bool loading = true;
  bool fabOpen = false;
  String? selectedCountry;

  @override
  void initState() {
    super.initState();
    loadTeams();
  }

  Future<void> loadTeams() async {
    if (!mounted) return;
    setState(() => loading = true);

    try {
      final response = await http.get(
        Uri.parse("http://localhost:8000/lineup/api/teams/"),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final teamsList = data['teams'] as List;
        final teamData = teamsList
            .map(
              (t) => {
                'name': t['name'].toString(),
                'code': t['code'].toString(),
                'id': t['id'].toString(),
              },
            )
            .toList();

        setState(() {
          teams = teamData.cast<Map<String, String>>();
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      print("Error: $e");
      if (mounted) setState(() => loading = false);
    }
  }

  void showAddTeamDialog(BuildContext context) {
    String? selectedCountryName;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Add Team"),
          content: DropdownButtonFormField<String>(
            value: selectedCountryName,
            hint: const Text("Select a country"),
            items: countryChoices.map((country) {
              return DropdownMenuItem<String>(
                value: country['name'],
                child: Row(
                  children: [
                    Image.network(
                      'https://flagcdn.com/24x18/${country['code']?.toLowerCase() ?? ''}.png',
                      width: 24,
                      height: 16,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.flag),
                    ),
                    const SizedBox(width: 12),
                    Text(country['name'] ?? ''),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedCountryName = value;
              });
            },
            decoration: const InputDecoration(
              labelText: "Country",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedCountryName == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please select a country"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  await TeamCreateUpdateService.createTeam(
                    name: selectedCountryName!,
                  );

                  if (!mounted) return;
                  Navigator.pop(context);
                  await loadTeams();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Team created successfully"),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text("Create"),
            ),
          ],
        ),
      ),
    );
  }

  void showEditTeamDialog(
    BuildContext context,
    String teamId,
    String currentName,
  ) {
    String? selectedCountryName;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Edit Team"),
          content: DropdownButtonFormField<String>(
            value: selectedCountryName,
            hint: const Text("Select a country"),
            items: countryChoices.map((country) {
              return DropdownMenuItem<String>(
                value: country['name'],
                child: Row(
                  children: [
                    Image.network(
                      'https://flagcdn.com/24x18/${country['code']?.toLowerCase() ?? ''}.png',
                      width: 24,
                      height: 16,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.flag),
                    ),
                    const SizedBox(width: 12),
                    Text(country['name'] ?? ''),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedCountryName = value;
              });
            },
            decoration: const InputDecoration(
              labelText: "Country",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedCountryName == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please select a country"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  // Find the country code from the selected name
                  final selectedCountry = countryChoices.firstWhere(
                    (country) => country['name'] == selectedCountryName,
                  );

                  await TeamCreateUpdateService.updateTeam(
                    id: int.parse(teamId),
                    code: selectedCountry['code']!,
                  );

                  if (!mounted) return;
                  Navigator.pop(context);
                  await loadTeams();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Team updated successfully"),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text("Update"),
            ),
          ],
        ),
      ),
    );
  }

  void uploadTeamsZip(BuildContext context) async {
    final bytes = await TeamService.pickZipFile();
    if (bytes == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await TeamService.uploadTeamsZip(bytes);
      if (!mounted) return;
      Navigator.pop(context);
      await loadTeams();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Teams uploaded successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Upload failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F6F4),
      appBar: AppBar(
        title: const Text("Teams"),
        backgroundColor: const Color(0xFF4AA69B),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (fabOpen) ...[
            FloatingActionButton.extended(
              heroTag: "addTeamFAB",
              backgroundColor: Colors.blue,
              icon: const Icon(Icons.add),
              label: const Text("Add Team"),
              onPressed: () => showAddTeamDialog(context),
            ),
            const SizedBox(height: 12),
            FloatingActionButton.extended(
              heroTag: "uploadTeamFAB",
              backgroundColor: Colors.green,
              icon: const Icon(Icons.upload_file),
              label: const Text("Upload ZIP"),
              onPressed: () => uploadTeamsZip(context),
            ),
            const SizedBox(height: 12),
          ],
          FloatingActionButton(
            heroTag: "toggleTeamFAB",
            backgroundColor: const Color(0xFF4AA69B),
            child: Icon(fabOpen ? Icons.close : Icons.add),
            onPressed: () => setState(() => fabOpen = !fabOpen),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : teams.isEmpty
          ? const Center(child: Text("No teams"))
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                for (final team in teams)
                  Card(
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Image.network(
                        'https://flagcdn.com/24x18/${team['code']?.toLowerCase() ?? ''}.png',
                        width: 32,
                        height: 24,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.flag),
                      ),
                      title: Text(
                        team['name'] ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => showEditTeamDialog(
                          context,
                          team['id'] ?? '',
                          team['name'] ?? '',
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
