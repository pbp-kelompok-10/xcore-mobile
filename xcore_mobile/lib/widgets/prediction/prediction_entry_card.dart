import 'package:flutter/material.dart';
import 'package:xcore_mobile/models/prediction_entry.dart';
import 'package:intl/intl.dart';

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
    final Color lightMint = const Color(0xFFE8F6F4);
    final Color whiteLight = const Color(0xFFFFFFFF);
    final Color textDark = const Color(0xFF2C5F5A);
    final Color textGray = const Color(0xFF6B8E8A);

    int homePct = prediction.homePercentage.clamp(0, 100);
    int awayPct = prediction.awayPercentage.clamp(0, 100);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 2,
        shadowColor: Colors.black12,
        color: whiteLight,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Header Status (Upcoming/Finished)
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // 2. Team Info Row (Home vs Away)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      prediction.homeTeam,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: textDark,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: lightMint,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: primaryTeal.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      "VS",
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: primaryTeal,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      prediction.awayTeam,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: textDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              
              // 3. Date & Location Info
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, size: 15, color: textGray),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('d MMM yyyy, HH:mm').format(prediction.matchDate),
                    style: TextStyle(
                      fontFamily: 'Nunito Sans',
                      color: textGray,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.location_on, size: 15, color: textGray),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      prediction.stadium,
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        color: textGray,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // 4. ACTION BUTTONS AREA (Disini perubahannya)
              // -----------------------------------------------------------
              
              if (!showActions) 
                // A. TAMPILAN TAB "ALL": Tombol Vote Now
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryTeal,
                      foregroundColor: whiteLight,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "🗳️ Vote Now",
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                )
              else 
                // B. TAMPILAN TAB "MY VOTES": Tombol Delete & Update
                // (Posisinya menggantikan Vote Now)
                Row(
                  children: [
                    // DELETE BUTTON
                    Expanded(
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFEF4444),
                            width: 2,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: onDelete,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.delete_outline,
                                  color: Color(0xFFEF4444),
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Delete",
                                  style: TextStyle(
                                    fontFamily: 'Nunito Sans',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: Color(0xFFEF4444),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // UPDATE BUTTON
                    Expanded(
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: primaryTeal,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: onUpdate,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.edit_outlined,
                                  color: Color(0xFFFFFFFF),
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Update",
                                  style: TextStyle(
                                    fontFamily: 'Nunito Sans',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: Color(0xFFFFFFFF),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              
              // -----------------------------------------------------------

              const SizedBox(height: 24),
              
              // 5. Result Bars (Sekarang ada di bawah tombol aksi)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: lightMint,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: primaryTeal.withOpacity(0.15),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    _buildResultRow(
                      prediction.homeTeam,
                      homePct,
                      prediction.votesHomeTeam,
                      primaryTeal,
                      textDark,
                    ),
                    const SizedBox(height: 16),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow(String teamName, int percentage, int votes, Color barColor, Color textColor) {
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
                fontSize: 14,
                color: textColor,
              ),
            ),
            Text(
              "$percentage%",
              style: TextStyle(
                fontFamily: 'Nunito Sans',
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: barColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: const Color(0xFFFFFFFF),
            color: barColor,
            minHeight: 10,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "$votes votes",
          style: const TextStyle(
            fontFamily: 'Nunito Sans',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF9CA3AF),
          ),
        ),
      ],
    );
  }
}