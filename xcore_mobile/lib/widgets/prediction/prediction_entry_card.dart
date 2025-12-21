import 'package:flutter/material.dart';
import 'package:xcore_mobile/models/prediction_entry.dart';
import 'package:intl/intl.dart';
import 'package:xcore_mobile/screens/statistik/widgets/flag_widget.dart';

class PredictionEntryCard extends StatelessWidget {
  final Prediction prediction;
  final VoidCallback onTap;
  final bool showActions;
  final VoidCallback? onDelete;
  final VoidCallback? onUpdate;

  const PredictionEntryCard({
    super.key,
    required this.prediction,
    required this.onTap,
    this.showActions = false,
    this.onDelete,
    this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryTeal = const Color(0xFF4AA69B);
    final Color whiteLight = const Color(0xFFFFFFFF);
    final Color textDark = const Color(0xFF2C5F5A);

    int homePct = prediction.homePercentage.clamp(0, 100);
    int awayPct = prediction.awayPercentage.clamp(0, 100);

    // Format Tanggal gabung jam: "31 Dec, 19:00" (Dipersingkat biar muat 1 baris)
    final String shortDateString = DateFormat(
      'd MMM, HH:mm',
    ).format(prediction.matchDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 3,
        shadowColor: Colors.black12,
        color: whiteLight,
        child: Column(
          children: [
            // 1. STATUS BADGE
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.only(top: 16, left: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: prediction.status == "UPCOMING"
                      ? const Color(0xFFFEF3C7)
                      : const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  prediction.status == "UPCOMING" ? "⏰ UPCOMING" : "✅ FINISHED",
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    color: prediction.status == "UPCOMING"
                        ? const Color(0xFF92400E)
                        : const Color(0xFF065F46),
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

            // 2. TIM & VS
            Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                12,
              ), // Bottom padding dikurangi
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HOME TEAM
                  Expanded(
                    child: Column(
                      children: [
                        FlagWidget(
                          teamCode: prediction.homeTeamCode ?? '',
                          isHome: true,
                          width: 50,
                          height: 35,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          prediction.homeTeam,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Nunito Sans',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: textDark,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // VS
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 8,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: primaryTeal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "VS",
                        style: TextStyle(
                          fontFamily: 'Nunito Sans',
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: primaryTeal,
                        ),
                      ),
                    ),
                  ),

                  // AWAY TEAM
                  Expanded(
                    child: Column(
                      children: [
                        FlagWidget(
                          teamCode: prediction.awayTeamCode ?? '',
                          isHome: false,
                          width: 50,
                          height: 35,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          prediction.awayTeam,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Nunito Sans',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: textDark,
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

            // 3. INFO BOX (SATU BARIS & WRAP CONTENT)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC), // Lebih terang dikit
                borderRadius: BorderRadius.circular(20), // Lebih bulat
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisSize:
                    MainAxisSize.min, // <--- INI KUNCINYA: Wrap Content
                children: [
                  // Tanggal
                  const Icon(
                    Icons.calendar_month_rounded,
                    size: 14,
                    color: Color(0xFF6B7280),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    shortDateString,
                    style: const TextStyle(
                      fontFamily: 'Nunito Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),

                  // Divider Kecil
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    width: 1,
                    height: 12,
                    color: Colors.grey.shade400,
                  ),

                  // Stadium
                  const Icon(
                    Icons.location_on_rounded,
                    size: 14,
                    color: Color(0xFFEF4444),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    // Pakai Flexible biar kalau kepanjangan dia motong rapi
                    child: Text(
                      prediction.stadium,
                      style: const TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 4. RESULT BARS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildResultRow(
                    prediction.homeTeam,
                    homePct,
                    prediction.votesHomeTeam,
                    primaryTeal,
                    textDark,
                  ),
                  const SizedBox(height: 12),
                  _buildResultRow(
                    prediction.awayTeam,
                    awayPct,
                    prediction.votesAwayTeam,
                    primaryTeal,
                    textDark,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 5. ACTION BUTTONS
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: !showActions
                  ? SizedBox(
                      width: double.infinity,
                      height: 44, // Sedikit lebih ramping
                      child: ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryTeal,
                          foregroundColor: whiteLight,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "🗳️ Vote Now",
                          style: TextStyle(
                            fontFamily: 'Nunito Sans',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            label: "Delete",
                            icon: Icons.delete_outline,
                            color: const Color(0xFFEF4444),
                            isOutlined: true,
                            onTap: onDelete,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionButton(
                            label: "Update",
                            icon: Icons.edit_outlined,
                            color: primaryTeal,
                            isOutlined: false,
                            onTap: onUpdate,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper untuk Button agar kodingan lebih bersih
  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool isOutlined,
    VoidCallback? onTap,
  }) {
    return SizedBox(
      height: 44,
      child: Material(
        color: isOutlined ? Colors.transparent : color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isOutlined
              ? BorderSide(color: color, width: 1.5)
              : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isOutlined ? color : Colors.white, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Nunito Sans',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: isOutlined ? color : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow(
    String teamName,
    int percentage,
    int votes,
    Color barColor,
    Color textColor,
  ) {
    final double value = (percentage.clamp(0, 100)) / 100.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              teamName,
              style: TextStyle(
                fontFamily: 'Nunito Sans',
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: textColor,
              ),
            ),
            Text(
              "$percentage%",
              style: TextStyle(
                fontFamily: 'Nunito Sans',
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: barColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: const Color(0xFFF3F4F6),
            color: barColor,
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "$votes votes",
          style: const TextStyle(
            fontFamily: 'Nunito Sans',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFF9CA3AF),
          ),
        ),
      ],
    );
  }
}
