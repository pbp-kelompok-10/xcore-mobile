import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:xcore_mobile/models/prediction_entry.dart';
import 'package:xcore_mobile/widgets/prediction/prediction_entry_card.dart';
import 'package:xcore_mobile/widgets/prediction/vote_dialog.dart';

class PredictionPage extends StatefulWidget {
  final String? matchId;

  const PredictionPage({super.key, this.matchId});

  @override
  State<PredictionPage> createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<List<Prediction>> fetchPredictions(CookieRequest request, String endpoint) async {
    final String baseUrl = "http://localhost:8000"; 
    
    try {
      final response = await request.get("$baseUrl$endpoint");
      
      List<Prediction> listData = [];
      for (var d in response) {
        if (d != null) {
          listData.add(Prediction.fromJson(d));
        }
      }
      return listData;
    } catch (e) {
      return []; 
    }
  }

  Future<void> _deleteVote(CookieRequest request, String predictionId) async {
    final url = 'http://localhost:8000/prediction/delete-vote-flutter/';
    
    try {
      final response = await request.post(url, {
        'prediction_id': predictionId,
      });

      if (mounted) {
        if (response['status'] == 'success') {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(
               content: Text(
                 "Vote berhasil dihapus!",
                 style: TextStyle(
                   fontFamily: 'Nunito Sans',
                   fontWeight: FontWeight.w600,
                 ),
               ),
               backgroundColor: Color(0xFF4AA69B),
             )
           );
           setState(() {});
        } else {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               content: Text(
                 response['message'],
                 style: const TextStyle(
                   fontFamily: 'Nunito Sans',
                   fontWeight: FontWeight.w600,
                 ),
               ),
               backgroundColor: const Color(0xFFEF4444),
             )
           );
        }
      }
    } catch (e) {
      if (mounted) {
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
           )
         );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.read<CookieRequest>();

    return Scaffold(
      backgroundColor: const Color(0xFFE8F6F4),
      appBar: AppBar(
        title: const Text(
          "Prediction Center", 
          style: TextStyle(
            fontFamily: 'Nunito Sans',
            fontWeight: FontWeight.w700,
            fontSize: 20,
          )
        ),
        centerTitle: true,
        elevation: 2,
        backgroundColor: const Color(0xFF4AA69B),
        foregroundColor: const Color(0xFFFFFFFF),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFFFFFFF),
          unselectedLabelColor: const Color(0xFFE8F6F4),
          indicatorColor: const Color(0xFFFFFFFF),
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontFamily: 'Nunito Sans',
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Nunito Sans',
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: "All Predictions"),
            Tab(text: "My Votes"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPredictionList(request, '/prediction/json/', false),
          _buildPredictionList(request, '/prediction/json-my-votes/', true),
        ],
      ),
    );
  }

  Widget _buildPredictionList(CookieRequest request, String endpoint, bool isMyVotes) {
    return FutureBuilder<List<Prediction>>(
      future: fetchPredictions(request, endpoint),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF4AA69B),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isMyVotes ? Icons.how_to_vote : Icons.sports_soccer, 
                  size: 80, 
                  color: const Color(0xFF9CA3AF),
                ),
                const SizedBox(height: 24),
                Text(
                  isMyVotes ? "Kamu belum melakukan voting." : "Belum ada prediksi tersedia.",
                  style: const TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B8E8A),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: const Color(0xFF4AA69B),
          backgroundColor: const Color(0xFFFFFFFF),
          onRefresh: () async { setState(() {}); },
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final prediction = snapshot.data![index];
              
              return PredictionEntryCard(
                prediction: prediction,
                showActions: isMyVotes,
                onTap: () async {
                  if (!isMyVotes) {
                    String? result = await showDialog(
                      context: context,
                      builder: (context) => VoteDialog(prediction: prediction, isUpdate: false),
                    );

                    if (result == 'success') {
                      setState(() {});
                    } else if (result == 'already_voted') {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Kamu sudah voting di match ini. Silakan ke tab 'My Votes' untuk mengubah.",
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            backgroundColor: Color(0xFFF59E0B),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
                    }
                  }
                },
                onDelete: isMyVotes ? () async {
                  bool? confirm = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: const Color(0xFFFFFFFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: const Text(
                        "Hapus Vote?",
                        style: TextStyle(
                          fontFamily: 'Nunito Sans',
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2C5F5A),
                        ),
                      ),
                      content: const Text(
                        "Yakin ingin menghapus prediksi ini?",
                        style: TextStyle(
                          fontFamily: 'Nunito Sans',
                          color: Color(0xFF6B8E8A),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text(
                            "Batal",
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            "Hapus",
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFEF4444),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    _deleteVote(request, prediction.id);
                  }
                } : null,
                onUpdate: isMyVotes ? () async {
                  String? result = await showDialog(
                    context: context,
                    builder: (context) => VoteDialog(
                      prediction: prediction,
                      isUpdate: true,
                    ),
                  );
                  if (result == 'success') setState(() {});
                } : null,
              );
            },
          ),
        );
      },
    );
  }
}