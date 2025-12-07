import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
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
import 'widgets/flag_widget.dart'; // Import FlagWidget
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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    try {
      final admin_status = await StatistikService.fetchAdminStatus(context);
      setState(() {
        _isAdmin = admin_status;
      });
    } catch (e) {
      print('Error checking admin status: $e');
    }
  }

  Future<void> _loadStatistik() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });
      
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
      print('Error loading statistik: $e');
    }
  }

  // Navigation functions
  void _navigateToScoreboard() {
    Navigator.pop(context);
  }

  void _navigateToForum() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ForumPage(matchId: widget.matchId)),
    );
  }

  void _navigateToHighlight() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HighlightPage(matchId: widget.matchId)),
    );
  }

  void _navigateToPrediction() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PredictionPage(matchId: widget.matchId)),
    );
  }

  void _navigateToLineup() {
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
        title: Text('Hapus Statistik'),
        content: Text('Yakin ingin menghapus statistik pertandingan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await StatistikService.deleteStatistik(context, widget.matchId);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Statistik berhasil dihapus'),
              backgroundColor: Colors.green[700],
              duration: Duration(seconds: 2),
            )
          );
          _loadStatistik(); // Auto refresh setelah delete
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Gagal menghapus statistik'),
              backgroundColor: Colors.red[600],
              duration: Duration(seconds: 2),
            )
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red[600],
            duration: Duration(seconds: 3),
          )
        );
      }
    }
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

  // Navigation Cards yang selalu tampil
  Widget _buildNavigationCards() {
    return NavigationCards(
      onForumTap: _navigateToForum,
      onHighlightTap: _navigateToHighlight,
      onPredictionTap: _navigateToPrediction,
      onLineupTap: _navigateToLineup,
      matchId: widget.matchId,
    );
  }

  // Widget untuk menampilkan header seperti di AddStatistikPage (tanpa skor) DENGAN FlagWidget
  Widget _buildMatchHeaderWithoutScore() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[100]!),
      ),
      child: Column(
        children: [
          // Header "MATCH" (opsional, bisa dihapus juga kalo mau)
          Text(
            'MATCH',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
              letterSpacing: 1.0,
            ),
          ),
          SizedBox(height: 16),
          
          // Team names dengan VS di tengah DAN BENDERA
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Home team dengan bendera di atas nama
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Bendera menggunakan FlagWidget
                    FlagWidget(
                      teamCode: widget.homeTeamCode,
                      isHome: true,
                      width: 60,
                      height: 40,
                    ),
                    SizedBox(height: 8),
                    // Nama tim
                    Text(
                      widget.homeTeam,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // VS di tengah TANPA SKOR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'VS',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
              
              // Away team dengan bendera di atas nama
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Bendera menggunakan FlagWidget
                    FlagWidget(
                      teamCode: widget.awayTeamCode,
                      isHome: false,
                      width: 60,
                      height: 40,
                    ),
                    SizedBox(height: 8),
                    // Nama tim
                    Text(
                      widget.awayTeam,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Divider(height: 1, color: Colors.green[200]),
          SizedBox(height: 8),
          // Hanya tampilkan Match ID saja
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Match ID: ${widget.matchId}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Loading state DENGAN Navigation Cards
  Widget _buildLoadingState() {
    return Column(
      children: [
        // Navigation Cards di atas loading indicator
        Padding(
          padding: EdgeInsets.all(16),
          child: _buildNavigationCards(),
        ),
        Expanded(
          child: Center(
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
          ),
        ),
      ],
    );
  }

  // Error state DENGAN Navigation Cards
  Widget _buildErrorState() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Navigation Cards di atas
          Padding(
            padding: EdgeInsets.all(16),
            child: _buildNavigationCards(),
          ),
          
          // Match Header dengan bendera
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: _buildMatchHeaderWithoutScore(),
          ),
          
          SizedBox(height: 24),
          
          // Error message
          Padding(
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
                  'Failed to Load Statistics',
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
                ElevatedButton(
                  onPressed: _loadStatistik,
                  child: Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                  ),
                ),
                SizedBox(height: 12),
                if (_isAdmin)
                  ElevatedButton.icon(
                    icon: Icon(Icons.add, size: 18),
                    label: Text('Tambah Statistik'),
                    onPressed: _addStatistik,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
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
        ],
      ),
    );
  }

  // Empty state (belum ada statistik) DENGAN Navigation Cards dan Match Header
  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Navigation Cards di atas
          Padding(
            padding: EdgeInsets.all(16),
            child: _buildNavigationCards(),
          ),
          
          // Match Header dengan bendera
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: _buildMatchHeaderWithoutScore(),
          ),
          
          SizedBox(height: 24),
          
          // Empty message
          Padding(
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
                  'No Statistics Available',
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
                if (_isAdmin)
                  ElevatedButton.icon(
                    icon: Icon(Icons.add, size: 18),
                    label: Text('Tambah Statistik'),
                    onPressed: _addStatistik,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
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
        ],
      ),
    );
  }

  bool get _hasStatistik {
    return _statistik != null;
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        children: [
          // Navigation Cards di ATAS Header Section (setelah menambahkan statistik)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: _buildNavigationCards(),
          ),
          
          SizedBox(height: 8),
          
          // Header Section dengan skor (ketika sudah ada statistik)
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
        actions: _isAdmin ? [
          if (_hasStatistik)
            IconButton(
              icon: Icon(Icons.edit, color: Colors.white),
              onPressed: _editStatistik,
              tooltip: 'Edit Statistik',
            ),
          if (_hasStatistik)
            IconButton(
              icon: Icon(Icons.delete, color: Colors.white),
              onPressed: _deleteStatistik,
              tooltip: 'Hapus Statistik',
            ),
        ] : null,
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _error.isNotEmpty
              ? _buildErrorState()
              : !_hasStatistik
                  ? _buildEmptyState()
                  : _buildContent(),
      floatingActionButton: _isAdmin && !_hasStatistik
          ? FloatingActionButton(
              onPressed: _addStatistik,
              child: Icon(Icons.add),
              backgroundColor: Colors.orange,
              tooltip: 'Tambah Statistik',
            )
          : null,
    );
  }
}