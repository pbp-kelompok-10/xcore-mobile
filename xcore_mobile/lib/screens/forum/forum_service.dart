// forum_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xcore_mobile/models/forum_entry.dart';
import 'package:xcore_mobile/models/post_entry.dart';

class ForumService {
  static const String baseUrl = 'http://localhost:8000'; // Ganti URL Django

  // Get forum by match ID
  static Future<ForumEntry> fetchForumByMatch(String matchId) async {
    final response = await http.get(Uri.parse('$baseUrl/forum/$matchId/json/'));

    print('URL: $baseUrl/forum/$matchId/json/');
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}'); // Debug

    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.body); // PERBAIKAN: response.body bukan response.forum_data
        print('Parsed Data: $data'); // Debug
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
  static Future<void> addPost(String forumId, String message) async {
    final response = await http.post(
      Uri.parse('$baseUrl/forum/flutter/$forumId/add_post/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'message': message}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add post');
    }
  }

  // Edit post
  static Future<void> editPost(String forumId, String postId, String message) async {
    final response = await http.post(
      Uri.parse('$baseUrl/forum/flutter/$forumId/edit_post/$postId/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'message': message}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to edit post');
    }
  }

  // Delete post
  static Future<void> deletePost(String forumId, String postId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/forum/flutter/$forumId/delete_post/$postId/'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete post');
    }
  }
}