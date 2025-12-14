// lineup/lineup_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:xcore_mobile/models/lineup_entry.dart';
import 'package:xcore_mobile/models/scoreboard_entry.dart';

class LineupDetailScreen extends StatelessWidget {
  final MatchLineupResponse lineupData;

  const LineupDetailScreen({Key? key, required this.lineupData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final match = lineupData.match;

    return Scaffold(
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
              ),

            const SizedBox(height: 32),

            // Away Team Lineup
            if (lineupData.awayLineup != null)
              _buildTeamLineupSection(
                team: match.awayTeam,
                lineup: lineupData.awayLineup!,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${match.homeTeam} vs ${match.awayTeam}',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${_formatDate(match.matchDate)} • ${match.stadium}',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildTeamLineupSection({
    required String team,
    required Lineup lineup,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          team,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...lineup.players.map((player) => _buildPlayerCard(player)),
      ],
    );
  }

  Widget _buildPlayerCard(Player player) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Player Number
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.green[800],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(
                player.nomor.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (player.asal.isNotEmpty)
                  Text(
                    player.asal,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                Text(
                  'Umur: ${player.umur}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncompleteLineupMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info, color: Colors.orange[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Lineup untuk salah satu tim belum tersedia',
              style: TextStyle(
                color: Colors.orange[800],
                fontSize: 14,
              ),
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