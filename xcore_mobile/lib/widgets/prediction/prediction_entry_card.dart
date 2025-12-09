// lib/widgets/prediction_entry_card.dart
import 'package:flutter/material.dart';
import 'package:xcore_mobile/models/prediction_entry.dart';
import 'package:intl/intl.dart';

class PredictionEntryCard extends StatelessWidget {
  final Prediction prediction;
  final VoidCallback onTap;

  const PredictionEntryCard({
    super.key,
    required this.prediction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color greenNormal = const Color(0xFF4CAF50);
    final Color blueNormal = const Color(0xFF2196F3);
    final Color whiteLight = Colors.white;

    // safe percentage values
    int homePct = prediction.homePercentage.clamp(0, 100);
    int awayPct = prediction.awayPercentage.clamp(0, 100);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 4,
        color: whiteLight,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: prediction.status == "UPCOMING"
                        ? Colors.orange.shade100
                        : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    prediction.status == "UPCOMING" ? "⏰ UPCOMING" : "✅ FINISHED",
                    style: TextStyle(
                      color: prediction.status == "UPCOMING"
                          ? Colors.orange.shade800
                          : Colors.green.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      prediction.homeTeam,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: greenNormal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "VS",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: greenNormal,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      prediction.awayTeam,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('d MMM yyyy, HH:mm').format(prediction.matchDate),
                    style: TextStyle(color: blueNormal, fontSize: 12),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.location_on, size: 14, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text(
                    prediction.stadium,
                    style: TextStyle(color: blueNormal, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [greenNormal, Colors.green.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: greenNormal.withOpacity(0.4),
                      offset: const Offset(0, 4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "🗳️ Vote Now",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: greenNormal.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildResultRow(
                      prediction.homeTeam,
                      homePct,
                      prediction.votesHomeTeam,
                      greenNormal,
                    ),
                    const SizedBox(height: 12),
                    _buildResultRow(
                      prediction.awayTeam,
                      awayPct,
                      prediction.votesAwayTeam,
                      greenNormal,
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

  Widget _buildResultRow(String teamName, int percentage, int votes, Color color) {
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
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            Text(
              "$percentage%",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.white,
            color: color,
            minHeight: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "$votes votes",
          style: const TextStyle(fontSize: 12, color: Colors.blue),
        ),
      ],
    );
  }
}
