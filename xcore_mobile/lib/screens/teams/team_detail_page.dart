import 'package:flutter/material.dart';
import 'team_detail_service.dart';
import 'team_create_update_service.dart';
import '../players/player_detail_page.dart';
import '../../models/team_entry.dart';
import '../players/player_service.dart';

class TeamDetailPage extends StatefulWidget {
  final int teamId;
  final bool isEmbedded;

  const TeamDetailPage({
    Key? key,
    required this.teamId,
    this.isEmbedded = false,
  }) : super(key: key);

  @override
  State<TeamDetailPage> createState() => _TeamDetailPageState();
}

class _TeamDetailPageState extends State<TeamDetailPage> {
  late Future<Map<String, dynamic>> _teamDetails;
  bool _isAdmin = false;
  bool _isLoading = true;
  String? _error;

  // Country list (copied from teams_page.dart)
  static const List<Map<String, String>> countryChoices = [
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

  @override
  void initState() {
    super.initState();
    _teamDetails = TeamDetailService.getTeamDetails(widget.teamId);
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
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showEditTeamDialog(String teamName, String teamCode) {
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
                    id: widget.teamId,
                    code: selectedCountry['code']!,
                  );

                  if (!mounted) return;
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Team updated successfully"),
                      backgroundColor: Colors.green,
                    ),
                  );

                  // Refresh the team details
                  setState(() {
                    _teamDetails = TeamDetailService.getTeamDetails(
                      widget.teamId,
                    );
                  });
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error updating team: $e"),
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

  @override
  Widget build(BuildContext context) {
    if (widget.isEmbedded) {
      return _buildDetailContent();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Details'),
        backgroundColor: const Color(0xFF4AA69B),
        actions: [
          FutureBuilder<Map<String, dynamic>>(
            future: _teamDetails,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final teamData = snapshot.data!;
                final teamName = teamData['name'] ?? '';
                final teamCode = teamData['code'] ?? '';
                return _isAdmin
                    ? IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () =>
                            _showEditTeamDialog(teamName, teamCode),
                      )
                    : const SizedBox.shrink();
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: _buildDetailContent(),
    );
  }

  Widget _buildDetailContent() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _teamDetails,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: Text('No team data found'));
        }

        final teamData = snapshot.data!;
        final teamName = teamData['name'] ?? '';
        final teamCode = teamData['code'] ?? '';
        final players = (teamData['players'] ?? []) as List;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Team Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                ),
                child: Row(
                  children: [
                    Image.network(
                      'https://flagcdn.com/48x36/${teamCode.toLowerCase()}.png',
                      width: 48,
                      height: 36,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.flag, color: Color(0xFF9CA3AF)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            teamName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C5F5A),
                            ),
                          ),
                          Text(
                            'Code: $teamCode',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B8E8A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Players Section - Dropdown
              ExpansionTile(
                title: Text(
                  'Players (${players.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                children: [
                  if (players.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: Text('No players in this team')),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: players.length,
                      itemBuilder: (context, index) {
                        final player = players[index] as Map<String, dynamic>;
                        return Card(
                          margin: const EdgeInsets.only(
                            bottom: 8,
                            left: 16,
                            right: 16,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.green[700],
                              child: Text(
                                player['nomor']?.toString() ?? '-',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(player['nama'] ?? '-'),
                            subtitle: Text(
                              '${player['asal'] ?? '-'} • Age ${player['umur'] ?? '-'}',
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PlayerDetailPage(
                                    playerId: player['id'] as int,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
