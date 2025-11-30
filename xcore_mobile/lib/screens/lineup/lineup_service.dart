// services/lineup_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xcore_mobile/models/lineup_entry.dart';
import 'package:xcore_mobile/models/scoreboard_entry.dart';

class LineupService {
  static const String baseUrl = 'http://localhost:8000'; // Ganti dengan URL Django Anda

  static Future<MatchLineupResponse> fetchLineup(String matchId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/lineup/flutter/$matchId/'), // Sesuaikan dengan URL Django
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return MatchLineupResponse.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Lineup not found for match $matchId');
      } else {
        throw Exception('Failed to load lineup: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load lineup: $e');
    }
  }

  static Future<bool> createLineup({
    required String matchId,
    required String teamCode,
    required List<String> playerIds,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/lineup/flutter/create/$matchId/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'team_code': teamCode,
          'players': playerIds,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception('Failed to create lineup: $e');
    }
  }

  static Future<bool> updateLineup({
    required String lineupId,
    required List<String> playerIds,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/lineup/flutter/update/$lineupId/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'players': playerIds,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to update lineup: $e');
    }
  }

  static Future<bool> deleteLineup(String lineupId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/lineup/flutter/delete/$lineupId/'),
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw Exception('Failed to delete lineup: $e');
    }
  }

  // Get available players for a team
  static Future<List<Player>> fetchPlayersByTeam(String teamCode) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/players/?team_code=$teamCode'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Player>.from(data.map((x) => Player.fromJson(x)));
      } else {
        throw Exception('Failed to load players: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load players: $e');
    }
  }
}