import 'package:flutter/material.dart';
import 'package:xcore_mobile/models/scoreboard_entry.dart';
import 'package:xcore_mobile/screens/forum/forum_page.dart';
import 'package:xcore_mobile/screens/scoreboard/admin/add_match_page.dart';
import 'package:xcore_mobile/screens/scoreboard/admin/edit_match_page.dart';
import 'package:xcore_mobile/services/scoreboard_service.dart';
import 'package:xcore_mobile/screens/statistik/match_statistik.dart';
import 'package:xcore_mobile/screens/prediction/prediction_detail_page.dart';
import 'package:xcore_mobile/screens/scoreboard/scoreboard_card.dart';

class ScoreboardPage extends StatefulWidget {
  final Function(int)? onSwitchTab; 

  const ScoreboardPage({super.key, this.onSwitchTab});

  @override
  State<ScoreboardPage> createState() => _ScoreboardPageState();
}

class _ScoreboardPageState extends State<ScoreboardPage> {
  late Future<List<ScoreboardEntry>> futureScoreboard;
  bool _isAdmin = false;
  bool _isLoading = true;
  String _error = '';
  
  // Controller dan variabel untuk Search
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _refreshScoreboard();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    try {
      final adminStatus = await ScoreboardService.fetchAdminStatus(context);
      if (mounted) {
        setState(() {
          _isAdmin = adminStatus;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshScoreboard() async {
    setState(() {
      futureScoreboard = ScoreboardService.fetchScoreboard();
      _error = '';
    });
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _getMonthName(int month) {
    const months = [
      "Januari", "Februari", "Maret", "April", "Mei", "Juni",
      "Juli", "Agustus", "September", "Oktober", "November", "Desember"
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    // Definisi Warna dari PROD
    const Color primaryColor = Color(0xFF4AA69B);
    const Color scaffoldBgColor = Color(0xFFE8F6F4);
    const Color darkTextColor = Color(0xFF2C5F5A);
    const Color mutedTextColor = Color(0xFF6B8E8A);

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: scaffoldBgColor,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: scaffoldBgColor, 
      
      appBar: AppBar(
        title: const Text(
          "Scoreboard",
          style: TextStyle(
            fontFamily: 'Nunito Sans',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false, // Hilangkan tombol back default
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _refreshScoreboard,
          ),
          if (_isAdmin)
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddMatchPage()),
                );
                if (result == true) _refreshScoreboard();
              },
            ),
        ],
      ),

      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: "Cari negara...",
                hintStyle: const TextStyle(
                  fontFamily: 'Nunito Sans',
                  color: mutedTextColor,
                ),
                prefixIcon: const Icon(Icons.search, color: primaryColor),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: primaryColor.withOpacity(0.1), width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: primaryColor, width: 1.5),
                ),
              ),
            ),
          ),

          // List Pertandingan
          Expanded(
            child: FutureBuilder<List<ScoreboardEntry>>(
              future: futureScoreboard,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  );
                }
                if (_error.isNotEmpty) {
                  return _buildErrorState(mutedTextColor);
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState(primaryColor, mutedTextColor);
                }

                // Logika Filtering
                final allMatches = snapshot.data!;
                final filteredMatches = allMatches.where((match) {
                  return match.homeTeam.toLowerCase().contains(_searchQuery) ||
                          match.awayTeam.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filteredMatches.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off_rounded, size: 64, color: mutedTextColor),
                        const SizedBox(height: 16),
                        Text(
                          "Tidak ditemukan match untuk \"$_searchQuery\"",
                          style: const TextStyle(
                            fontFamily: 'Nunito Sans',
                            color: mutedTextColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Sorting tanggal ascending
                filteredMatches.sort((a, b) => a.matchDate.compareTo(b.matchDate));

                return RefreshIndicator(
                  onRefresh: _refreshScoreboard,
                  color: primaryColor,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredMatches.length,
                    itemBuilder: (context, index) {
                      final item = filteredMatches[index];

                      bool showDateHeader = false;
                      if (index == 0) {
                        showDateHeader = true;
                      } else {
                        final prevItem = filteredMatches[index - 1];
                        if (!_isSameDay(item.matchDate, prevItem.matchDate)) {
                          showDateHeader = true;
                        }
                      }

                      return Column(
                        children: [
                          if (showDateHeader) 
                            _buildDateHeader(item.matchDate, primaryColor, darkTextColor),
                          
                          GestureDetector(
                            onTap: () {
                              final status = item.status.toLowerCase();
                              if (status == "upcoming") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PredictionDetailPage(matchId: item.id)),
                                  );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MatchStatisticsPage(
                                      matchId: item.id,
                                      homeTeam: item.homeTeam,
                                      awayTeam: item.awayTeam,
                                      homeTeamCode: item.homeTeamCode,
                                      awayTeamCode: item.awayTeamCode,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: ScoreboardMatchCard(
                              homeTeam: item.homeTeam,
                              awayTeam: item.awayTeam,
                              homeCode: item.homeTeamCode,
                              awayCode: item.awayTeamCode,
                              status: item.status,
                              homeScore: item.homeScore,
                              awayScore: item.awayScore,
                              stadium: item.stadium,
                              group: item.group,
                              matchDate: item.matchDate, 
                            ),
                          ),
                          const SizedBox(height: 12),

                          // [UPDATE] Action Buttons 
                          Row(
                            children: [
                              // Forum Button (Visible to ALL users) -> Warna Primary
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 1,
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                  ),
                                  icon: const Icon(Icons.forum, size: 16),
                                  label: const Text(
                                    "Forum",
                                    style: TextStyle(
                                      fontFamily: 'Nunito Sans',
                                      fontWeight: FontWeight.w600
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => ForumPage(matchId: item.id)),
                                    );
                                  },
                                ),
                              ),

                              // Edit Button (Visible to ADMIN only) -> Warna Dark Teal
                              if (_isAdmin) ...[
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: darkTextColor, // Beda warna biar distinct
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      elevation: 1,
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                    ),
                                    icon: const Icon(Icons.edit, size: 16),
                                    label: const Text(
                                      "Edit Match",
                                      style: TextStyle(
                                        fontFamily: 'Nunito Sans',
                                        fontWeight: FontWeight.w600
                                      ),
                                    ),
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => EditMatchPage(matchEntry: item)),
                                      );
                                      if (result == true) _refreshScoreboard();
                                    },
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader(DateTime date, Color primaryColor, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 16.0),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: primaryColor.withOpacity(0.4),
              thickness: 1,
              endIndent: 12,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: primaryColor.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calendar_today_rounded, 
                     size: 14, 
                     color: primaryColor),
                const SizedBox(width: 8),
                Text(
                  "${date.day} ${_getMonthName(date.month)} ${date.year}",
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Divider(
              color: primaryColor.withOpacity(0.4),
              thickness: 1,
              indent: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Color primaryColor, Color mutedColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.sports_soccer_rounded, size: 64, color: primaryColor),
          ),
          const SizedBox(height: 16),
          Text(
            "Belum ada pertandingan",
            style: TextStyle(
              fontFamily: 'Nunito Sans',
              fontSize: 16, 
              fontWeight: FontWeight.w600,
              color: mutedColor
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Color errorColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Color(0xFFEF4444)),
          const SizedBox(height: 16),
          Text(
            'Error loading data: $_error', 
            style: TextStyle(
              fontFamily: 'Nunito Sans',
              color: errorColor
            )
          ),
        ],
      ),
    );
  }
}