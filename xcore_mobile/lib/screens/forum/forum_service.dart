// forum_service.dart
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:xcore_mobile/models/forum_entry.dart';
import 'package:xcore_mobile/models/post_entry.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class ForumService {
  static const String baseUrl = 'http://localhost:8000'; // Ganti URL Django

  // Get forum by match ID
  static Future<ForumEntry> fetchForumByMatch(String matchId) async {
    final response = await http.get(Uri.parse('$baseUrl/forum/$matchId/json/'));

    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.body);
        return ForumEntry.fromJson(data);
      } catch (e) {
        print('JSON Parse Error: $e');
        throw Exception('Error parsing JSON: $e');
      }
    } else {
      throw Exception('Failed to load forum: ${response.statusCode}');
    }
  }

  // Get posts for a forum
  static Future<List<PostEntry>> fetchPosts(String forumId) async {
    final response = await http.get(Uri.parse('$baseUrl/forum/flutter/$forumId/get_posts/'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<PostEntry>.from(data['posts'].map((x) => PostEntry.fromJson(x)));
    } else {
      throw Exception('Failed to load posts');
    }
  }

  // Add new post
  static Future<void> addPost(String forumId, String message, BuildContext context) async {
    final request = context.read<CookieRequest>();

    try {
      if (!request.loggedIn) {
        throw Exception('User not logged in. Please login first.');
      }

      // Menggunakan CookieRequest untuk mengirim request dengan cookies/session
      final response = await request.post(
        '${ForumService.baseUrl}/forum/flutter/$forumId/add_post/',
        {
          'message': message,
        },
      );

      if (response['success'] != true) {
        throw Exception(response['error'] ?? 'Failed to edit post');
      }

    } catch (e) {
      rethrow;
    }

  }

  // Edit post
  static Future<void> editPost(String forumId, String postId, String message, BuildContext context) async {
    final request = context.read<CookieRequest>();

    try {
      if (!request.loggedIn){
        throw Exception('User not logged in. Please login first.');
      }

      // Menggunakan CookieRequest untuk mengirim request dengan cookies/session
      final response = await request.post(
        '${ForumService.baseUrl}/forum/flutter/$forumId/edit_post/$postId/',
        {
          'message': message,
        },
      );

      if (response['success'] != true) {
        throw Exception('Failed to edit post');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Delete post
  static Future<void> deletePost(String forumId, String postId, BuildContext context) async {
    final request = context.read<CookieRequest>();

    try {
      final response = await request.post(
        '${baseUrl}/forum/flutter/$forumId/delete_post/$postId/',
        {}
      );

      if (response['success'] != true) {
        throw Exception('Failed to delete post');
      }
    } catch (e) {
      rethrow;
    }

  }
}