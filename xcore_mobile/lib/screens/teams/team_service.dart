import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

import '../../models/team_entry.dart';

class TeamService {
  // 🔥 Change this based on your server
  static const String baseUrl = "http://localhost:8000/lineup/api";

  // GET ALL TEAMS
  static Future<List<Team>> getTeams() async {
    try {
      final url = Uri.parse("$baseUrl/teams/");
      debugPrint("🔹 GET $url");
      final response = await http.get(url);

      debugPrint("📊 Response status: ${response.statusCode}");
      debugPrint("📝 Response body: ${response.body}");

      if (response.statusCode != 200) {
        throw Exception("Failed to fetch teams: ${response.statusCode}");
      }

      final body = jsonDecode(response.body);
      debugPrint("✅ Decoded body: $body");

      // API returns: {"teams": [{"id": 1, "code": "ARG", "name": "Argentina"}, ...]}
      if (body is! Map || body["teams"] == null) {
        throw Exception("Unexpected response format: expected {teams: [...]}, got $body");
      }

      final teamsList = (body["teams"] as List).cast<Map<String, dynamic>>();
      debugPrint("🎯 Found ${teamsList.length} teams");

      return teamsList.map((team) => Team.fromJson(team)).toList();
    } catch (e) {
      debugPrint("❌ Error in getTeams: $e");
      rethrow;
    }
  }

  // ------------------------------------------------------------
  // GET TEAM BY ID
  // ------------------------------------------------------------
  static Future<Team> getTeam(int id) async {
    final url = Uri.parse("$baseUrl/teams/$id/");
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("Team not found");
    }

    return Team.fromJson(jsonDecode(response.body));
  }

  // ------------------------------------------------------------
  // CREATE TEAM
  // ------------------------------------------------------------
  static Future<bool> createTeam(String code) async {
    final url = Uri.parse("$baseUrl/teams/create/");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"code": code}),
    );

    return response.statusCode == 201;
  }

  // ------------------------------------------------------------
  // UPDATE TEAM
  // ------------------------------------------------------------
  static Future<bool> updateTeam(int id, String code) async {
    final url = Uri.parse("$baseUrl/teams/$id/update/");
    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"code": code}),
    );

    return response.statusCode == 200;
  }

  // ------------------------------------------------------------
  // DELETE TEAM
  // ------------------------------------------------------------
  static Future<bool> deleteTeam(int id) async {
    final url = Uri.parse("$baseUrl/teams/$id/delete/");
    final response = await http.delete(url);

    return response.statusCode == 204;
  }

  static Future<Uint8List?> pickZipFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
      withData: true, // IMPORTANT for web
    );

    if (result == null) return null;
    return result.files.single.bytes;
  }

  // ------------------------------------------------------------
  // UPLOAD ZIP FILE (BASE64 JSON)
  // ------------------------------------------------------------
  static Future<Map<String, dynamic>> uploadTeamsZip(
    Uint8List zipBytes,
  ) async {
    final url = Uri.parse("$baseUrl/upload/teams/");

    final base64Zip = base64Encode(zipBytes);

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "file": base64Zip,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    return jsonDecode(response.body);
  }
}
