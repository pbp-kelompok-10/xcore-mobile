import 'dart:convert';
import 'package:http/http.dart' as http;

class TeamCreateUpdateService {
  static const String baseUrl =
      "https://alvin-christian-xcore.pbp.cs.ui.ac.id/lineup/api";

  // -----------------------------------------------------------
  // CREATE TEAM
  // -----------------------------------------------------------
  static Future<Map<String, dynamic>> createTeam({required String name}) async {
    final url = Uri.parse("$baseUrl/teams/");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name}),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 400) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['error'] ?? 'Failed to create team');
    } else {
      throw Exception('Failed to create team');
    }
  }

  // -----------------------------------------------------------
  // UPDATE TEAM
  // -----------------------------------------------------------
  static Future<Map<String, dynamic>> updateTeam({
    required int id,
    required String code,
  }) async {
    final url = Uri.parse("$baseUrl/teams/$id/update/");

    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"code": code}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 400) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['error'] ?? 'Failed to update team');
    } else if (response.statusCode == 404) {
      throw Exception('Team not found');
    } else {
      throw Exception('Failed to update team');
    }
  }
}
