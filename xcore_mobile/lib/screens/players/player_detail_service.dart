import 'dart:convert';
import 'package:http/http.dart' as http;

class PlayerDetailService {
  static const String baseUrl =
      "http://localhost:8000/lineup/api";

  // -----------------------------------------------------------
  // GET PLAYER DETAILS
  // -----------------------------------------------------------
  static Future<Map<String, dynamic>> getPlayerDetails(int playerId) async {
    final url = Uri.parse("$baseUrl/players/$playerId/");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Player not found');
    } else {
      throw Exception('Failed to fetch player details');
    }
  }

  // -----------------------------------------------------------
  // UPDATE PLAYER
  // -----------------------------------------------------------
  static Future<Map<String, dynamic>> updatePlayer({
    required int playerId,
    required String nama,
    required String asal,
    required int? umur,
    required int nomor,
    String? teamName,
  }) async {
    final url = Uri.parse("$baseUrl/players/$playerId/");

    final body = {"nama": nama, "asal": asal, "nomor": nomor};

    if (umur != null) {
      body["umur"] = umur;
    }

    if (teamName != null && teamName.isNotEmpty) {
      body["team_name"] = teamName;
    }

    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Player not found');
    } else if (response.statusCode == 400) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['error'] ?? 'Failed to update player');
    } else {
      throw Exception('Failed to update player');
    }
  }

  // -----------------------------------------------------------
  // DELETE PLAYER
  // -----------------------------------------------------------
  static Future<bool> deletePlayer(int playerId) async {
    final url = Uri.parse("$baseUrl/players/$playerId/");

    final response = await http.delete(url);

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      return result['deleted'] ?? false;
    } else if (response.statusCode == 404) {
      throw Exception('Player not found');
    } else {
      throw Exception('Failed to delete player');
    }
  }
}
