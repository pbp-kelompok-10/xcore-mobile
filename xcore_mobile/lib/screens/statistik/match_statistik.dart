import 'package:flutter/material.dart';
import 'package:xcore_mobile/models/statistik_entry.dart'; 
import 'statistik_service.dart';
import '../scoreboard/scoreboard_page.dart';
import '../forum/forum_page.dart';
import '../prediction/prediction_page.dart';
import '../highlight/highlight_page.dart';
import '../lineup/lineup_page.dart';

class MatchStatisticsPage extends StatefulWidget {
  final String matchId;
  final String homeTeam;
  final String awayTeam;
  final String homeTeamCode; // TAMBAH INI
  final String awayTeamCode; // TAMBAH INI

  const MatchStatisticsPage({
    super.key,
    required this.matchId,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeTeamCode, // TAMBAH INI
    required this.awayTeamCode, // TAMBAH INI
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
    Navigator.pop(context); // Kembali ke scoreboard dengan sekali tekan
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

  Widget _buildNavigationCard(String title, IconData icon, Function() onTap) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.green[700]!, Colors.green[600]!],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: Colors.white),
                SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String title, dynamic homeValue, dynamic awayValue, 
                      {bool isPercentage = false, IconData? icon}) {
    String formatValue(dynamic value) {
      if (isPercentage) {
        if (value is double) {
          return '${value.toStringAsFixed(1)}%';
        } else if (value is int) {
          return '$value%';
        }
        return '$value%';
      }
      return value.toString();
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Colors.white, Colors.grey[50]!],
        ),
      ),
      child: Row(
        children: [
          // Home value dengan background
          Container(
            width: 60,
            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[100]!),
            ),
            child: Text(
              formatValue(homeValue),
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 6),
                ],
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14, 
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          // Away value dengan background
          Container(
            width: 60,
            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red[100]!),
            ),
            child: Text(
              formatValue(awayValue),
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.bold,
                color: Colors.red[800],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk build bendera
  Widget _buildFlagWidget(String teamCode, bool isHome) {
    // Pastikan teamCode lowercase dan valid
    String effectiveCode = teamCode.toLowerCase();
    if (effectiveCode.isEmpty || effectiveCode.length != 2) {
      // Fallback jika teamCode tidak valid
      effectiveCode = isHome ? 'id' : 'sg'; // default Indonesia vs Singapore
    }

    final flagUrl = "https://flagcdn.com/w80/$effectiveCode.png";
    
    return Container(
      width: 60,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          flagUrl,
          width: 60,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print("Error loading flag: $flagUrl");
            // Fallback ke container berwarna dengan inisial
            return Container(
              color: isHome ? Colors.green[500] : Colors.red[500],
              child: Center(
                child: Text(
                  effectiveCode.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Colors.grey[200],
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / 
                        loadingProgress.expectedTotalBytes!
                      : null,
                  strokeWidth: 2,
                ),
              ),
            );
          },
        ),
      ),
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
          icon: Icon(Icons.arrow_back_ios_new_rounded, 
                    size: 20, color: Colors.white),
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
              child: Icon(Icons.error_outline, 
                         size: 48, color: Colors.red[400]),
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
              child: Icon(Icons.analytics_outlined, 
                         size: 48, color: Colors.green[400]),
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
          // Header Section - DESAIN BARU
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.green[700]!, Colors.green[500]!],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Stadium dan Waktu di atas
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.stadium, size: 16, color: Colors.white70),
                        SizedBox(width: 6),
                        Text(
                          _statistik!.stadium,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: Colors.white70),
                        SizedBox(width: 6),
                        Text(
                          _formatDate(_statistik!.matchDate),
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                SizedBox(height: 16),
                
                // Score dan Bendera Section
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Home Team - Bendera dan Nama
                      Expanded(
                        child: Column(
                          children: [
                            // Bendera Home
                            _buildFlagWidget(widget.homeTeamCode, true),
                            SizedBox(height: 8),
                            Text(
                              widget.homeTeam,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                      
                      // Score di tengah
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _statistik!.homeScore.toString(),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                '-',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                            Text(
                              _statistik!.awayScore.toString(),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Away Team - Bendera dan Nama
                      Expanded(
                        child: Column(
                          children: [
                            // Bendera Away
                            _buildFlagWidget(widget.awayTeamCode, false),
                            SizedBox(height: 8),
                            Text(
                              widget.awayTeam,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 20),
          
          // Navigation Cards
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildNavigationCard('Forum', Icons.forum, _navigateToForum),
                SizedBox(width: 8),
                _buildNavigationCard('Highlight', Icons.video_library, _navigateToHighlight),
                SizedBox(width: 8),
                _buildNavigationCard('Prediction', Icons.analytics, _navigateToPrediction),
                SizedBox(width: 8),
                _buildNavigationCard('Lineup', Icons.people, _navigateToLineup),
              ],
            ),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.homeTeam,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'TEAM STATISTICS',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            widget.awayTeam,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Statistics Rows
                    _buildStatRow('Passes', _statistik!.homePasses, _statistik!.awayPasses, 
                                icon: Icons.swap_horiz),
                    _buildStatRow('Shoot', _statistik!.homeShots, _statistik!.awayShots, 
                                icon: Icons.sports_soccer),
                    _buildStatRow('Shoot on Target', _statistik!.homeShotsOnTarget, _statistik!.awayShotsOnTarget, 
                                icon: Icons.flag),
                    _buildStatRow('Ball Possession', _statistik!.homePossession, _statistik!.awayPossession, 
                                isPercentage: true, icon: Icons.pie_chart),
                    _buildStatRow('Red Card', _statistik!.homeRedCards, _statistik!.awayRedCards, 
                                icon: Icons.error),
                    _buildStatRow('Yellow Card', _statistik!.homeYellowCards, _statistik!.awayYellowCards, 
                                icon: Icons.warning),
                    _buildStatRow('Offside', _statistik!.homeOffsides, _statistik!.awayOffsides, 
                                icon: Icons.gps_not_fixed),
                    _buildStatRow('Corner', _statistik!.homeCorners, _statistik!.awayCorners, 
                                icon: Icons.circle),
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

  String _formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return dateString;
    }
  }
}