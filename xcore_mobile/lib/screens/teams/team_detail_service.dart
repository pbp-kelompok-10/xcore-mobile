import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class TeamDetailService {
  static const String baseUrl =
      "https://alvin-christian-xcore.pbp.cs.ui.ac.id/lineup/api";

  // GET TEAM DETAILS
  static Future<Map<String, dynamic>> getTeamDetails(int teamId) async {
    try {
      final url = Uri.parse("$baseUrl/teams/$teamId/");
      debugPrint("🔹 GET $url");

      final response = await http.get(url);

      debugPrint("📊 Response status: ${response.statusCode}");
      debugPrint("📝 Response body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        debugPrint("✅ Team details retrieved successfully");
        return responseData;
      } else if (response.statusCode == 404) {
        throw Exception("Team not found");
      } else {
        throw Exception("Failed to fetch team details: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Error fetching team details: $e");
      rethrow;
    }
  }
}
