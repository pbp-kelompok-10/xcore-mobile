import 'package:flutter/material.dart';
import 'team_detail_service.dart';
import 'team_create_update_service.dart';
import '../players/player_detail_page.dart';
import '../../models/team_entry.dart';
import '../players/player_service.dart';

class TeamDetailPage extends StatefulWidget {
  final int teamId;

  const TeamDetailPage({Key? key, required this.teamId}) : super(key: key);

  @override
  State<TeamDetailPage> createState() => _TeamDetailPageState();
}

class _TeamDetailPageState extends State<TeamDetailPage> {
  late Future<Map<String, dynamic>> _teamDetails;
  bool _isAdmin = false;
  bool _isLoading = true;
  String? _error;

  // Warna konsisten dengan MatchStatisticsPage dan ForumPage
  static const Color primaryColor = Color(0xFF4AA69B);
  static const Color scaffoldBgColor = Color(0xFFE8F6F4);
  static const Color darkTextColor = Color(0xFF2C5F5A);
  static const Color mutedTextColor = Color(0xFF6B8E8A);
  static const Color accentColor = Color(0xFF34C6B8);
  static const Color lightBgColor = Color(0xFFD1F0EB);
  static const Color whiteColor = Colors.white;

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

  void _showEditTeamDialog(String teamName, String teamCode) {
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
                    id: widget.teamId,
                    code: selectedCountry['code']!,
                  );

                  if (!mounted) return;
                  Navigator.pop(context);

                  _showSnackBar("✅ Team updated successfully", isError: false);

                  // Refresh the team details
                  setState(() {
                    _teamDetails = TeamDetailService.getTeamDetails(
                      widget.teamId,
                    );
                  });
                } catch (e) {
                  if (!mounted) return;
                  _showSnackBar("❌ Error updating team: $e", isError: true);
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
            'Loading Team Details...',
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

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withOpacity(0.2)),
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
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.error_outline, size: 40, color: Colors.red),
              ),
              SizedBox(height: 20),
              Text(
                'Error Loading Team',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 8),
              Text(
                error,
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
          'Team Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: whiteColor,
            fontSize: 18,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: whiteColor),
          onPressed: () => Navigator.pop(context),
        ),
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
                  icon: Icon(Icons.edit, color: whiteColor),
                  onPressed: () =>
                      _showEditTeamDialog(teamName, teamCode),
                  tooltip: 'Edit Team',
                )
                    : const SizedBox.shrink();
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _teamDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          if (!snapshot.hasData) {
            return _buildErrorState('No team data found');
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
                // Team Header Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [primaryColor, accentColor],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: whiteColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Image.network(
                          'https://flagcdn.com/48x36/${teamCode.toLowerCase()}.png',
                          width: 48,
                          height: 36,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.flag, color: whiteColor, size: 36),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              teamName,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: whiteColor,
                              ),
                            ),
                            SizedBox(height: 4),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: whiteColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Code: $teamCode',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: whiteColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Players Section
                Container(
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
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                    ),
                    child: ExpansionTile(
                      title: Row(
                        children: [
                          Icon(Icons.people, size: 20, color: primaryColor),
                          SizedBox(width: 8),
                          Text(
                            'Players',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: darkTextColor,
                            ),
                          ),
                          Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${players.length}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      children: [
                        if (players.isEmpty)
                          Padding(
                            padding: EdgeInsets.all(24),
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.people_outline,
                                    size: 32,
                                    color: primaryColor,
                                  ),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'No players in this team',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: mutedTextColor,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: players.length,
                            itemBuilder: (context, index) {
                              final player = players[index] as Map<String, dynamic>;
                              return Container(
                                margin: EdgeInsets.only(
                                  bottom: index == players.length - 1 ? 0 : 1,
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: index == 0
                                        ? BorderSide.none
                                        : BorderSide(
                                      color: primaryColor.withOpacity(0.1),
                                    ),
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor: primaryColor,
                                    child: Text(
                                      player['nomor']?.toString() ?? '-',
                                      style: TextStyle(
                                        color: whiteColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    player['nama'] ?? '-',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: darkTextColor,
                                    ),
                                  ),
                                  subtitle: Row(
                                    children: [
                                      if (player['asal'] != null && player['asal'] != '-') ...[
                                        Icon(Icons.public, size: 12, color: mutedTextColor),
                                        SizedBox(width: 4),
                                        Text(
                                          player['asal'],
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: mutedTextColor,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                      ],
                                      Icon(Icons.calendar_today, size: 12, color: mutedTextColor),
                                      SizedBox(width: 4),
                                      Text(
                                        'Age ${player['umur'] ?? '-'}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: mutedTextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Icon(
                                    Icons.chevron_right,
                                    color: mutedTextColor,
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
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}