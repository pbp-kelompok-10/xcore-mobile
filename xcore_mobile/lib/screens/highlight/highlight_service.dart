import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../../models/highlights_entry.dart';
import '../../models/scoreboard_entry.dart';

class HighlightService {
  static const String baseUrl = "http://localhost:8000";

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

  /// GET highlight data
  static Future<Highlight?> getHighlight(String matchId) async {
    final url = Uri.parse("$baseUrl/highlight/api/$matchId/");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final highlightData = jsonData["highlight"];
      // Check if highlight exists and has a valid id
      if (highlightData != null && highlightData["id"] != null) {
        return Highlight.fromJson(jsonData);
      }
    }
    return null;
  }

  /// GET match data (from scoreboard)
  static Future<ScoreboardEntry?> getMatchData(String matchId) async {
    final url = Uri.parse("$baseUrl/scoreboard/json/");
    final response = await http.get(url);

    debugPrint('getMatchData: Looking for matchId = $matchId');
    debugPrint('getMatchData: Response status = ${response.statusCode}');

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      debugPrint('getMatchData: Found ${jsonData.length} matches');
      for (var item in jsonData) {
        final match = ScoreboardEntry.fromJson(item);
        debugPrint('getMatchData: Checking match.id = ${match.id}');
        if (match.id == matchId) {
          debugPrint('getMatchData: Match found!');
          return match;
        }
      }
      debugPrint('getMatchData: No match found with id $matchId');
    }
    return null;
  }

  /// CREATE highlight
  static Future<bool> createHighlight(String matchId, String videoUrl) async {
    final url = Uri.parse("$baseUrl/highlight/api/$matchId/create/");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({"video": videoUrl}),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  /// UPDATE highlight
  static Future<bool> updateHighlight(String matchId, String videoUrl) async {
    final url = Uri.parse("$baseUrl/highlight/api/$matchId/update/");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({"video": videoUrl}),
    );

    return response.statusCode == 200;
  }

  /// DELETE highlight
  static Future<bool> deleteHighlight(String matchId) async {
    final url = Uri.parse("$baseUrl/highlight/api/$matchId/delete/");

    final response = await http.delete(url);

    return response.statusCode == 200;
  }
}
