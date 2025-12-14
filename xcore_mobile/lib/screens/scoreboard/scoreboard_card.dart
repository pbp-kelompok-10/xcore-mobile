import 'package:flutter/material.dart';
import 'package:xcore_mobile/screens/statistik/widgets/flag_widget.dart';

class ScoreboardMatchCard extends StatelessWidget {
  final String homeTeam;
  final String awayTeam;
  final String homeCode;
  final String awayCode;
  final String status;
  final int homeScore;
  final int awayScore;
  final String stadium;
  final String group;
  final DateTime matchDate;

  const ScoreboardMatchCard({
    super.key,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeCode,
    required this.awayCode,
    required this.status,
    required this.homeScore,
    required this.awayScore,
    required this.stadium,
    required this.group,
    required this.matchDate,
  });

  // Helper untuk nama bulan
  String _getMonthName(int month) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final bool isUpcoming = status.toLowerCase() == 'upcoming';
    final bool isLive = status.toLowerCase() == 'live';

    // Format Jam (Contoh: 19:30)
    final String timeString = 
        "${matchDate.hour.toString().padLeft(2, '0')}:${matchDate.minute.toString().padLeft(2, '0')}";

    // Format Tanggal (Contoh: 12 Oct 2023)
    final String dateString = 
        "${matchDate.day} ${_getMonthName(matchDate.month)} ${matchDate.year}";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Kartu (Group & Status)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  group,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
                _buildStatusBadge(status),
              ],
            ),
          ),

          // Body Kartu (Tim, Bendera, & Skor/Waktu)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start, // Align start agar teks tim panjang aman
              children: [
                // Home Team
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 48, 
                        child: Center(
                          child: FlagWidget(
                            teamCode: homeCode,
                            isHome: true,
                            width: 45,
                            height: 30,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        homeTeam,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Center Area (VS/Score + Date + Time)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: [
                      if (isUpcoming) ...[
                        // 1. VS Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "VS",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // 2. Tanggal (Dibawah VS)
                        Text(
                          dateString,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // 3. Jam (Dibawah Tanggal)
                        Row(
                          children: [
                            Icon(Icons.access_time_rounded, size: 12, color: Colors.grey[800]),
                            const SizedBox(width: 4),
                            Text(
                              timeString,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        // Jika Finished/Live
                        Row(
                          children: [
                            Text(
                              "$homeScore",
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 36,
                                color: isLive ? Colors.redAccent : Colors.black87,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                "-", 
                                style: TextStyle(
                                  fontSize: 28, 
                                  color: Colors.grey.shade300,
                                  fontWeight: FontWeight.w300
                                )
                              ),
                            ),
                            Text(
                              "$awayScore",
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 36,
                                color: isLive ? Colors.redAccent : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        // Tanggal dibawah Skor
                        const SizedBox(height: 4),
                        Text(
                          dateString,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Away Team
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 48,
                        child: Center(
                          child: FlagWidget(
                            teamCode: awayCode,
                            isHome: false,
                            width: 45,
                            height: 30,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        awayTeam,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Footer Kartu (Stadium)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.stadium_rounded, size: 14, color: Colors.grey.shade400),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    stadium,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String text = status.toUpperCase();

    switch (status.toLowerCase()) {
      case 'live':
        bgColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        text = "● LIVE";
        break;
      case 'finished':
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        text = "FULL TIME";
        break;
      case 'upcoming':
        bgColor = Colors.yellow.shade50;
        textColor = Colors.yellow.shade700;
        break;
      default:
        bgColor = Colors.blueGrey.shade100;
        textColor = Colors.blueGrey.shade600;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}