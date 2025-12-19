// services/lineup_service.dart
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:xcore_mobile/models/lineup_entry.dart';
import 'package:xcore_mobile/models/scoreboard_entry.dart';

class LineupService {
  static const String baseUrl = 'http://localhost:8000'; // Untuk Android emulator

  static Future<bool> fetchAdminStatus(BuildContext context) async {
    final request = context.watch<CookieRequest>();

    try {
      final response = await request.get(
        '$baseUrl/auth/is-admin/',
      );

      // Periksa apakah user terautentikasi DAN apakah admin
      if (response['status'] == true) {
        return response['is_admin'];
      } else {
        // User tidak terautentikasi
        return false;
      }
    } catch (e) {
      throw Exception('Failed to get admin status : $e');
    }
  }

  static Future<MatchLineupResponse> fetchLineup(String matchId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/lineup/flutter/$matchId/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return MatchLineupResponse.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Lineup not found for match $matchId');
      } else {
        throw Exception('Failed to load lineup: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching lineup: $e');
      throw Exception('Failed to load lineup: $e');
    }
  }

  static Future<bool> createLineup({
    required String matchId,
    required String teamCode,
    required List<String> playerIds,
  }) async {
    try {
      if (playerIds.length != 11) {
        throw Exception('Must have exactly 11 players, got ${playerIds.length}');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/lineup/flutter/create/$matchId/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'team_code': teamCode,
          'players': playerIds,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return data['success'] == true;
      } else if (response.statusCode == 400) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        throw Exception(data['error'] ?? 'Validation failed');
      } else {
        throw Exception('Failed to create lineup: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating lineup: $e');
      rethrow;
    }
  }

  static Future<bool> updateLineup({
    required String lineupId,
    required List<String> playerIds,
  }) async {
    try {
      if (playerIds.length != 11) {
        throw Exception('Must have exactly 11 players, got ${playerIds.length}');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/lineup/flutter/update/$lineupId/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'players': playerIds,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return data['success'] == true;
      } else if (response.statusCode == 400) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        throw Exception(data['error'] ?? 'Validation failed');
      } else {
        throw Exception('Failed to update lineup: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating lineup: $e');
      rethrow;
    }
  }

  // Get available players for a team - FIXED to match Django endpoint
  static Future<List<Player>> fetchPlayersByTeam(String teamId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/lineup/ajax/get-players/?team=$teamId'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final playersData = data['players'] as List;

        // Parse the player data from Django response
        return playersData.map((playerData) {
          // Assuming playerData is {'id': X, 'name': 'Name (#Number)'}
          // We need to parse this string
          final nameString = playerData['name'] as String;
          final nameMatch = RegExp(r'^(.*?) \(#(\d+)\)$').firstMatch(nameString);

          String playerName = nameString;
          int playerNumber = 0;

          if (nameMatch != null) {
            playerName = nameMatch.group(1)!;
            playerNumber = int.parse(nameMatch.group(2)!);
          }

          return Player(
            id: playerData['id'].toString(),
            nama: playerName,
            asal: '', // Not available from this endpoint
            umur: 0,   // Not available from this endpoint
            nomor: playerNumber,
            timId: teamId,
          );
        }).toList();
      } else {
        throw Exception('Failed to load players: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching players: $e');
      throw Exception('Failed to load players: $e');
    }
  }

  // NEW: Get teams for a match
  static Future<List<Team>> fetchTeamsForMatch(String matchId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/lineup/ajax/get-teams/?match=$matchId'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final teamsData = data['teams'] as List;

        return teamsData.map((teamData) {
          return Team(
            id: teamData['id'].toString(),
            name: teamData['name'] as String,
            code: '', // Not available from this endpoint
          );
        }).toList();
      } else {
        throw Exception('Failed to load teams: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load teams: $e');
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
}