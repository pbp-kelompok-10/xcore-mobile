import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:xcore_mobile/models/prediction_entry.dart';

class PredictionService {
  static const String baseUrl = "http://localhost:8000"; 

  // --- 1. FETCH DATA (AMBIL DATA) ---
  static Future<List<Prediction>> fetchPredictions(
      CookieRequest request, String endpoint) async {
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

  // --- 2. VOTE MATCH (SUBMIT / UPDATE) ---
  static Future<Map<String, dynamic>> voteMatch({
    required CookieRequest request,
    required String predictionId,
    required String choice,
    required bool isUpdate,
  }) async {
    final String endpoint = isUpdate
        ? '/prediction/update-vote-flutter/'
        : '/prediction/submit-vote-flutter/';
    final url = '$baseUrl$endpoint';

    try {
      final response = await request.post(url, {
        'prediction_id': predictionId,
        'choice': choice,
      });

      if (response['status'] == 'success') {
        return {'status': 'success', 'message': response['message']};
      } else if (response['message'].toString().contains("sudah voting") ||
          response['status'] == 409) {
        return {'status': 'already_voted', 'message': response['message']};
      } else {
        return {'status': 'failed', 'message': response['message']};
      }
    } catch (e) {
      if (e.toString().contains("sudah voting")) {
        return {'status': 'already_voted', 'message': "Sudah pernah voting"};
      }
      return {'status': 'failed', 'message': "Error: $e"};
    }
  }

  // --- 3. DELETE VOTE ---
  static Future<Map<String, dynamic>> deleteVote(
      CookieRequest request, String predictionId) async {
    final url = '$baseUrl/prediction/delete-vote-flutter/';

    try {
      final response = await request.post(url, {
        'prediction_id': predictionId,
      });

      if (response['status'] == 'success') {
        return {'status': 'success', 'message': "Vote berhasil dihapus!"};
      } else {
        return {'status': 'failed', 'message': response['message']};
      }
    } catch (e) {
      return {'status': 'failed', 'message': "Error: $e"};
    }
  }
}