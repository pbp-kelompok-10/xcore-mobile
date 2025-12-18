import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

import '../../models/player_entry.dart';

class PlayerService {
  // 🔥 Change based on your server
  static const String baseUrl = "http://localhost:8000/lineup/api";

  // ------------------------------------------------------------
  // GET ALL PLAYERS
  // ------------------------------------------------------------
  static Future<List<Player>> getPlayers() async {
    final url = Uri.parse("$baseUrl/players/");
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch players");
    }

    final jsonBody = jsonDecode(response.body);

    return (jsonBody["players"] as List)
        .map((p) => Player.fromJson(p))
        .toList();
  }

  // ------------------------------------------------------------
  // GET PLAYER BY ID
  // ------------------------------------------------------------
  static Future<Player> getPlayer(int id) async {
    final url = Uri.parse("$baseUrl/players/$id/");
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("Player not found");
    }

    return Player.fromJson(jsonDecode(response.body));
  }

  // ------------------------------------------------------------
  // GET PLAYERS BY TEAM ID
  // ------------------------------------------------------------
  static Future<List<Player>> getPlayersByTeam(int teamId) async {
    final url = Uri.parse("$baseUrl/players/?team=$teamId");
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch players by team");
    }

    final jsonBody = jsonDecode(response.body);

    return (jsonBody["players"] as List)
        .map((p) => Player.fromJson(p))
        .toList();
  }

  // ------------------------------------------------------------
  // CREATE PLAYER
  // ------------------------------------------------------------
  static Future<bool> createPlayer({
    required String nama,
    required String asal,
    required int umur,
    required int nomor,
    required int teamId,
  }) async {
    final url = Uri.parse("$baseUrl/players/create/");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "nama": nama,
        "asal": asal,
        "umur": umur,
        "nomor": nomor,
        "tim": teamId,
      }),
    );

    return response.statusCode == 201;
  }

  // ------------------------------------------------------------
  // UPDATE PLAYER
  // ------------------------------------------------------------
  static Future<bool> updatePlayer({
    required int id,
    required String nama,
    required String asal,
    required int umur,
    required int nomor,
    required int teamId,
  }) async {
    final url = Uri.parse("$baseUrl/players/$id/update/");

    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "nama": nama,
        "asal": asal,
        "umur": umur,
        "nomor": nomor,
        "tim": teamId,
      }),
    );

    return response.statusCode == 200;
  }

  // ------------------------------------------------------------
  // DELETE PLAYER
  // ------------------------------------------------------------
  static Future<bool> deletePlayer(int id) async {
    final url = Uri.parse("$baseUrl/players/$id/delete/");

    final response = await http.delete(url);

    return response.statusCode == 204;
  }

  // ------------------------------------------------------------
  // PICK ZIP FILE USING file_picker (Flutter Web compatible)
  // ------------------------------------------------------------
  static Future<Uint8List?> pickPlayersZip() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["zip"],
    );

    if (result == null) return null;

    return result.files.single.bytes;
  }

  // ------------------------------------------------------------
  // UPLOAD PLAYERS ZIP (base64 JSON format for Flutter Web)
  // ------------------------------------------------------------
  static Future<Map<String, dynamic>> uploadPlayersZip(
    Uint8List zipBytes,
  ) async {
    final url = Uri.parse("$baseUrl/upload/players/");

    final base64File = base64Encode(zipBytes);

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"file": base64File}),
    );

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['error'] ?? 'Upload failed');
    }

    final result = jsonDecode(response.body);

    if (result['status'] != 'ok') {
      throw Exception('Upload returned an error');
    }

    return result;
  }
}
