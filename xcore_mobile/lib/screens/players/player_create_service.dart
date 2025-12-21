import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class PlayerCreateService {
  static const String baseUrl =
      "https://alvin-christian-xcore.pbp.cs.ui.ac.id/lineup/api";

  // CREATE PLAYER
  static Future<int> createPlayer({
    required int teamId,
    required String nama,
    required String asal,
    required int? umur,
    required int nomor,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/players/");
      debugPrint("🔹 POST $url");

      final body = {
        "team_id": teamId,
        "nama": nama,
        "asal": asal,
        "nomor": nomor,
      };

      if (umur != null) {
        body["umur"] = umur;
      }

      debugPrint("📤 Request body: $body");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      debugPrint("📊 Response status: ${response.statusCode}");
      debugPrint("📝 Response body: ${response.body}");

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final playerId = responseData['id'] as int;
        debugPrint("✅ Player created with ID: $playerId");
        return playerId;
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['error'] ?? 'Invalid request';
        throw Exception(errorMessage);
      } else {
        throw Exception("Failed to create player: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Error creating player: $e");
      rethrow;
    }
  }
}
