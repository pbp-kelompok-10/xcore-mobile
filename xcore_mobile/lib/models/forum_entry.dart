// To parse this JSON data, do
//
//     final forumEntry = forumEntryFromJson(jsonString);

import 'dart:convert';

List<ForumEntry> forumEntryFromJson(String str) =>
    List<ForumEntry>.from(json.decode(str).map((x) => ForumEntry.fromJson(x)));

String forumEntryToJson(List<ForumEntry> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ForumEntry {
  String id;
  String nama;

  // match data (nullable jika null di Django)
  int? matchId;
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
    id: json["id"],
    nama: json["nama"],

    // null-safe match info
    matchId: json["match_id"],
    matchHome: json["match_home"],
    matchAway: json["match_away"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "nama": nama,
    "match_id": matchId,
    "match_home": matchHome,
    "match_away": matchAway,
  };
}