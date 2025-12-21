import 'dart:convert';
import 'dart:typed_data';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ProfileService {
  static Future<Map<String, dynamic>> updateProfile({
    required CookieRequest request, // Wajib pakai CookieRequest
    required String username,
    required String email,
    required String bio,
    Uint8List? imageBytes,
    String? imageFilename,
  }) async {
    // Sesuaikan URL (Localhost untuk Web, 10.0.2.2 untuk Emulator Android)
    String url ="https://alvin-christian-xcore.pbp.cs.ui.ac.id/profile/update-flutter/";

    // Konversi Image Bytes ke Base64 String
    String? base64Image;
    if (imageBytes != null) {
      // Backend split(';base64,'), jadi kita format sesuai Data URL scheme
      // Atau kirim raw base64 jika backend sudah kita sesuaikan (kode backend di atas sudah handle keduanya)
      String base64Str = base64Encode(imageBytes);
      base64Image = "data:image/jpeg;base64,$base64Str";
    }

    try {
      // PENTING: Gunakan request.postJson untuk mengirim cookies otomatis
      final response = await request.postJson(
        url,
        jsonEncode({
          "username": username,
          "email": email,
          "bio": bio,
          "image": base64Image, // String panjang base64
          "image_name": imageFilename,
        }),
      );

      return response;
    } catch (e) {
      // Tangkap error jika server melempar status code error (seperti 401/500)
      return {"status": "error", "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getUserProfile(
    CookieRequest request,
  ) async {
    String url = kIsWeb
        ? "https://alvin-christian-xcore.pbp.cs.ui.ac.id/profile/json/"
        : "http://10.0.2.2:8000/profile/json/";

    final response = await request.get(url);
    return response;
  }
}
