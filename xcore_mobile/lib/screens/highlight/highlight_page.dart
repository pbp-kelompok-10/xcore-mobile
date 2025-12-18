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
        // NOTE: keep error handling minimal to avoid introducing new fields
        loading = false;
      });
    }
  }

  String flagUrl(String code) =>
      "https://flagcdn.com/w80/${code.toLowerCase()}.png";

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (matchData == null) {
      return const Scaffold(body: Center(child: Text("Match not found")));
    }

    final match = matchData!;

    return Scaffold(
      backgroundColor: const Color(0xfff0f7f5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1e423b),
        title: Text("${match.homeTeam} vs ${match.awayTeam}"),
      ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFF1e423b),
              icon: Icon(
                highlight == null ? Icons.add : Icons.edit,
                color: Colors.white,
              ),
              label: Text(
                highlight == null ? "Create Highlight" : "Edit Highlight",
                style: const TextStyle(color: Colors.white),
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
                  // show a brief loading state while we re-fetch the updated highlight
                  setState(() => loading = true);

                  await fetchHighlight();

                  // optionally show a confirmation to the user
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Highlight updated')),
                    );
                  }
                }
              },
            )
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 15),
            const Text(
              "Highlights",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1e423b),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // MATCH CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xffeef8f6),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 20,
                    color: Colors.black12,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Image.network(flagUrl(match.homeTeamCode), width: 65),
                      const SizedBox(height: 8),
                      Text(match.homeTeam),
                      Text(
                        match.homeScore.toString(),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: const [
                      Text(
                        "VS",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text("FT", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  Column(
                    children: [
                      Image.network(flagUrl(match.awayTeamCode), width: 65),
                      const SizedBox(height: 8),
                      Text(match.awayTeam),
                      Text(
                        match.awayScore.toString(),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // VIDEO PLAYER OR PLACEHOLDER
            if (highlight != null &&
                highlight!.video != null &&
                _controller != null)
              YoutubePlayer(controller: _controller!, aspectRatio: 16 / 9)
            else
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFF1e423b),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    "No Highlight Available",
                    style: TextStyle(fontSize: 18, color: Colors.white),
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
