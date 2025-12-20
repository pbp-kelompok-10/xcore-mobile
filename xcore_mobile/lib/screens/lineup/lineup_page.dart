// lineup/lineup_page.dart
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:xcore_mobile/screens/lineup/lineup_service.dart';
import 'package:xcore_mobile/models/lineup_entry.dart';
import 'package:xcore_mobile/models/scoreboard_entry.dart';
import 'package:xcore_mobile/screens/lineup/lineup_detail_screen.dart';
import 'package:xcore_mobile/screens/lineup/create_edit_lineup_screen.dart';

class LineupPage extends StatefulWidget {
  final String matchId;

  const LineupPage({super.key, required this.matchId});

  @override
  _LineupPageState createState() => _LineupPageState();
}

class _LineupPageState extends State<LineupPage> {
  MatchLineupResponse? _lineupData;
  bool _isLoading = true;
  String _error = '';
  bool _isAdmin = false;

  // Warna konsisten dengan MatchStatisticsPage dan ForumPage
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
    _loadLineup();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    try {
      final admin_status = await LineupService.fetchAdminStatus(context);
      setState(() {
        _isAdmin = admin_status;
        debugPrint("🔐 _isAdmin: $_isAdmin");
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadLineup() async {
    try {
      final lineupData = await LineupService.fetchLineup(widget.matchId);
      setState(() {
        _lineupData = lineupData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _navigateToCreateEditLineup() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateEditLineupScreen(
          match: _lineupData!.match,
          homeLineup: _lineupData?.homeLineup,
          awayLineup: _lineupData?.awayLineup,
          isEdit:
          _lineupData != null &&
              (_lineupData!.homeLineup != null ||
                  _lineupData!.awayLineup != null),
        ),
      ),
    ).then((_) {
      // Refresh lineup setelah create/edit
      _loadLineup();
    });
  }

  void _deleteLineup() async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: whiteColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          'Hapus Lineup',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: darkTextColor,
          ),
        ),
        content: Text(
          'Yakin ingin menghapus lineup pertandingan ini?',
          style: TextStyle(
            color: mutedTextColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: mutedTextColor,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Hapus',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        bool success = true;

        // Delete both home and away lineups
        if (_lineupData?.homeLineup != null) {
          success =
              await LineupService.deleteLineup(_lineupData!.homeLineup!.id) &&
                  success;
        }
        if (_lineupData?.awayLineup != null) {
          success =
              await LineupService.deleteLineup(_lineupData!.awayLineup!.id) &&
                  success;
        }

        if (success) {
          _showSnackBar('✅ Lineup berhasil dihapus');
          _loadLineup(); // Refresh setelah delete
        } else {
          _showSnackBar('❌ Gagal menghapus lineup');
        }
      } catch (e) {
        _showSnackBar('❌ Error: $e');
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
            'Loading Lineup...',
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

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
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
                'Failed to Load Lineup',
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
                onPressed: _loadLineup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: whiteColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.people_outline, size: 40, color: primaryColor),
              ),
              SizedBox(height: 20),
              Text(
                'No Lineup Available',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: darkTextColor,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Lineup will be available once it\'s created',
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
                  label: Text('Create Lineup'),
                  onPressed: _navigateToCreateEditLineup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: whiteColor,
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
    );
  }

  bool get _hasLineup {
    return _lineupData != null &&
        (_lineupData!.homeLineup != null || _lineupData!.awayLineup != null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        title: Text(
          'Match Lineup',
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
        actions: _isAdmin
            ? [
          if (_hasLineup)
            IconButton(
              icon: Icon(Icons.edit, color: whiteColor),
              onPressed: _navigateToCreateEditLineup,
              tooltip: 'Edit Lineup',
            ),
          if (_hasLineup)
            IconButton(
              icon: Icon(Icons.delete, color: whiteColor),
              onPressed: _deleteLineup,
              tooltip: 'Hapus Lineup',
            ),
        ]
            : null,
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _error.isNotEmpty
          ? _buildErrorState()
          : !_hasLineup
          ? _buildEmptyState()
          : LineupDetailScreen(lineupData: _lineupData!),
      floatingActionButton: _isAdmin && !_hasLineup
          ? FloatingActionButton(
        onPressed: _navigateToCreateEditLineup,
        child: Icon(Icons.add),
        backgroundColor: accentColor,
        foregroundColor: whiteColor,
        tooltip: 'Create Lineup',
      )
          : null,
    );
  }
}