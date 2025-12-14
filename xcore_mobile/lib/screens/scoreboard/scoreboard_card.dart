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
  final bool isAdmin;
  final VoidCallback? onEdit;
  final VoidCallback? onForum;

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
    this.isAdmin = false,
    this.onEdit,
    this.onForum,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // STATUS
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: status.toLowerCase() == "upcoming"
                    ? [const Color(0xFFFBBF24), const Color(0xFFF59E0B)]
                    : status.toLowerCase() == "live"
                        ? [const Color(0xFFF87171), const Color(0xFFEF4444)]
                        : [const Color(0xFF4AA69B), const Color(0xFF56BDA9)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status.toUpperCase(),
              style: TextStyle(
                fontFamily: 'Nunito Sans',
                fontWeight: FontWeight.w700,
                color: status.toLowerCase() == "upcoming" 
                    ? const Color(0xFF78350F) 
                    : const Color(0xFFFFFFFF),
                fontSize: 12,
              ),
            ),
          ),

          const SizedBox(height: 15),

          // TEAMS & SCORE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: _teamItem(homeTeam, homeCode, true)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  status.toLowerCase() == "upcoming"
                      ? "VS"
                      : "$homeScore - $awayScore",
                  style: const TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2C5F5A),
                  ),
                ),
              ),
              Expanded(child: _teamItem(awayTeam, awayCode, false)),
            ],
          ),

          const SizedBox(height: 12),

          // STADIUM
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F6F4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.stadium,
                  size: 16,
                  color: Color(0xFF4AA69B),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    stadium,
                    style: const TextStyle(
                      fontFamily: 'Nunito Sans',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C5F5A),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          // ACTION BUTTONS
          if (isAdmin || onForum != null) const SizedBox(height: 16),
          
          if (isAdmin || onForum != null)
            Row(
              children: [
                if (isAdmin) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onEdit,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF4AA69B),
                        side: const BorderSide(
                          color: Color(0xFF4AA69B),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text(
                        'Edit',
                        style: TextStyle(
                          fontFamily: 'Nunito Sans',
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  if (onForum != null) const SizedBox(width: 8),
                ],
                if (onForum != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onForum,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4AA69B),
                        foregroundColor: const Color(0xFFFFFFFF),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      icon: const Icon(Icons.forum, size: 18),
                      label: const Text(
                        'Forum',
                        style: TextStyle(
                          fontFamily: 'Nunito Sans',
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _teamItem(String name, String code, bool isHome) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF4AA69B).withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4AA69B).withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.network(
              "https://flagcdn.com/w80/${code.toLowerCase()}.png",
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFFE8F6F4),
                  child: const Icon(
                    Icons.flag,
                    color: Color(0xFF4AA69B),
                    size: 28,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 100,
          child: Text(
            name,
            style: const TextStyle(
              fontFamily: 'Nunito Sans',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2C5F5A),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}