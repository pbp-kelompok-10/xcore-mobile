import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'team_service.dart';
import 'team_create_update_service.dart';
import 'team_detail_page.dart';
import '../players/player_service.dart';

const List<Map<String, String>> countryChoices = [
  {'code': 'af', 'name': 'Afghanistan'},
  {'code': 'au', 'name': 'Australia'},
  {'code': 'bh', 'name': 'Bahrain'},
  {'code': 'bd', 'name': 'Bangladesh'},
  {'code': 'bt', 'name': 'Bhutan'},
  {'code': 'bn', 'name': 'Brunei'},
  {'code': 'kh', 'name': 'Cambodia'},
  {'code': 'cn', 'name': 'China'},
  {'code': 'tw', 'name': 'Chinese Taipei'},
  {'code': 'gu', 'name': 'Guam'},
  {'code': 'hk', 'name': 'Hong Kong'},
  {'code': 'in', 'name': 'India'},
  {'code': 'id', 'name': 'Indonesia'},
  {'code': 'ir', 'name': 'Iran'},
  {'code': 'iq', 'name': 'Iraq'},
  {'code': 'jp', 'name': 'Japan'},
  {'code': 'jo', 'name': 'Jordan'},
  {'code': 'kg', 'name': 'Kyrgyzstan'},
  {'code': 'kw', 'name': 'Kuwait'},
  {'code': 'la', 'name': 'Laos'},
  {'code': 'lb', 'name': 'Lebanon'},
  {'code': 'mo', 'name': 'Macau'},
  {'code': 'my', 'name': 'Malaysia'},
  {'code': 'mv', 'name': 'Maldives'},
  {'code': 'mn', 'name': 'Mongolia'},
  {'code': 'mm', 'name': 'Myanmar'},
  {'code': 'np', 'name': 'Nepal'},
  {'code': 'kp', 'name': 'North Korea'},
  {'code': 'om', 'name': 'Oman'},
  {'code': 'pk', 'name': 'Pakistan'},
  {'code': 'ps', 'name': 'Palestine'},
  {'code': 'ph', 'name': 'Philippines'},
  {'code': 'qa', 'name': 'Qatar'},
  {'code': 'kr', 'name': 'South Korea'},
  {'code': 'sa', 'name': 'Saudi Arabia'},
  {'code': 'sg', 'name': 'Singapore'},
  {'code': 'lk', 'name': 'Sri Lanka'},
  {'code': 'sy', 'name': 'Syria'},
  {'code': 'tj', 'name': 'Tajikistan'},
  {'code': 'th', 'name': 'Thailand'},
  {'code': 'tl', 'name': 'Timor-Leste'},
  {'code': 'tm', 'name': 'Turkmenistan'},
  {'code': 'ae', 'name': 'United Arab Emirates'},
  {'code': 'uz', 'name': 'Uzbekistan'},
  {'code': 'vn', 'name': 'Vietnam'},
  {'code': 'ye', 'name': 'Yemen'},
];

class TeamsPage extends StatefulWidget {
  final Function(int)? onSwitchTab;

  const TeamsPage({super.key, this.onSwitchTab});

  @override
  State<TeamsPage> createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {
  List<Map<String, String>> teams = [];
  bool loading = true;
  bool fabOpen = false;
  String? selectedCountry;
  bool _isAdmin = PlayerService.getIsAdmin();
  String _error = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTeams();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    try {
      final admin_status = await PlayerService.fetchAdminStatus(context);
      setState(() {
        _isAdmin = admin_status;
        debugPrint("🔐 _isAdmin: $_isAdmin");
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> loadTeams() async {
    if (!mounted) return;
    setState(() => loading = true);

    try {
      final response = await http.get(
        Uri.parse(
          "https://alvin-christian-xcore.pbp.cs.ui.ac.id/lineup/api/teams/",
        ),
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
      floatingActionButton: _isAdmin
          ? Column(
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
            )
          : null,
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : teams.isEmpty
          ? const Center(child: Text("No teams"))
          : ListView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TeamDetailPage(
                              teamId: int.parse(team['id'] ?? '0'),
                            ),
                          ),
                        );
                      },
                      trailing: _isAdmin
                          ? IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => showEditTeamDialog(
                                context,
                                team['id'] ?? '',
                                team['name'] ?? '',
                              ),
                            )
                          : null,
                    ),
                  ),
              ],
            ),
    );
  }
}
