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
      setState(() {
        _isAdmin = adminStatus;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      
      appBar: AppBar(
        title: const Text(
          "⚽ Xcore",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // TOMBOL REFRESH
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.blue),
            onPressed: _refreshScoreboard,
          ),

          if (_isAdmin)
            IconButton(
              icon: const Icon(Icons.add, color: Colors.teal),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddMatchPage(),
                  ),
                );
                // Jika Add/Edit Match berhasil (mengembalikan true), refresh data
                if (result == true) {
                  _refreshScoreboard();
                }
              },
            ),
        ],
      ),

      body: FutureBuilder(
        future: futureScoreboard,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_error.isNotEmpty) {
            return Center(child: Text('Error: $_error'));
          }
          
          if (snapshot.hasError) {
             return Center(child: Text('Error loading data: ${snapshot.error.toString()}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No scoreboard found"));
          }

          final matches = snapshot.data!;

          return RefreshIndicator( 
            onRefresh: _refreshScoreboard,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: matches.length,
              itemBuilder: (context, index) {
                final item = matches[index];

                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        final status = item.status.toLowerCase();

                        if (status == "upcoming") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PredictionPage(),
                            ),
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
                      ),
                    ),
                    const SizedBox(height: 8),

                    if (_isAdmin)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.edit, color: Colors.white),
                          label: const Text("Edit Match", style: TextStyle(color: Colors.white)),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditMatchPage(matchEntry: item),
                              ),
                            );
                            // Jika Edit Match berhasil (mengembalikan true), refresh data
                            if (result == true) {
                              _refreshScoreboard();
                            }
                          },
                        ),
                      ),

                    if (_isAdmin) const SizedBox(height: 8),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.forum, color: Colors.white),
                        label: const Text("Open Match Forum", style: TextStyle(color: Colors.white)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ForumPage(matchId: item.id),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}