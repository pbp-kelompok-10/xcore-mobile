import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:xcore_mobile/models/statistik_entry.dart'; 

class StatistikService {
  // static const String baseUrl = 'http://10.0.2.2:8000'; // Android emulator
  static const String baseUrl = 'http://localhost:8000'; // iOS/Web

  static Future<bool> fetchAdminStatus(BuildContext context) async {
    final request = context.watch<CookieRequest>();
    try {
      final response = await request.get('$baseUrl/auth/is-admin/');
      return response['is_admin'] ?? false;
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }

  static Future<StatistikEntry?> fetchStatistik(String matchId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/statistik/flutter/$matchId/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return StatistikEntry.fromJson(data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        print('Error fetching statistik: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching statistik: $e');
      return null;
    }
  }

  // CREATE statistik - KIRIM SEBAGAI JSON
  static Future<bool> createStatistik(BuildContext context, Map<String, dynamic> statistikData) async {
    try {
      print('=== CREATE STATISTIK ===');
      print('Data to send: $statistikData');
      
      // Kirim sebagai JSON
      final response = await http.post(
        Uri.parse('$baseUrl/statistik/flutter/create/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(statistikData),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          return data['status'] == true;
        } catch (e) {
          print('Error parsing response: $e');
          return false;
        }
      }
      return false;
      
    } catch (e) {
      print('Error creating statistik: $e');
      rethrow;
    }
  }

  // UPDATE statistik - KIRIM SEBAGAI JSON PUT
  static Future<bool> updateStatistik(BuildContext context, String matchId, Map<String, dynamic> statistikData) async {
    try {
      print('=== UPDATE STATISTIK ===');
      print('Match ID: $matchId');
      print('Data to send: $statistikData');
      print('JSON encoded: ${json.encode(statistikData)}');
      
      // Kirim sebagai PUT dengan JSON
      final response = await http.put(
        Uri.parse('$baseUrl/statistik/flutter/update/$matchId/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(statistikData),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          return data['status'] == true;
        } catch (e) {
          print('Error parsing response: $e');
          return false;
        }
      }
      return false;
      
    } catch (e) {
      print('Error updating statistik: $e');
      rethrow;
    }
  }

  // DELETE statistik - KIRIM SEBAGAI JSON DELETE
  static Future<bool> deleteStatistik(BuildContext context, String matchId) async {
    try {
      print('=== DELETE STATISTIK ===');
      print('Match ID: $matchId');
      
      // Kirim DELETE request dengan JSON header
      final response = await http.delete(
        Uri.parse('$baseUrl/statistik/flutter/delete/$matchId/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          return data['status'] == true;
        } catch (e) {
          print('Error parsing response: $e');
          return false;
        }
      }
      return false;
      
    } catch (e) {
      print('Error deleting statistik: $e');
      rethrow;
    }
  }


  // ALTERNATIVE: Gunakan CookieRequest untuk autentikasi
  static Future<bool> createStatistikWithAuth(BuildContext context, Map<String, dynamic> statistikData) async {
    try {
      print('=== CREATE WITH AUTH ===');
      
      final request = context.read<CookieRequest>();
      
      // CookieRequest secara otomatis menangani JSON
      final response = await request.post(
        '$baseUrl/statistik/flutter/create/',
        statistikData, // CookieRequest akan convert ke JSON
      );

      print('Auth response: $response');
      
      if (response is Map) {
        return response['status'] == true;
      }
      return false;
      
    } catch (e) {
      print('Error with auth: $e');
      return false;
    }
  }
}