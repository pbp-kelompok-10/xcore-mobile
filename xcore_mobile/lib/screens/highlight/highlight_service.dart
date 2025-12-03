import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/highlights_entry.dart';

class HighlightService {
  // TODO: replace with your real domain, example:
  // static const String baseUrl = "https://xcore-football.com";
  static const String baseUrl = "http://localhost:8000";

  /// GET highlight data
  static Future<Highlight?> getHighlight(String matchId) async {
    final url = Uri.parse("$baseUrl/highlight/api/$matchId/");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return Highlight.fromJson(jsonData);
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
