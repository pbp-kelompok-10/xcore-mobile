import 'package:pbp_django_auth/pbp_django_auth.dart';

class ProfileService {
  static Future<Map<String, dynamic>> getUserProfile(
    CookieRequest request,
  ) async {
    try {
      final response = await request.get(
        'http://localhost:8000/user/api/profile/',
      );

      if (response is Map) {
        final Map<String, dynamic> profileData = Map<String, dynamic>.from(
          response,
        );

        // Convert HTTP to HTTPS if needed
        if (profileData['profile_picture'] is String) {
          profileData['profile_picture'] = profileData['profile_picture']
              .replaceFirst('http://', 'https://');
        }

        return profileData;
      }

      throw Exception('Failed to fetch user profile');
    } catch (e) {
      throw Exception('Error fetching profile: $e');
    }
  }
}
