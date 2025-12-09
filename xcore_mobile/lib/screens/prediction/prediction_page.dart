import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:xcore_mobile/models/prediction_entry.dart';
import 'package:xcore_mobile/widgets/prediction/prediction_entry_card.dart';
import 'package:xcore_mobile/widgets/prediction/vote_dialog.dart';

class PredictionPage extends StatefulWidget {
  const PredictionPage({super.key});

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

  // --- FUNGSI FETCH DATA ---
  Future<List<Prediction>> fetchPredictions(CookieRequest request, String endpoint) async {
    // Gunakan 127.0.0.1 untuk Web, atau 10.0.2.2 untuk Android Emulator
    final String baseUrl = "http://localhost:8000"; 
    
    try {
      final response = await request.get("$baseUrl$endpoint");
      
      // Parsing manual hasil JSON ke List<Prediction>
      List<Prediction> listData = [];
      for (var d in response) {
        if (d != null) {
          listData.add(Prediction.fromJson(d));
        }
      }
      return listData;
    } catch (e) {
      // Jika error fetch (misal belum login atau server mati), return list kosong
      return []; 
    }
  }

  // --- FUNGSI DELETE VOTE ---
  Future<void> _deleteVote(CookieRequest request, String predictionId) async {
    final url = 'http://localhost:8000/prediction/delete-vote-flutter/';
    
    try {
      final response = await request.post(url, {
        'prediction_id': predictionId,
      });

      if (mounted) {
        if (response['status'] == 'success') {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text("Vote berhasil dihapus!"), backgroundColor: Colors.green)
           );
           setState(() {}); // Refresh UI setelah hapus
        } else {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text(response['message']), backgroundColor: Colors.red)
           );
        }
      }
    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.read<CookieRequest>();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Prediction Center", 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF6200EE), // Warna Ungu Aktif
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF6200EE),
          indicatorWeight: 3,
          tabs: const [
            Tab(text: "All Predictions"),
            Tab(text: "My Votes"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: ALL PREDICTIONS
          _buildPredictionList(request, '/prediction/json/', false),

          // TAB 2: MY VOTES
          _buildPredictionList(request, '/prediction/json-my-votes/', true),
        ],
      ),
    );
  }

  // Widget Helper untuk menampilkan List
  Widget _buildPredictionList(CookieRequest request, String endpoint, bool isMyVotes) {
    return FutureBuilder<List<Prediction>>(
      future: fetchPredictions(request, endpoint),
      builder: (context, snapshot) {
        // A. Loading State
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // B. Data Kosong
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(isMyVotes ? Icons.how_to_vote : Icons.sports_soccer, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  isMyVotes ? "Kamu belum melakukan voting." : "Belum ada prediksi tersedia.",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        // C. Tampilkan List Data
        return RefreshIndicator(
          onRefresh: () async { setState(() {}); },
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final prediction = snapshot.data![index];
              
              return Column(
                children: [
                  // 1. CARD UTAMA (Tap Logic)
                  PredictionEntryCard(
                    prediction: prediction,
                    onTap: () async {
                      // HANYA BISA KLIK CARD DI TAB "ALL" (Untuk Vote Baru)
                      if (!isMyVotes) {
                        String? result = await showDialog(
                          context: context,
                          builder: (context) => VoteDialog(prediction: prediction, isUpdate: false),
                        );

                        // Logika hasil dialog
                        if (result == 'success') {
                          setState(() {}); // Refresh data
                        } else if (result == 'already_voted') {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Kamu sudah voting di match ini. Silakan ke tab 'My Votes' untuk mengubah."),
                                backgroundColor: Colors.orange,
                                duration: Duration(seconds: 3),
                              ),
                            );
                          }
                        }
                      }
                      // Di Tab "My Votes", klik card tidak melakukan apa-apa
                    },
                  ),

                  // 2. TOMBOL KHUSUS TAB "MY VOTES" (Delete & Update)
                  if (isMyVotes)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Row(
                        children: [
                          // TOMBOL DELETE
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                bool? confirm = await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Hapus Vote?"),
                                    content: const Text("Yakin ingin menghapus prediksi ini?"),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
                                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Hapus", style: TextStyle(color: Colors.red))),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  _deleteVote(request, prediction.id);
                                }
                              },
                              icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                              label: const Text("Delete", style: TextStyle(color: Colors.red)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.red),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 12), 

                          // TOMBOL UPDATE
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                // Buka VoteDialog mode Update
                                String? result = await showDialog(
                                  context: context,
                                  builder: (context) => VoteDialog(prediction: prediction, isUpdate: true),
                                );
                                if (result == 'success') setState(() {});
                              },
                              icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                              label: const Text("Update Vote", style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6200EE),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}