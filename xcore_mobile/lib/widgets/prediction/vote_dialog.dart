import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:xcore_mobile/models/prediction_entry.dart';
import 'package:xcore_mobile/screens/login.dart';
import 'package:xcore_mobile/services/prediction_service.dart'; 

class VoteDialog extends StatelessWidget {
  final Prediction prediction;
  final bool isUpdate;

  const VoteDialog({
    super.key,
    required this.prediction,
    this.isUpdate = false,
  });

  @override
  Widget build(BuildContext context) {
    final request = context.read<CookieRequest>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      backgroundColor: const Color(0xFFFFFFFF),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    isUpdate ? "Change Vote" : "Who will win?",
                    style: const TextStyle(fontFamily: 'Nunito Sans', fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF2C5F5A)),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: const Color(0xFFE8F6F4), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.close, color: Color(0xFF4AA69B), size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(isUpdate ? "Select your new choice:" : "Cast your vote for the winner!", style: const TextStyle(fontFamily: 'Nunito Sans', fontSize: 14, color: Color(0xFF6B8E8A))),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(child: _buildVoteButton(context, request, teamName: prediction.homeTeam, color: const Color(0xFF4AA69B), icon: Icons.sports_soccer, choice: "home")),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text("VS", style: TextStyle(fontFamily: 'Nunito Sans', fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF2C5F5A))),
                ),
                Expanded(child: _buildVoteButton(context, request, teamName: prediction.awayTeam, color: const Color(0xFF56BDA9), icon: Icons.sports_soccer, choice: "away")),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoteButton(
    BuildContext context,
    CookieRequest request, {
    required String teamName,
    required Color color,
    required IconData icon,
    required String choice,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      child: InkWell(
        onTap: () async {
          await _handleVote(context, request, choice);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 32),
              const SizedBox(height: 12),
              Text(teamName, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Nunito Sans', color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleVote(BuildContext context, CookieRequest request, String choice) async {
    if (!request.loggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Silakan login terlebih dahulu."), backgroundColor: Color(0xFFF59E0B)),
      );
      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
      return;
    }

    final result = await PredictionService.voteMatch(
      request: request,
      predictionId: prediction.id,
      choice: choice,
      isUpdate: isUpdate
    );

    if (context.mounted) {
      if (result['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message']), backgroundColor: const Color(0xFF4AA69B)),
        );
        Navigator.pop(context, 'success');
      } else if (result['status'] == 'already_voted') {
        Navigator.pop(context, 'already_voted');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message']), backgroundColor: const Color(0xFFEF4444)),
        );
      }
    }
  }
}
