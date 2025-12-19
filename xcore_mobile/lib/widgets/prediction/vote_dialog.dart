import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:xcore_mobile/models/prediction_entry.dart';
import 'package:xcore_mobile/screens/login.dart';

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
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    isUpdate ? "Change Vote" : "Who will win?",
                    style: const TextStyle(
                      fontFamily: 'Nunito Sans',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2C5F5A),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F6F4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Color(0xFF4AA69B),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isUpdate
                  ? "Select your new choice:"
                  : "Cast your vote for the winner!",
              style: const TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 14,
                color: Color(0xFF6B8E8A),
              ),
            ),
            const SizedBox(height: 30),

            // Vote Buttons
            Row(
              children: [
                Expanded(
                  child: _buildVoteButton(
                    context,
                    request,
                    teamName: prediction.homeTeam,
                    color: const Color(0xFF4AA69B),
                    icon: Icons.sports_soccer,
                    choice: "home",
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    "VS",
                    style: TextStyle(
                      fontFamily: 'Nunito Sans',
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: Color(0xFF2C5F5A),
                    ),
                  ),
                ),
                Expanded(
                  child: _buildVoteButton(
                    context,
                    request,
                    teamName: prediction.awayTeam,
                    color: const Color(0xFF56BDA9),
                    icon: Icons.sports_soccer,
                    choice: "away",
                  ),
                ),
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
          String result = await _submitOrUpdateVote(
            context,
            request,
            prediction.id,
            choice,
          );

          if (context.mounted) {
            Navigator.pop(context, result);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 32),
              const SizedBox(height: 12),
              Text(
                teamName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Nunito Sans',
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String> _submitOrUpdateVote(
    BuildContext context,
    CookieRequest request,
    String predictionId,
    String choice,
  ) async {
    if (!request.loggedIn) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Silakan login terlebih dahulu.",
              style: TextStyle(
                fontFamily: 'Nunito Sans',
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: Color(0xFFF59E0B),
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
      return 'failed';
    }

    final String endpoint = isUpdate
        ? 'prediction/update-vote-flutter/'
        : 'prediction/submit-vote-flutter/';
    final url = 'https://alvin-christian-xcore.pbp.cs.ui.ac.id/$endpoint';

    try {
      final response = await request.post(url, {
        'prediction_id': predictionId,
        'choice': choice,
      });

      if (!context.mounted) return 'failed';

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['message'],
              style: const TextStyle(
                fontFamily: 'Nunito Sans',
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: const Color(0xFF4AA69B),
          ),
        );
        return 'success';
      }
      // Handle error 409 (Already Voted)
      else if (response['message'].toString().contains("sudah voting") ||
          response['status'] == 409) {
        return 'already_voted';
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['message'] ?? "Gagal melakukan vote.",
              style: const TextStyle(
                fontFamily: 'Nunito Sans',
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
        return 'failed';
      }
    } catch (e) {
      if (!context.mounted) return 'failed';

      // Check if error message contains "sudah voting"
      if (e.toString().contains("sudah voting")) {
        return 'already_voted';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error: $e",
            style: const TextStyle(
              fontFamily: 'Nunito Sans',
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
      return 'failed';
    }
  }
}
