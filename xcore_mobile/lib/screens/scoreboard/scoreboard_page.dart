import 'package:flutter/material.dart';
import 'package:xcore_mobile/models/scoreboard_entry.dart';
import 'package:xcore_mobile/screens/forum/forum_page.dart';
import 'package:xcore_mobile/screens/scoreboard/admin/add_match_page.dart';
import 'package:xcore_mobile/screens/scoreboard/admin/edit_match_page.dart';
import 'package:xcore_mobile/screens/scoreboard/scoreboard_service.dart';
import 'package:xcore_mobile/screens/statistik/match_statistik.dart';
import 'package:xcore_mobile/screens/prediction/prediction_detail_page.dart';
import 'package:xcore_mobile/screens/scoreboard/scoreboard_card.dart';

class ScoreboardPage extends StatefulWidget {
  final Function(int)? onSwitchTab; // Function untuk ganti tab

  const ScoreboardPage({super.key, this.onSwitchTab});

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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFE8F6F4),
        body: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF4AA69B),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE8F6F4),
      appBar: AppBar(
        title: const Text(
          "Scoreboard",
          style: TextStyle(
            fontFamily: 'Nunito Sans',
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 2,
        backgroundColor: const Color(0xFF4AA69B),
        foregroundColor: const Color(0xFFFFFFFF),
        
        // --- PERBAIKAN 1: PAKSA HILANGKAN TOMBOL BACK ---
        automaticallyImplyLeading: false, 
        // ------------------------------------------------
        
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFFFFFFF)),
            onPressed: _refreshScoreboard,
          ),
          if (_isAdmin)
            IconButton(
              icon: const Icon(Icons.add, color: Color(0xFFFFFFFF)),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddMatchPage(),
                  ),
                );
                if (result == true) {
                  _refreshScoreboard();
                }
              },
            ),
        ],
      ),
      body: FutureBuilder<List<ScoreboardEntry>>(
        future: futureScoreboard,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF4AA69B)),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Belum ada pertandingan tersedia."));
          }

          final matches = snapshot.data!;

          return RefreshIndicator(
            color: const Color(0xFF4AA69B),
            onRefresh: _refreshScoreboard,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              itemCount: matches.length,
              itemBuilder: (context, index) {
                final item = matches[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: GestureDetector(
                    onTap: () {
                      final status = item.status.toLowerCase();

                      if (status == "upcoming") {                      
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PredictionDetailPage(matchId: item.id)),
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
                      isAdmin: _isAdmin,
                      onEdit: _isAdmin
                          ? () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EditMatchPage(matchEntry: item),
                                ),
                              );
                              if (result == true) {
                                _refreshScoreboard();
                              }
                            }
                          : null,
                      onForum: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ForumPage(matchId: item.id),
                          ),
                        );
                      },
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