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
  const TeamsPage({super.key});

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

  // Warna konsisten dengan MatchStatisticsPage dan ForumPage
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

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red[600] : primaryColor,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
  }

  void showAddTeamDialog(BuildContext context) {
    String? selectedCountryName;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: whiteColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add, color: primaryColor, size: 20),
              ),
              SizedBox(width: 12),
              Text(
                "Add Team",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: darkTextColor,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedCountryName,
                hint: Text("Select a country", style: TextStyle(color: mutedTextColor)),
                items: countryChoices.map((country) {
                  return DropdownMenuItem<String>(
                    value: country['name'],
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: lightBgColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Image.network(
                            'https://flagcdn.com/24x18/${country['code']?.toLowerCase() ?? ''}.png',
                            width: 24,
                            height: 16,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.flag, size: 16, color: mutedTextColor),
                          ),
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
                decoration: InputDecoration(
                  labelText: "Country",
                  labelStyle: TextStyle(color: mutedTextColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: mutedTextColor,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedCountryName == null) {
                  _showSnackBar("⚠️ Please select a country", isError: true);
                  return;
                }

                try {
                  await TeamCreateUpdateService.createTeam(
                    name: selectedCountryName!,
                  );

                  if (!mounted) return;
                  Navigator.pop(context);
                  await loadTeams();

                  _showSnackBar("✅ Team created successfully", isError: false);
                } catch (e) {
                  if (!mounted) return;
                  _showSnackBar("❌ Error: $e", isError: true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: whiteColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text("Create", style: TextStyle(fontWeight: FontWeight.bold)),
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
          backgroundColor: whiteColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.edit, color: accentColor, size: 20),
              ),
              SizedBox(width: 12),
              Text(
                "Edit Team",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: darkTextColor,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedCountryName,
                hint: Text("Select a country", style: TextStyle(color: mutedTextColor)),
                items: countryChoices.map((country) {
                  return DropdownMenuItem<String>(
                    value: country['name'],
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: lightBgColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Image.network(
                            'https://flagcdn.com/24x18/${country['code']?.toLowerCase() ?? ''}.png',
                            width: 24,
                            height: 16,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.flag, size: 16, color: mutedTextColor),
                          ),
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
                decoration: InputDecoration(
                  labelText: "Country",
                  labelStyle: TextStyle(color: mutedTextColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: mutedTextColor,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedCountryName == null) {
                  _showSnackBar("⚠️ Please select a country", isError: true);
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

                  _showSnackBar("✅ Team updated successfully", isError: false);
                } catch (e) {
                  if (!mounted) return;
                  _showSnackBar("❌ Error: $e", isError: true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: whiteColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text("Update", style: TextStyle(fontWeight: FontWeight.bold)),
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
      builder: (_) => Center(
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                strokeWidth: 3,
              ),
              SizedBox(height: 16),
              Text(
                'Uploading...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: darkTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      await TeamService.uploadTeamsZip(bytes);
      if (!mounted) return;
      Navigator.pop(context);
      await loadTeams();

      _showSnackBar("✅ Teams uploaded successfully", isError: false);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showSnackBar("❌ Upload failed: $e", isError: true);
    }
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            strokeWidth: 2,
          ),
          SizedBox(height: 16),
          Text(
            'Loading Teams...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: mutedTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Container(
          padding: EdgeInsets.all(32),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.groups_outlined, size: 40, color: primaryColor),
              ),
              SizedBox(height: 20),
              Text(
                'No Teams Available',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: darkTextColor,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Teams will appear here once added',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: mutedTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        title: Text(
          "Teams",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: whiteColor,
            fontSize: 18,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
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
              backgroundColor: accentColor,
              foregroundColor: whiteColor,
              icon: const Icon(Icons.add),
              label: const Text("Add Team", style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () => showAddTeamDialog(context),
            ),
            const SizedBox(height: 12),
            FloatingActionButton.extended(
              heroTag: "uploadTeamFAB",
              backgroundColor: primaryColor,
              foregroundColor: whiteColor,
              icon: const Icon(Icons.upload_file),
              label: const Text("Upload ZIP", style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () => uploadTeamsZip(context),
            ),
            const SizedBox(height: 12),
          ],
          FloatingActionButton(
            heroTag: "toggleTeamFAB",
            backgroundColor: primaryColor,
            foregroundColor: whiteColor,
            child: Icon(fabOpen ? Icons.close : Icons.add),
            onPressed: () => setState(() => fabOpen = !fabOpen),
          ),
        ],
      )
          : null,
      body: loading
          ? _buildLoadingState()
          : teams.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: teams.length,
        itemBuilder: (context, index) {
          final team = teams[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primaryColor.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: lightBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.network(
                  'https://flagcdn.com/24x18/${team['code']?.toLowerCase() ?? ''}.png',
                  width: 32,
                  height: 24,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.flag, size: 24, color: mutedTextColor),
                ),
              ),
              title: Text(
                team['name'] ?? '',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: darkTextColor,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chevron_right, color: mutedTextColor),
                  if (_isAdmin)
                    IconButton(
                      icon: Icon(Icons.edit, color: accentColor),
                      onPressed: () => showEditTeamDialog(
                        context,
                        team['id'] ?? '',
                        team['name'] ?? '',
                      ),
                      tooltip: 'Edit Team',
                    ),
                ],
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
            ),
          );
        },
      ),
    );
  }
}