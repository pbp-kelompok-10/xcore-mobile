// forum_entry.dart
import 'dart:convert';

List<ForumEntry> forumEntryFromJson(String str) =>
    List<ForumEntry>.from(json.decode(str).map((x) => ForumEntry.fromJson(x)));

String forumEntryToJson(List<ForumEntry> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ForumEntry {
  String id;
  String nama;
  String? matchId; // Ubah dari int? menjadi String?
  String? matchHome;
  String? matchAway;

  ForumEntry({
    required this.id,
    required this.nama,
    this.matchId,
    this.matchHome,
    this.matchAway,
  });

  factory ForumEntry.fromJson(Map<String, dynamic> json) => ForumEntry(
    id: json["id"]?.toString() ?? '',
    nama: json["nama"]?.toString() ?? 'Forum',
    // match_id di-parse sebagai String
    matchId: json["match_id"]?.toString(),
    matchHome: json["match_home"]?.toString(),
    matchAway: json["match_away"]?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "nama": nama,
    "match_id": matchId,
    "match_home": matchHome,
    "match_away": matchAway,
  };
}