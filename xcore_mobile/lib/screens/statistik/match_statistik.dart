import 'package:flutter/material.dart';
import 'package:xcore_mobile/models/statistik_entry.dart'; 
import 'statistik_service.dart';
import '../scoreboard/scoreboard_page.dart';
import '../forum/forum_page.dart';
import '../prediction/prediction_page.dart';
import '../highlight/highlight_page.dart';
import '../lineup/lineup_page.dart';
import 'widgets/header_section.dart';
import 'widgets/navigation_cards.dart';
import 'widgets/statistik_row.dart';
import 'package:xcore_mobile/services/auth_service.dart';
import 'admin/add_statistik_page.dart';
import 'admin/edit_statistik_page.dart';

class MatchStatisticsPage extends StatefulWidget {
  final String matchId;
  final String homeTeam;
  final String awayTeam;
  final String homeTeamCode;
  final String awayTeamCode;

  const MatchStatisticsPage({
    super.key,
    required this.matchId,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeTeamCode,
    required this.awayTeamCode,
  });

  @override
  _MatchStatisticsPageState createState() => _MatchStatisticsPageState();
}

class _MatchStatisticsPageState extends State<MatchStatisticsPage> {
  StatistikEntry? _statistik;
  bool _isLoading = true;
  String _error = '';
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadStatistik();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    final isAdmin = await AuthService.isAdmin();
    setState(() {
      _isAdmin = isAdmin;
    });
  }

  Future<void> _loadStatistik() async {
    try {
      final statistik = await StatistikService.fetchStatistik(widget.matchId);
      setState(() {
        _statistik = statistik;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // Navigation functions
  void _navigateToScoreboard() {
    _showSnackBar("Kembali ke Scoreboard");
    Navigator.pop(context);
  }

  void _navigateToForum() {
    _showSnackBar("Membuka Forum");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ForumPage(matchId: widget.matchId)),
    );
  }

  void _navigateToHighlight() {
    _showSnackBar("Membuka Highlight");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HighlightPage(matchId: widget.matchId)),
    );
  }

  void _navigateToPrediction() {
    _showSnackBar("Membuka Prediction");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PredictionPage()),
    );
  }

  void _navigateToLineup() {
    _showSnackBar("Membuka Lineup");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LineupPage(matchId: widget.matchId)),
    );
  }

  // Admin functions
  void _addStatistik() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddStatistikPage(
          matchId: widget.matchId,
          homeTeam: widget.homeTeam,
          awayTeam: widget.awayTeam,
          onStatistikAdded: _loadStatistik,
        ),
      ),
    );
  }

  void _editStatistik() {
    if (_statistik != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditStatistikPage(
            statistik: _statistik!,
            onStatistikUpdated: _loadStatistik,
          ),
        ),
      );
    }
  }

  void _deleteStatistik() async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFFFFF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Hapus Statistik',
          style: TextStyle(
            fontFamily: 'Nunito Sans',
            fontWeight: FontWeight.w700,
            color: Color(0xFF2C5F5A),
          ),
        ),
        content: const Text(
          'Yakin ingin menghapus statistik pertandingan ini?',
          style: TextStyle(
            fontFamily: 'Nunito Sans',
            color: Color(0xFF6B8E8A),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Batal',
              style: TextStyle(
                fontFamily: 'Nunito Sans',
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Hapus',
              style: TextStyle(
                fontFamily: 'Nunito Sans',
                fontWeight: FontWeight.w600,
                color: Color(0xFFEF4444),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await StatistikService.deleteStatistik(widget.matchId);
        if (success) {
          _showSnackBar('Statistik berhasil dihapus');
          _loadStatistik();
        } else {
          _showSnackBar('Gagal menghapus statistik');
        }
      } catch (e) {
        _showSnackBar('Error: $e');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              fontFamily: 'Nunito Sans',
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: const Color(0xFF4AA69B),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
  }

  // Build admin FAB
  Widget _buildAdminFab() {
    if (!_isAdmin) return const SizedBox();

    return FloatingActionButton(
      onPressed: _statistik == null ? _addStatistik : _editStatistik,
      backgroundColor: const Color(0xFF4AA69B),
      child: Icon(_statistik == null ? Icons.add : Icons.edit, color: Colors.white),
    );
  }

  // Build admin actions
  Widget _buildAdminActions() {
    if (!_isAdmin || _statistik == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.edit, size: 18),
              label: const Text(
                'Edit Statistik',
                style: TextStyle(
                  fontFamily: 'Nunito Sans',
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: _editStatistik,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4AA69B),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.delete, size: 18),
              label: const Text(
                'Hapus',
                style: TextStyle(
                  fontFamily: 'Nunito Sans',
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: _deleteStatistik,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Loading state
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Color(0xFF4AA69B),
          ),
          const SizedBox(height: 16),
          const Text(
            'Loading Statistics...',
            style: TextStyle(
              fontFamily: 'Nunito Sans',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B8E8A),
            ),
          ),
          if (_isAdmin && _statistik == null) ...[
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text(
                'Tambah Statistik',
                style: TextStyle(
                  fontFamily: 'Nunito Sans',
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: _addStatistik,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4AA69B),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Error state
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: const Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 24),
            const Text(
              'Failed to Load',
              style: TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2C5F5A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 14,
                color: Color(0xFF6B8E8A),
              ),
            ),
            const SizedBox(height: 24),
            if (_isAdmin)
              ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text(
                  'Tambah Statistik',
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: _addStatistik,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4AA69B),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Empty state
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 80,
              color: const Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Statistics',
              style: TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2C5F5A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Statistics will be available once\nthe match begins',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 14,
                color: Color(0xFF6B8E8A),
              ),
            ),
            const SizedBox(height: 24),
            if (_isAdmin)
              ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text(
                  'Tambah Statistik',
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: _addStatistik,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4AA69B),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // Header Section
          HeaderSection(
            stadium: _statistik!.stadium,
            matchDate: _statistik!.matchDate,
            homeTeam: widget.homeTeam,
            awayTeam: widget.awayTeam,
            homeTeamCode: widget.homeTeamCode,
            awayTeamCode: widget.awayTeamCode,
            homeScore: _statistik!.homeScore,
            awayScore: _statistik!.awayScore,
          ),
          
          const SizedBox(height: 20),
          
          // Admin Actions
          _buildAdminActions(),
          
          // Navigation Cards
          NavigationCards(
            onForumTap: _navigateToForum,
            onHighlightTap: _navigateToHighlight,
            onPredictionTap: _navigateToPrediction,
            onLineupTap: _navigateToLineup,
            matchId: widget.matchId,
          ),
          
          const SizedBox(height: 24),
          
          // Statistics Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  children: [
                    // Statistics Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF4AA69B), Color(0xFF56BDA9)],
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.homeTeam,
                              style: const TextStyle(
                                fontFamily: 'Nunito Sans',
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.left,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Expanded(
                            child: Text(
                              'TEAM STATISTICS',
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              widget.awayTeam,
                              style: const TextStyle(
                                fontFamily: 'Nunito Sans',
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.right,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Statistics Rows
                    StatistikRow(
                      title: 'Passes',
                      homeValue: _statistik!.homePasses,
                      awayValue: _statistik!.awayPasses,
                      icon: Icons.swap_horiz,
                    ),
                    StatistikRow(
                      title: 'Shoot',
                      homeValue: _statistik!.homeShots,
                      awayValue: _statistik!.awayShots,
                      icon: Icons.sports_soccer,
                    ),
                    StatistikRow(
                      title: 'Shoot on Target',
                      homeValue: _statistik!.homeShotsOnTarget,
                      awayValue: _statistik!.awayShotsOnTarget,
                      icon: Icons.flag,
                    ),
                    StatistikRow(
                      title: 'Ball Possession',
                      homeValue: _statistik!.homePossession,
                      awayValue: _statistik!.awayPossession,
                      isPercentage: true,
                      icon: Icons.pie_chart,
                    ),
                    StatistikRow(
                      title: 'Red Card',
                      homeValue: _statistik!.homeRedCards,
                      awayValue: _statistik!.awayRedCards,
                      icon: Icons.error,
                    ),
                    StatistikRow(
                      title: 'Yellow Card',
                      homeValue: _statistik!.homeYellowCards,
                      awayValue: _statistik!.awayYellowCards,
                      icon: Icons.warning,
                    ),
                    StatistikRow(
                      title: 'Offside',
                      homeValue: _statistik!.homeOffsides,
                      awayValue: _statistik!.awayOffsides,
                      icon: Icons.gps_not_fixed,
                    ),
                    StatistikRow(
                      title: 'Corner',
                      homeValue: _statistik!.homeCorners,
                      awayValue: _statistik!.awayCorners,
                      icon: Icons.circle,
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F6F4),
      appBar: AppBar(
        title: const Text(
          'Match Statistics',
          style: TextStyle(
            fontFamily: 'Nunito Sans',
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF4AA69B),
        foregroundColor: const Color(0xFFFFFFFF),
        elevation: 2,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: _navigateToScoreboard,
        ),
        actions: _isAdmin ? [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFFFFFFFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Text(
                    'Admin Options',
                    style: TextStyle(
                      fontFamily: 'Nunito Sans',
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2C5F5A),
                    ),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.add, color: Color(0xFF4AA69B)),
                        title: const Text(
                          'Tambah Statistik',
                          style: TextStyle(
                            fontFamily: 'Nunito Sans',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _addStatistik();
                        },
                      ),
                      if (_statistik != null) ...[
                        ListTile(
                          leading: const Icon(Icons.edit, color: Color(0xFF4AA69B)),
                          title: const Text(
                            'Edit Statistik',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            _editStatistik();
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.delete, color: Color(0xFFEF4444)),
                          title: const Text(
                            'Hapus Statistik',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFEF4444),
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            _deleteStatistik();
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ] : null,
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _error.isNotEmpty
              ? _buildErrorState()
              : _statistik == null
                  ? _buildEmptyState()
                  : _buildContent(),
      floatingActionButton: _buildAdminFab(),
    );
  }
}