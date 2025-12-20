// lineup/lineup_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:xcore_mobile/models/lineup_entry.dart';
import 'package:xcore_mobile/models/scoreboard_entry.dart';

class LineupDetailScreen extends StatelessWidget {
  final MatchLineupResponse lineupData;

  const LineupDetailScreen({Key? key, required this.lineupData}) : super(key: key);

  // Warna konsisten dengan MatchStatisticsPage dan ForumPage
  static const Color primaryColor = Color(0xFF4AA69B);
  static const Color scaffoldBgColor = Color(0xFFE8F6F4);
  static const Color darkTextColor = Color(0xFF2C5F5A);
  static const Color mutedTextColor = Color(0xFF6B8E8A);
  static const Color accentColor = Color(0xFF34C6B8);
  static const Color lightBgColor = Color(0xFFD1F0EB);
  static const Color whiteColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    final match = lineupData.match;

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Match Header
            _buildMatchHeader(match),
            const SizedBox(height: 24),

            // Home Team Lineup
            if (lineupData.homeLineup != null)
              _buildTeamLineupSection(
                team: match.homeTeam,
                lineup: lineupData.homeLineup!,
                isHome: true,
              ),

            const SizedBox(height: 24),

            // Away Team Lineup
            if (lineupData.awayLineup != null)
              _buildTeamLineupSection(
                team: match.awayTeam,
                lineup: lineupData.awayLineup!,
                isHome: false,
              ),

            // Message jika salah satu lineup belum ada
            if (lineupData.homeLineup == null || lineupData.awayLineup == null)
              _buildIncompleteLineupMessage(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchHeader(ScoreboardEntry match) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.stadium, size: 20, color: primaryColor),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${match.homeTeam} vs ${match.awayTeam}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: darkTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: mutedTextColor.withOpacity(0.3)),
          const SizedBox(height: 12),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calendar_today, size: 12, color: primaryColor),
                SizedBox(width: 4),
                Text(
                  '${_formatDate(match.matchDate)} • ${match.stadium}',
                  style: TextStyle(
                    fontSize: 12,
                    color: primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamLineupSection({
    required String team,
    required Lineup lineup,
    required bool isHome,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Team Header
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isHome ? primaryColor : accentColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                isHome ? Icons.home : Icons.flight_takeoff,
                size: 18,
                color: whiteColor,
              ),
              SizedBox(width: 8),
              Text(
                team,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: whiteColor,
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: whiteColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${lineup.players.length} Players',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: whiteColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Players List
        ...lineup.players.map((player) => _buildPlayerCard(player, isHome)),
      ],
    );
  }

  Widget _buildPlayerCard(Player player, bool isHome) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      color: whiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            // Player Number
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isHome ? primaryColor : accentColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: (isHome ? primaryColor : accentColor).withOpacity(0.3),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  player.nomor.toString(),
                  style: const TextStyle(
                    color: whiteColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Player Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.nama,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: darkTextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (player.asal.isNotEmpty) ...[
                        Icon(Icons.public, size: 12, color: mutedTextColor),
                        SizedBox(width: 4),
                        Text(
                          player.asal,
                          style: TextStyle(
                            fontSize: 13,
                            color: mutedTextColor,
                          ),
                        ),
                        SizedBox(width: 12),
                      ],
                      Icon(Icons.calendar_today, size: 12, color: mutedTextColor),
                      SizedBox(width: 4),
                      Text(
                        'Age: ${player.umur}',
                        style: TextStyle(
                          fontSize: 13,
                          color: mutedTextColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Player Icon
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: (isHome ? primaryColor : accentColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.person,
                size: 18,
                color: isHome ? primaryColor : accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncompleteLineupMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange[700], size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Incomplete Lineup',
                  style: TextStyle(
                    color: Colors.orange[800],
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Lineup untuk salah satu tim belum tersedia',
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    return '${days[date.weekday - 1]} – ${date.day} ${months[date.month - 1]} ${date.year}';
  }
}