import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:xcore_mobile/models/prediction_entry.dart';
import 'package:xcore_mobile/screens/login.dart';
import 'package:xcore_mobile/services/prediction_service.dart';
import 'package:xcore_mobile/screens/statistik/widgets/flag_widget.dart'; 

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
    final Color primaryTeal = const Color(0xFF4AA69B);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0, 
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32), // Padding atas dikurangi sedikit biar X ga kejauhan
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. CLOSE BUTTON (X) - Paling Atas Kanan
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                // Tanpa Container/Border, icon saja
                child: const Padding(
                  padding: EdgeInsets.all(4.0), // Hitbox biar gampang dipencet
                  child: Icon(Icons.close_rounded, color: Color(0xFF9CA3AF), size: 24),
                ),
              ),
            ),
            
            // 2. HEADER TEXT (Judul) - Di bawah X
            const SizedBox(height: 4), // Jarak sedikit dari X
            Text(
              isUpdate ? "Change Vote" : "Who will win?",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2C5F5A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isUpdate ? "Select your new choice:" : "Predict the winner!",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 14,
                color: Color(0xFF6B8E8A),
                fontWeight: FontWeight.w500,
              ),
            ),
            
            const SizedBox(height: 32),

            // 3. VOTE BUTTONS (Flags)
            Row(
              children: [
                // HOME BUTTON
                Expanded(
                  child: _buildVoteButton(
                    context, 
                    request, 
                    teamName: prediction.homeTeam, 
                    teamCode: prediction.homeTeamCode, 
                    isHome: true,
                    choice: "home",
                    primaryColor: primaryTeal,
                  ),
                ),
                
                // VS Divider
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Container(
                        height: 40,
                        width: 1,
                        color: Colors.grey.shade200,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "VS",
                        style: TextStyle(
                          fontFamily: 'Nunito Sans',
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 40,
                        width: 1,
                        color: Colors.grey.shade200,
                      ),
                    ],
                  ),
                ),

                // AWAY BUTTON
                Expanded(
                  child: _buildVoteButton(
                    context, 
                    request, 
                    teamName: prediction.awayTeam, 
                    teamCode: prediction.awayTeamCode, 
                    isHome: false,
                    choice: "away",
                    primaryColor: const Color(0xFF56BDA9),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildVoteButton(
    BuildContext context,
    CookieRequest request, {
    required String teamName,
    required String teamCode,
    required bool isHome,
    required String choice,
    required Color primaryColor,
  }) {
    return Material(
      color: Colors.white, 
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () async {
          await _handleVote(context, request, choice);
        },
        borderRadius: BorderRadius.circular(16),
        splashColor: primaryColor.withOpacity(0.1),
        highlightColor: primaryColor.withOpacity(0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: primaryColor.withOpacity(0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // BENDERA
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: FlagWidget(
                  teamCode: teamCode,
                  isHome: isHome,
                  width: 60,
                  height: 40,
                ),
              ),
              const SizedBox(height: 16),
              
              // NAMA TIM
              Text(
                teamName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Nunito Sans',
                  color: Color(0xFF374151),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  height: 1.2,
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

  Future<void> _handleVote(BuildContext context, CookieRequest request, String choice) async {
    if (!request.loggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Silakan login terlebih dahulu."), backgroundColor: Color(0xFFF59E0B)),
      );
      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator(color: Color(0xFF4AA69B))),
    );

    final result = await PredictionService.voteMatch(
      request: request,
      predictionId: prediction.id,
      choice: choice,
      isUpdate: isUpdate
    );

    if (context.mounted) Navigator.pop(context);

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