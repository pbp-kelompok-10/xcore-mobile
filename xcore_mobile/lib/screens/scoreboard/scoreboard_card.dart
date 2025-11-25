import 'package:flutter/material.dart';

class ScoreboardMatchCard extends StatelessWidget {
  final String homeTeam;
  final String awayTeam;
  final String homeCode;
  final String awayCode;
  final String status;
  final int? homeScore;
  final int? awayScore;
  final String stadium;
  final String group;

  const ScoreboardMatchCard({
    super.key,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeCode,
    required this.awayCode,
    required this.status,
    this.homeScore,
    this.awayScore,
    required this.stadium,
    required this.group,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.teal.shade100, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // STATUS
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: status == "upcoming"
                    ? [Colors.yellow.shade200, Colors.amber.shade400]
                    : status == "live"
                        ? [Colors.red.shade300, Colors.red.shade600]
                        : [Colors.blue.shade200, Colors.blue.shade400],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: status == "live" ? Colors.white : Colors.black87,
                fontSize: 12,
              ),
            ),
          ),

          const SizedBox(height: 15),

          // TEAMS & SCORE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _teamItem(homeTeam, homeCode),
              Text(
                status == "upcoming"
                    ? "N/A"
                    : "$homeScore - $awayScore",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade900,
                ),
              ),
              _teamItem(awayTeam, awayCode),
            ],
          ),

          const SizedBox(height: 12),

          Text("🏟️ $stadium"),
        ],
      ),
    );
  }

  Widget _teamItem(String name, String code) {
    return Row(
      children: [
        ClipOval(
          child: Image.network(
            "https://flagcdn.com/w80/$code.png",
            width: 48,
            height: 48,
          ),
        ),
        const SizedBox(width: 10),
        Text(name),
      ],
    );
  }
}
