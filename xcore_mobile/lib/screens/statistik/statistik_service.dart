import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xcore_mobile/models/statistik_entry.dart'; 
import 'package:xcore_mobile/services/auth_service.dart';

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
        return null;
      } else {
        throw Exception('Failed to load statistik');
      }
    } catch (e) {
      throw Exception('Failed to load statistik: $e');
    }
  }

  // CREATE statistik - SESUAI FIELD MODEL
  static Future<bool> createStatistik(Map<String, dynamic> statistikData) async {
    final url = Uri.parse('http://localhost:8000/statistik/create-flutter/');
    
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode(statistikData),
      );

      print('Create statistik response: ${response.statusCode} - ${response.body}');
      return response.statusCode == 201;
    } catch (e) {
      print('Error creating statistik: $e');
      throw Exception('Failed to create statistik: $e');
    }
  }

  // UPDATE statistik - SESUAI FIELD MODEL  
  static Future<bool> updateStatistik(String matchId, Map<String, dynamic> statistikData) async {
    final url = Uri.parse('http://localhost:8000/statistik/update-flutter/$matchId/');
    
    try {
      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode(statistikData),
      );

      print('Update statistik response: ${response.statusCode} - ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating statistik: $e');
      throw Exception('Failed to update statistik: $e');
    }
  }

  // DELETE statistik
  static Future<bool> deleteStatistik(String matchId) async {
    final url = Uri.parse('http://localhost:8000/statistik/delete-flutter/$matchId/');
    
    try {
      final response = await http.delete(url);

      print('Delete statistik response: ${response.statusCode} - ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting statistik: $e');
      throw Exception('Failed to delete statistik: $e');
    }
  }
}