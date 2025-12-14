import 'dart:convert';
// import 'dart:typed_data';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

import '../../models/team_entry.dart';

class TeamService {
  // 🔥 Change this based on your server
  static const String baseUrl = "http://10.0.2.2:8000/lineup/api";

  // ------------------------------------------------------------
  // GET ALL TEAMS
  // ------------------------------------------------------------
  static Future<List<Team>> getTeams() async {
    final url = Uri.parse("$baseUrl/teams/");
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch teams");
    }

    final body = jsonDecode(response.body);

    return (body["teams"] as List)
        .map((team) => Team.fromJson(team))
        .toList();
  }

  // ------------------------------------------------------------
  // GET TEAM BY ID
  // ------------------------------------------------------------
  static Future<Team> getTeam(int id) async {
    final url = Uri.parse("$baseUrl/teams/$id/");
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("Team not found");
    }

    return Team.fromJson(jsonDecode(response.body));
  }

  // ------------------------------------------------------------
  // CREATE TEAM
  // ------------------------------------------------------------
  static Future<bool> createTeam(String code) async {
    final url = Uri.parse("$baseUrl/teams/create/");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"code": code}),
    );

    return response.statusCode == 201;
  }

  // ------------------------------------------------------------
  // UPDATE TEAM
  // ------------------------------------------------------------
  static Future<bool> updateTeam(int id, String code) async {
    final url = Uri.parse("$baseUrl/teams/$id/update/");
    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"code": code}),
    );

    return response.statusCode == 200;
  }

  // ------------------------------------------------------------
  // DELETE TEAM
  // ------------------------------------------------------------
  static Future<bool> deleteTeam(int id) async {
    final url = Uri.parse("$baseUrl/teams/$id/delete/");
    final response = await http.delete(url);

    return response.statusCode == 204;
  }

  // ------------------------------------------------------------
  // PICK ZIP FILE USING file_picker
  // ------------------------------------------------------------
  static Future<File?> pickZipFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );

    if (result == null) return null; // User cancelled

    return File(result.files.single.path!);
  }

  // ------------------------------------------------------------
  // UPLOAD ZIP FILE
  // ------------------------------------------------------------
  static Future<Map<String, dynamic>> uploadTeamsZip(File zipFile) async {
    final url = Uri.parse("$baseUrl/upload/teams/");

    final request = http.MultipartRequest('POST', url)
      ..files.add(
        await http.MultipartFile.fromPath('file', zipFile.path),
      );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    return jsonDecode(response.body);
  }
}
