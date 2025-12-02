import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:xcore_mobile/models/scoreboard_entry.dart';

class ScoreboardService {
  static const String baseUrl = 'http://localhost:8000'; // Ganti dengan URL Django Anda

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
