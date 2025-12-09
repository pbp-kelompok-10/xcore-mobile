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
    this.isUpdate = false 
  });

  @override
  Widget build(BuildContext context) {
    final request = context.read<CookieRequest>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 5,
      backgroundColor: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isUpdate ? "Change Vote" : "Who will win?",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D6A66),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context), // Tutup tanpa aksi
                  child: Icon(Icons.close, color: Colors.grey[400]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isUpdate ? "Select your new choice:" : "Cast your vote for the winner!",
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: _buildVoteButton(
                    context,
                    request,
                    teamName: prediction.homeTeam,
                    color: const Color(0xFF4DB6AC),
                    icon: Icons.check_circle_outline,
                    choice: "home",
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text("VS", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: _buildVoteButton(
                    context,
                    request,
                    teamName: prediction.awayTeam,
                    color: const Color(0xFF267365),
                    icon: Icons.check_circle,
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
      child: InkWell(
        onTap: () async {
          // Kita tangkap hasilnya (String)
          String result = await _submitOrUpdateVote(context, request, prediction.id, choice);
          
          if (context.mounted) {
            // Kembalikan hasil ke PredictionPage
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
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String> _submitOrUpdateVote(BuildContext context, CookieRequest request, String predictionId, String choice) async {
    if (!request.loggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Silakan login terlebih dahulu.")));
      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
      return 'failed';
    }

    final String endpoint = isUpdate ? 'prediction/update-vote-flutter/' : 'prediction/submit-vote-flutter/';
    final url = 'http://localhost:8000/$endpoint';

    try {
      final response = await request.post(url, {
        'prediction_id': predictionId,
        'choice': choice,
      });

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message']), backgroundColor: Colors.green),
        );
        return 'success';
      } 
      // TANGKAP ERROR 409 (Already Voted)
      else if (response['message'].toString().contains("sudah voting") || response['status'] == 409) {
        // Kita tidak tampilkan error merah, tapi kita return status khusus
        return 'already_voted';
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? "Gagal."), backgroundColor: Colors.red),
        );
        return 'failed';
      }
    } catch (e) {
      // Cek manual kalau message error mengandung kata kunci
      if (e.toString().contains("sudah voting")) {
         return 'already_voted';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      return 'failed';
    }
  }
}