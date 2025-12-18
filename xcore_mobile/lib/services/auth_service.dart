import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:convert';

class AuthService {
  static const String _baseUrl = 'http://localhost:8000';

  // Save user data
  static Future<void> saveUserData(
    String token,
    Map<String, dynamic> userData,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setBool('is_admin', userData['is_admin'] ?? false);
    await prefs.setString('username', userData['username'] ?? '');
  }

  // Check if user is admin
  static Future<bool> isAdmin() async {
    try {
      final token = await getToken();

      // Make request to the endpoint
      final response = await http.get(
        Uri.parse('$_baseUrl/auth/is-admin/'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Token $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint("📊 Admin status response: $data");
        if (data['status'] == true) {
          final isAdmin = data['is_admin'] ?? false;
          debugPrint("✅ Admin status retrieved: $isAdmin");
          // Cache the result in SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('is_admin', isAdmin);
          return isAdmin;
        }
      }
    } catch (e) {
      debugPrint('❌ Error checking admin status from endpoint: $e');
    }

    // Fallback to cached value
    final prefs = await SharedPreferences.getInstance();
    final cachedAdmin = prefs.getBool('is_admin') ?? false;
    debugPrint("💾 Using cached admin status: $cachedAdmin");
    return cachedAdmin;
  }

  // Get stored token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Clear user data (logout)
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('is_admin');
    await prefs.remove('username');
  }

  // Get user info from Django
  static Future<Map<String, dynamic>?> getUserInfo() async {
    final token = await getToken();
    if (token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/auth/user-info/'),
        headers: {'Authorization': 'Token $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          await saveUserData(token, data['user']);
          return data['user'];
        }
      }
    } catch (e) {
      print('Error getting user info: $e');
    }

    return null;
  }
}
