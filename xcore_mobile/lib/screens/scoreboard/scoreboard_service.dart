import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xcore_mobile/models/scoreboard_entry.dart';

class ScoreboardService {
  static Future<List<ScoreboardEntry>> fetchScoreboard() async {
    final url = Uri.parse('http://localhost:8000/scoreboard/json/');

    final response = await http.get(url, headers: {
      "Content-Type": "application/json",
    });

    if (response.statusCode == 200) {
      return scoreboardEntryFromJson(response.body);
    } else {
      throw Exception('Failed to load scoreboard');
    }
  }
}
