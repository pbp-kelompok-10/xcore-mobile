import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:xcore_mobile/models/prediction_entry.dart';
import 'package:xcore_mobile/widgets/prediction/prediction_entry_card.dart';
import 'package:xcore_mobile/widgets/prediction/vote_dialog.dart';
import 'package:xcore_mobile/services/prediction_service.dart';

class PredictionDetailPage extends StatefulWidget {
  final String matchId; // ID Match dari Scoreboard

  const PredictionDetailPage({super.key, required this.matchId});

  @override
  State<PredictionDetailPage> createState() => _PredictionDetailPageState();
}

class _PredictionDetailPageState extends State<PredictionDetailPage> {
  late Future<Prediction?> _futurePrediction;
  bool _hasVoted = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _futurePrediction = _fetchAndCheckStatus();
    });
  }

  Future<Prediction?> _fetchAndCheckStatus() async {
    final request = context.read<CookieRequest>();
    debugPrint("Fetching detail for Match ID: ${widget.matchId}");

    try {
      // 1. Ambil data match dari 'All Predictions' biar dapet statistik terbaru
      final allPredictions = await PredictionService.fetchPredictions(
        request,
        '/prediction/json/',
      );

      // Debug: Print all match_id in allPredictions
      debugPrint(
        "All match IDs: ${allPredictions.map((p) => p.matchId).toList()}",
      );

      // 2. Ambil data 'My Votes' buat ngecek status user
      final myVotes = await PredictionService.fetchPredictions(
        request,
        '/prediction/json-my-votes/',
      );

      // 3. Cari Match yang sesuai ID
      final targetMatch = allPredictions.firstWhere(
        (item) => item.matchId == widget.matchId,
        orElse: () => throw Exception("Match not found"),
      );

      // 4. Cek apakah Match ID ini ada di daftar 'My Votes' user?
      final isVoted = myVotes.any((item) => item.id == targetMatch.id);

      // 5. Update status vote di state
      if (mounted) {
        _hasVoted = isVoted;
      }

      return targetMatch;
    } catch (e) {
      print("Error loading detail: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.read<CookieRequest>();

    return Scaffold(
      backgroundColor: const Color(0xFFE8F6F4),
      appBar: AppBar(
        title: const Text(
          "Prediction Detail",
          style: TextStyle(
            fontFamily: 'Nunito Sans',
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: const Color(0xFF4AA69B),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: FutureBuilder<Prediction?>(
        future: _futurePrediction,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF4AA69B)),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Data prediksi tidak ditemukan."));
          }

          final prediction = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                PredictionEntryCard(
                  prediction: prediction,
                  showActions: _hasVoted,

                  // 1. LOGIC VOTE (Kalau belum vote)
                  onTap: () async {
                    if (!_hasVoted) {
                      String? result = await showDialog(
                        context: context,
                        builder: (context) =>
                            VoteDialog(prediction: prediction, isUpdate: false),
                      );

                      if (result == 'success') {
                        _loadData();
                      } else if (result == 'already_voted') {
                        _loadData();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Kamu sudah pernah vote di match ini.",
                            ),
                          ),
                        );
                      }
                    }
                  },

                  // 2. LOGIC DELETE
                  onDelete: () async {
                    bool? confirm = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text(
                          "Hapus Vote?",
                          style: TextStyle(
                            fontFamily: 'Nunito Sans',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        content: const Text(
                          "Yakin ingin menghapus prediksi ini?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text(
                              "Batal",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text(
                              "Hapus",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      final result = await PredictionService.deleteVote(
                        request,
                        prediction.id,
                      );

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result['message']),
                            backgroundColor: result['status'] == 'success'
                                ? const Color(0xFF4AA69B)
                                : Colors.red,
                          ),
                        );
                        if (result['status'] == 'success') {
                          _loadData();
                        }
                      }
                    }
                  },

                  // 3. LOGIC UPDATE
                  onUpdate: () async {
                    String? result = await showDialog(
                      context: context,
                      builder: (context) =>
                          VoteDialog(prediction: prediction, isUpdate: true),
                    );
                    if (result == 'success') {
                      _loadData();
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
