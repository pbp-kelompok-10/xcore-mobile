import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import 'highlight_service.dart';
import '../../models/highlights_entry.dart';
import '../../models/scoreboard_entry.dart';
import 'highlight_create_page.dart';
import 'highlight_edit_page.dart';

class HighlightPage extends StatefulWidget {
  final String matchId;

  const HighlightPage({super.key, required this.matchId});

  @override
  State<HighlightPage> createState() => _HighlightPageState();
}

class _HighlightPageState extends State<HighlightPage> {
  Highlight? highlight;
  ScoreboardEntry? matchData;
  bool _isAdmin = false;
  String _error = '';

  YoutubePlayerController? _controller;

  bool loading = true;

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
    fetchHighlight();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    try {
      final admin_status = await HighlightService.fetchAdminStatus(context);
      setState(() {
        _isAdmin = admin_status;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        loading = false;
      });
    }
  }

  Future<void> fetchHighlight() async {
    debugPrint('fetchHighlight: Starting with matchId = ${widget.matchId}');
    try {
      final data = await HighlightService.getHighlight(widget.matchId);
      debugPrint(
        'fetchHighlight: getHighlight returned ${data != null ? "data" : "null"}',
      );

      if (data != null) {
        // Update local models first
        setState(() {
          highlight = data;
          matchData = data.match;
        });

        // Rebuild YouTube controller if video exists; otherwise clear it
        if (highlight!.video != null && highlight!.video!.contains("youtube")) {
          final id = YoutubePlayerController.convertUrlToId(highlight!.video!);

          if (id != null) {
            // Dispose any previous controller before creating new one
            await _controller?.close();

            setState(() {
              _controller = YoutubePlayerController.fromVideoId(
                videoId: id,
                autoPlay: false,
                params: const YoutubePlayerParams(
                  showControls: true,
                  showFullscreenButton: true,
                  origin: 'https://www.youtube-nocookie.com'
                ),
              );
            });
          }
        } else {
          // No valid youtube video — dispose existing controller
          await _controller?.close();
          setState(() {
            _controller = null;
          });
        }
      } else {
        // No highlight exists, but we still need match data
        debugPrint('fetchHighlight: Calling getMatchData');
        final match = await HighlightService.getMatchData(widget.matchId);
        debugPrint(
          'fetchHighlight: getMatchData returned ${match != null ? "data" : "null"}',
        );
        if (match != null) {
          setState(() {
            matchData = match;
          });
        }
      }

      setState(() => loading = false);
    } catch (e) {
      debugPrint('fetchHighlight: ERROR - $e');
      setState(() {
        loading = false;
      });
    }
  }

  String flagUrl(String code) =>
      "https://flagcdn.com/w80/${code.toLowerCase()}.png";

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

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
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
            'Loading Highlights...',
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

  Widget _buildMatchNotFound() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Container(
          padding: EdgeInsets.all(32),
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
                'Match Not Found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Unable to load match data',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: mutedTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        backgroundColor: scaffoldBgColor,
        appBar: AppBar(
          title: Text(
            'Match Highlights',
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
        ),
        body: _buildLoadingState(),
      );
    }

    if (matchData == null) {
      return Scaffold(
        backgroundColor: scaffoldBgColor,
        appBar: AppBar(
          title: Text(
            'Match Highlights',
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
        ),
        body: _buildMatchNotFound(),
      );
    }

    final match = matchData!;

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        title: Text(
          'Match Highlights',
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
          IconButton(
            icon: Icon(
              highlight == null ? Icons.add : Icons.edit,
              color: whiteColor,
            ),
            onPressed: () async {
              bool? updated;

              if (highlight == null) {
                updated = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        HighlightCreatePage(matchId: widget.matchId),
                  ),
                );
              } else {
                updated = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HighlightEditPage(
                      matchId: widget.matchId,
                      currentVideo: highlight!.video!,
                    ),
                  ),
                );
              }

              if (updated == true) {
                setState(() => loading = true);
                await fetchHighlight();
                _showSnackBar('✅ Highlight updated');
              }
            },
            tooltip: highlight == null ? 'Create Highlight' : 'Edit Highlight',
          ),
        ]
            : null,
      ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton.extended(
        backgroundColor: accentColor,
        foregroundColor: whiteColor,
        icon: Icon(
          highlight == null ? Icons.add : Icons.edit,
        ),
        label: Text(
          highlight == null ? "Create" : "Edit",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () async {
          bool? updated;

          if (highlight == null) {
            updated = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    HighlightCreatePage(matchId: widget.matchId),
              ),
            );
          } else {
            updated = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HighlightEditPage(
                  matchId: widget.matchId,
                  currentVideo: highlight!.video!,
                ),
              ),
            );
          }

          if (updated == true) {
            setState(() => loading = true);
            await fetchHighlight();
            _showSnackBar('✅ Highlight updated');
          }
        },
      )
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Page Title
            Container(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_circle_outline, size: 28, color: primaryColor),
                  SizedBox(width: 8),
                  Text(
                    "Match Highlights",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: darkTextColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // MATCH CARD
            Container(
              padding: const EdgeInsets.all(20),
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
                  // Teams Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Home Team
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: lightBgColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Image.network(
                                flagUrl(match.homeTeamCode),
                                width: 60,
                                height: 40,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(Icons.flag, size: 40, color: mutedTextColor),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              match.homeTeam,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: darkTextColor,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 8),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: primaryColor.withOpacity(0.3)),
                              ),
                              child: Text(
                                match.homeScore.toString(),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: darkTextColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // VS Column
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: accentColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: accentColor.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "VS",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: darkTextColor,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                "FT",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Away Team
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: lightBgColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Image.network(
                                flagUrl(match.awayTeamCode),
                                width: 60,
                                height: 40,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(Icons.flag, size: 40, color: mutedTextColor),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              match.awayTeam,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: darkTextColor,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 8),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: accentColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: accentColor.withOpacity(0.3)),
                              ),
                              child: Text(
                                match.awayScore.toString(),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: darkTextColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // VIDEO PLAYER OR PLACEHOLDER
            Container(
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: highlight != null &&
                    highlight!.video != null &&
                    _controller != null
                    ? YoutubePlayer(controller: _controller!, aspectRatio: 16 / 9)
                    : Container(
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primaryColor.withOpacity(0.8),
                        accentColor.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.video_library_outlined,
                          size: 48,
                          color: whiteColor.withOpacity(0.8),
                        ),
                        SizedBox(height: 12),
                        Text(
                          "No Highlight Available",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: whiteColor,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          _isAdmin
                              ? "Tap the button to add highlights"
                              : "Highlights will be added soon",
                          style: TextStyle(
                            fontSize: 13,
                            color: whiteColor.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}