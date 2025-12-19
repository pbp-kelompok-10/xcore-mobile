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
        title: Text('Hapus Lineup'),
        content: Text('Yakin ingin menghapus lineup pertandingan ini?'),
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
          _showSnackBar('Lineup berhasil dihapus');
          _loadLineup(); // Refresh setelah delete
        } else {
          _showSnackBar('Gagal menghapus lineup');
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
          content: Text(message),
          backgroundColor: Colors.green[600],
          duration: Duration(seconds: 2),
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
          ),
          SizedBox(height: 16),
          Text(
            'Loading Lineup...',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
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
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            SizedBox(height: 16),
            Text(
              'Failed to Load Lineup',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              _error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _loadLineup, child: Text('Try Again')),
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
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'No Lineup Available',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Lineup will be available once it\'s created',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 20),
            if (_isAdmin)
              ElevatedButton.icon(
                icon: Icon(Icons.add),
                label: Text('Create Lineup'),
                onPressed: _navigateToCreateEditLineup,
              ),
          ],
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
      appBar: AppBar(
        title: Text(
          'Match Lineup',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.green[700],
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: _isAdmin
            ? [
                if (_hasLineup)
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.white),
                    onPressed: _navigateToCreateEditLineup,
                  ),
                if (_hasLineup)
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.white),
                    onPressed: _deleteLineup,
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
              backgroundColor: Colors.orange,
            )
          : null,
    );
  }
}
