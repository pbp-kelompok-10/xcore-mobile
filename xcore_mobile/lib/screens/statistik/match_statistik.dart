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

  @override
  void initState() {
    super.initState();
    _loadStatistik();
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

  // Fungsi navigation yang konsisten
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
      MaterialPageRoute(builder: (context) => PredictionPage(matchId: widget.matchId)),
    );
  }

  void _navigateToLineup() {
    _showSnackBar("Membuka Lineup");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LineupPage(matchId: widget.matchId)),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green[600],
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
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
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green[700]!),
            strokeWidth: 2,
          ),
          SizedBox(height: 16),
          Text(
            'Loading Statistics...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
            ),
            SizedBox(height: 20),
            Text(
              'Failed to Load',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8),
            Text(
              _error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              icon: Icon(Icons.refresh_rounded, size: 18),
              label: Text('Try Again'),
              onPressed: _loadStatistik,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.analytics_outlined, size: 48, color: Colors.green[400]),
            ),
            SizedBox(height: 20),
            Text(
              'No Statistics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Statistics will be available once\nthe match begins',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              icon: Icon(Icons.refresh_rounded, size: 18),
              label: Text('Refresh'),
              onPressed: _loadStatistik,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
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
      physics: BouncingScrollPhysics(),
      child: Column(
        children: [
          // Header Section menggunakan widget terpisah
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
          
          SizedBox(height: 20),
          
          // Navigation Cards menggunakan widget terpisah
          NavigationCards(
            onForumTap: _navigateToForum,
            onHighlightTap: _navigateToHighlight,
            onPredictionTap: _navigateToPrediction,
            onLineupTap: _navigateToLineup,
          ),
          
          SizedBox(height: 24),
          
          // Statistics Section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  children: [
                    // Statistics Header
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.green[700]!, Colors.green[600]!],
                        ),
                      ),
                      child: Row(
                        // diubah
                        children: [
                          Expanded(
                            child: Text(
                              widget.homeTeam,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.left,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'TEAM STATISTICS',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              widget.awayTeam,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.right,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                        // end diubah
                      ),

                    ),
                    
                    // Statistics Rows menggunakan widget terpisah
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
          
          SizedBox(height: 30),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Match Statistics',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.green[700],
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.white),
          onPressed: _navigateToScoreboard,
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _error.isNotEmpty
              ? _buildErrorState()
              : _statistik == null
                  ? _buildEmptyState()
                  : _buildContent(),
    );
  }
}