import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:xcore_mobile/models/statistik_entry.dart'; 
import '../../services/statistik_service.dart';
import '../scoreboard/scoreboard_page.dart';
import '../forum/forum_page.dart';
import '../prediction/prediction_detail_page.dart';
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

  // Warna dari PROD
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
      MaterialPageRoute(
        builder: (_) => PredictionDetailPage(matchId: widget.matchId)),
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
        title: Text('Hapus Statistik', style: TextStyle(color: darkTextColor)),
        content: Text('Yakin ingin menghapus statistik pertandingan ini?', style: TextStyle(color: mutedTextColor)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal', style: TextStyle(color: mutedTextColor)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );

    if (confirmed == true) {
      try {
        final success = await StatistikService.deleteStatistik(context, widget.matchId);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Statistik berhasil dihapus'),
              backgroundColor: primaryColor,
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
          backgroundColor: primaryColor,
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
        children: [
          // Header "MATCH"
          Text(
            'MATCH STATISTICS',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: primaryColor,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 16),
          
          // Team names dengan VS di tengah DAN BENDERA - DENGAN NAMA NEGARA
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
                        fontWeight: FontWeight.w600,
                        color: darkTextColor,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    // Label HOME
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'HOME',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // VS di tengah
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: accentColor.withOpacity(0.3), width: 2),
                  ),
                  child: Center(
                    child: Text(
                      'VS',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: darkTextColor,
                      ),
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
                        fontWeight: FontWeight.w600,
                        color: darkTextColor,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    // Label AWAY
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'AWAY',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Divider(height: 1, color: mutedTextColor.withOpacity(0.3)),
          SizedBox(height: 8),
          // Match ID
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(Icons.fingerprint, size: 12, color: primaryColor),
                    SizedBox(width: 4),
                    Text(
                      'Match ID: ${widget.matchId}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: primaryColor,
                      ),
                    ),
                  ],
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
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  strokeWidth: 2,
                ),
                SizedBox(height: 16),
                Text(
                  'Loading Statistics...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: mutedTextColor,
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
          
          // Error message dalam KOTAK dengan LEBAR KONSISTEN
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
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
                    'Failed to Load Statistics',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _error,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: mutedTextColor,
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loadStatistik,
                    child: Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  if (_isAdmin)
                    ElevatedButton.icon(
                      icon: Icon(Icons.add, size: 18),
                      label: Text('Tambah Statistik'),
                      onPressed: _addStatistik,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
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
          
          // Empty message dalam KOTAK dengan LEBAR KONSISTEN (sama dengan tabel statistik)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
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
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.analytics_outlined, size: 40, color: primaryColor),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'No Statistics Available',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: darkTextColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Statistics will be available once\nthe match begins',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: mutedTextColor,
                    ),
                  ),
                  SizedBox(height: 24),
                  if (_isAdmin)
                    ElevatedButton.icon(
                      icon: Icon(Icons.add, size: 18),
                      label: Text('Tambah Statistik'),
                      onPressed: _addStatistik,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
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
          ),
        ],
      ),
    );
  }

  bool get _hasStatistik {
    return _statistik != null;
  }

  // Helper method untuk membuat statistik row dengan centering - UKURAN LEBIH KECIL LAGI
  Widget _buildStatistikRowWithCentering({
    required String title,
    required int homeValue,
    required int awayValue,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8), // Diperkecil lagi
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: primaryColor.withOpacity(0.1))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Home value - UKURAN LEBIH KECIL
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                width: 28, // Diperkecil lagi
                padding: EdgeInsets.symmetric(vertical: 3, horizontal: 4), // Diperkecil lagi
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: primaryColor.withOpacity(0.3)),
                ),
                child: Text(
                  homeValue.toString(),
                  style: TextStyle(
                    fontSize: 12, // Diperkecil lagi
                    fontWeight: FontWeight.bold,
                    color: darkTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          
          // Title dengan icon - UKURAN LEBIH KECIL
          Expanded(
            flex: 3,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 12, color: primaryColor), // Diperkecil lagi
                  SizedBox(width: 4), 
                  Flexible(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 10, // Diperkecil lagi
                        fontWeight: FontWeight.w600,
                        color: darkTextColor,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Away value - UKURAN LEBIH KECIL
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                width: 28, // Diperkecil lagi
                padding: EdgeInsets.symmetric(vertical: 3, horizontal: 4), // Diperkecil lagi
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: accentColor.withOpacity(0.3)),
                ),
                child: Text(
                  awayValue.toString(),
                  style: TextStyle(
                    fontSize: 12, // Diperkecil lagi
                    fontWeight: FontWeight.bold,
                    color: darkTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        children: [
          // Navigation Cards di ATAS Header Section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: _buildNavigationCards(),
          ),
          
          SizedBox(height: 8),
          
          // Header Section dengan skor (ketika sudah ada statistik)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: HeaderSection(
              stadium: _statistik!.stadium,
              matchDate: _statistik!.matchDate,
              homeTeam: widget.homeTeam,
              awayTeam: widget.awayTeam,
              homeTeamCode: widget.homeTeamCode,
              awayTeamCode: widget.awayTeamCode,
              homeScore: _statistik!.homeScore,
              awayScore: _statistik!.awayScore,
            ),
          ),
          
          SizedBox(height: 16), // Diperkecil lagi
          
          // Statistics Section Title - UKURAN LEBIH KECIL
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.analytics, size: 16, color: primaryColor), // Diperkecil lagi
                SizedBox(width: 6), 
                Text(
                  'STATISTIK PERTANDINGAN',
                  style: TextStyle(
                    fontSize: 13, // Diperkecil lagi
                    fontWeight: FontWeight.bold,
                    color: darkTextColor,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 8), // Diperkecil lagi
          
          // Statistics Table yang DIKEMBALIKAN ke format asli - UKURAN LEBIH KECIL
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(8), // Diperkecil lagi
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4, // Diperkecil lagi
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Statistics Header dengan NAMA TIM dan STATISTIK di tengah - UKURAN LEBIH KECIL
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8), // Diperkecil lagi
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Home Team
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: Text(
                              widget.homeTeam,
                              style: TextStyle(
                                color: whiteColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 10, // Diperkecil lagi
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ),
                        
                        // Statistics Title
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3), // Diperkecil lagi
                              decoration: BoxDecoration(
                                color: whiteColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12), // Diperkecil lagi
                              ),
                              child: Text(
                                'STATISTIK',
                                style: TextStyle(
                                  color: whiteColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 9, // Diperkecil lagi
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        // Away Team
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: Text(
                              widget.awayTeam,
                              style: TextStyle(
                                color: whiteColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 10, // Diperkecil lagi
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Statistics Rows dengan DIVIDER antar row
                  _buildStatistikRowWithCentering(
                    title: 'Passes',
                    homeValue: _statistik!.homePasses,
                    awayValue: _statistik!.awayPasses,
                    icon: Icons.swap_horiz,
                  ),
                  Divider(height: 0.5, color: Colors.grey[200]),
                  
                  _buildStatistikRowWithCentering(
                    title: 'Total Shots',
                    homeValue: _statistik!.homeShots,
                    awayValue: _statistik!.awayShots,
                    icon: Icons.sports_soccer,
                  ),
                  Divider(height: 0.5, color: Colors.grey[200]),
                  
                  _buildStatistikRowWithCentering(
                    title: 'Shots on Target',
                    homeValue: _statistik!.homeShotsOnTarget,
                    awayValue: _statistik!.awayShotsOnTarget,
                    icon: Icons.flag,
                  ),
                  Divider(height: 0.5, color: Colors.grey[200]),
                  
                  // Ball Possession dengan % di samping angka - UKURAN LEBIH KECIL
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8), // Diperkecil lagi
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: primaryColor.withOpacity(0.1))),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [whiteColor, primaryColor.withOpacity(0.05)],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Home value dengan background dan % di samping
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: Container(
                              width: 40, // Diperkecil lagi
                              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 4), // Diperkecil lagi
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: primaryColor.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _statistik!.homePossession.toStringAsFixed(0),
                                    style: TextStyle(
                                      fontSize: 12, // Diperkecil lagi
                                      fontWeight: FontWeight.bold,
                                      color: darkTextColor,
                                    ),
                                  ),
                                  SizedBox(width: 1), // Diperkecil
                                  Text(
                                    '%',
                                    style: TextStyle(
                                      fontSize: 9, // Diperkecil lagi
                                      fontWeight: FontWeight.w500,
                                      color: darkTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        // Title di tengah - UKURAN LEBIH KECIL
                        Expanded(
                          flex: 3,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.pie_chart, size: 12, color: primaryColor), // Diperkecil lagi
                                SizedBox(width: 4), 
                                Flexible(
                                  child: Text(
                                    'Ball Possession',
                                    style: TextStyle(
                                      fontSize: 10, // Diperkecil lagi
                                      fontWeight: FontWeight.w600,
                                      color: darkTextColor,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // Away value dengan background dan % di samping
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: Container(
                              width: 40, // Diperkecil lagi
                              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 4), // Diperkecil lagi
                              decoration: BoxDecoration(
                                color: accentColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: accentColor.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _statistik!.awayPossession.toStringAsFixed(0),
                                    style: TextStyle(
                                      fontSize: 12, // Diperkecil lagi
                                      fontWeight: FontWeight.bold,
                                      color: darkTextColor,
                                    ),
                                  ),
                                  SizedBox(width: 1), // Diperkecil
                                  Text(
                                    '%',
                                    style: TextStyle(
                                      fontSize: 9, // Diperkecil lagi
                                      fontWeight: FontWeight.w500,
                                      color: darkTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 0.5, color: Colors.grey[200]),
                  
                  _buildStatistikRowWithCentering(
                    title: 'Yellow Cards',
                    homeValue: _statistik!.homeYellowCards,
                    awayValue: _statistik!.awayYellowCards,
                    icon: Icons.warning,
                  ),
                  Divider(height: 0.5, color: Colors.grey[200]),
                  
                  _buildStatistikRowWithCentering(
                    title: 'Red Cards',
                    homeValue: _statistik!.homeRedCards,
                    awayValue: _statistik!.awayRedCards,
                    icon: Icons.error,
                  ),
                  Divider(height: 0.5, color: Colors.grey[200]),
                  
                  _buildStatistikRowWithCentering(
                    title: 'Offsides',
                    homeValue: _statistik!.homeOffsides,
                    awayValue: _statistik!.awayOffsides,
                    icon: Icons.gps_not_fixed,
                  ),
                  Divider(height: 0.5, color: Colors.grey[200]),
                  
                  _buildStatistikRowWithCentering(
                    title: 'Corners',
                    homeValue: _statistik!.homeCorners,
                    awayValue: _statistik!.awayCorners,
                    icon: Icons.circle,
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 20), // Diperkecil lagi
          
          // Info footer dengan LEBAR KONSISTEN - UKURAN LEBIH KECIL
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: EdgeInsets.all(8), // Diperkecil lagi
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: primaryColor.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 12, color: primaryColor), // Diperkecil lagi
                  SizedBox(width: 6), 
                  Expanded(
                    child: Text(
                      'Statistik diperbarui secara real-time selama pertandingan berlangsung',
                      style: TextStyle(
                        fontSize: 9, // Diperkecil lagi
                        color: mutedTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 20), // Diperkecil lagi
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        title: Text(
          'Match Statistics',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: primaryColor,
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
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              tooltip: 'Tambah Statistik',
            )
          : null,
    );
  }
}
