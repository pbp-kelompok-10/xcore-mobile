import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xcore_mobile/models/statistik_entry.dart'; 

class StatistikService {
  static Future<StatistikEntry?> fetchStatistik(String matchId) async {
    final url = Uri.parse('http://localhost:8000/statistik/$matchId/json/');

    try {
      final response = await http.get(url, headers: {
        "Content-Type": "application/json",
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return StatistikEntry.fromJson(data);
      } else if (response.statusCode == 404) {
        // Statistik belum ada untuk match ini
        return null;
      } else {
        throw Exception('Failed to load statistik');
      }
    } catch (e) {
      throw Exception('Failed to load statistik: $e');
    }
  }

  static Future<List<StatistikEntry>> fetchAllStatistik() async {
    final url = Uri.parse('http://localhost:8000/statistik/json/');

    final response = await http.get(url, headers: {
      "Content-Type": "application/json",
    });

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => StatistikEntry.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load statistik list');
    }
  }
}