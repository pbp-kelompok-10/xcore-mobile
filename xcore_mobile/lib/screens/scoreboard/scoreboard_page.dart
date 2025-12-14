import 'package:flutter/material.dart';
import 'package:xcore_mobile/models/scoreboard_entry.dart';
import 'package:xcore_mobile/screens/forum/forum_page.dart';
import 'package:xcore_mobile/screens/scoreboard/admin/add_match_page.dart';
import 'package:xcore_mobile/screens/scoreboard/admin/edit_match_page.dart';
import 'package:xcore_mobile/screens/scoreboard/scoreboard_service.dart';
import 'package:xcore_mobile/screens/statistik/match_statistik.dart';
import 'package:xcore_mobile/screens/prediction/prediction_page.dart';
import 'package:xcore_mobile/screens/scoreboard/scoreboard_card.dart';

class ScoreboardPage extends StatefulWidget {
  const ScoreboardPage({super.key});

  @override
  State<ScoreboardPage> createState() => _ScoreboardPageState();
}

class _ScoreboardPageState extends State<ScoreboardPage> {
  late Future<List<ScoreboardEntry>> futureScoreboard;
  bool _isAdmin = false;
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _refreshScoreboard();
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
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 121, 220, 172),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(const Color.fromARGB(255, 50, 92, 52)!),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.green[50],
      
      // APP BAR HIJAU SESUAI TEMA
      appBar: AppBar(
        title: const Text(
          "Scoreboard",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green[700], // Warna Tema Utama
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
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

      body: FutureBuilder<List<ScoreboardEntry>>(
        future: futureScoreboard,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green[700]!),
              ),
            );
          }
          if (_error.isNotEmpty) {
            return _buildErrorState();
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final matches = snapshot.data!;
          // Sorting tanggal ascending
          matches.sort((a, b) => a.matchDate.compareTo(b.matchDate));

          return RefreshIndicator(
            onRefresh: _refreshScoreboard,
            color: Colors.green[700],
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: matches.length,
              itemBuilder: (context, index) {
                final item = matches[index];

                bool showDateHeader = false;
                if (index == 0) {
                  showDateHeader = true;
                } else {
                  final prevItem = matches[index - 1];
                  if (!_isSameDay(item.matchDate, prevItem.matchDate)) {
                    showDateHeader = true;
                  }
                }

                return Column(
                  children: [
                    if (showDateHeader) _buildDateHeader(item.matchDate),
                    
                    GestureDetector(
                      onTap: () {
                        final status = item.status.toLowerCase();
                        if (status == "upcoming") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => PredictionPage(matchId: item.id)),
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
                        matchDate: item.matchDate, // PENTING: Mengirim tanggal untuk jam main
                      ),
                    ),
                    const SizedBox(height: 12), // Jarak antar kartu

                    // Admin Actions
                    if (_isAdmin) ...[
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[600],
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 1,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                              icon: const Icon(Icons.edit, size: 16),
                              label: const Text("Edit Match"),
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
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[600],
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 1,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                              icon: const Icon(Icons.forum, size: 16),
                              label: const Text("Forum"),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => ForumPage(matchId: item.id)),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  // HEADER TANGGAL DENGAN GAYA MODERN (HIJAU)
  Widget _buildDateHeader(DateTime date) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 16.0),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: Colors.green.withOpacity(0.3),
              thickness: 1,
              endIndent: 12,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.05),
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
                     color: Colors.green.shade700),
                const SizedBox(width: 8),
                Text(
                  "${date.day} ${_getMonthName(date.month)} ${date.year}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Divider(
              color: Colors.green.withOpacity(0.3),
              thickness: 1,
              indent: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.sports_soccer_rounded, size: 64, color: Colors.green[300]),
          ),
          const SizedBox(height: 16),
          Text(
            "Belum ada pertandingan",
            style: TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.w500,
              color: Colors.grey[600]
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text('Error loading data: $_error', style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}