import 'dart:convert';
import 'package:xcore_mobile/models/scoreboard_entry.dart';

// Team Model - sesuai dengan Django Team
Team teamFromJson(String str) => Team.fromJson(json.decode(str));
String teamToJson(Team data) => json.encode(data.toJson());

class Team {
  String id;
  String name;
  String code;

  Team({required this.id, required this.name, required this.code});

  factory Team.fromJson(Map<String, dynamic> json) => Team(
    id: json["id"]?.toString() ?? '',
    name: json["name"]?.toString() ?? 'Unknown Team',
    code: json["code"]?.toString() ?? '',
  );

  Map<String, dynamic> toJson() => {"id": id, "name": name, "code": code};
}

// Player Model - sesuai dengan Django Player
Player playerFromJson(String str) => Player.fromJson(json.decode(str));
String playerToJson(Player data) => json.encode(data.toJson());

class Player {
  String id;
  String nama;
  String asal;
  int? umur;
  int nomor;
  String timId;
  Team? tim; // Optional, jika termasuk data team lengkap

  Player({
    required this.id,
    required this.nama,
    required this.asal,
    this.umur,
    required this.nomor,
    required this.timId,
    this.tim,
  });

  factory Player.fromJson(Map<String, dynamic> json) => Player(
    id: json["id"]?.toString() ?? '',
    nama: json["nama"]?.toString() ?? 'Unknown Player',
    asal: json["asal"]?.toString() ?? '',
    umur: _parseInt(json["umur"]),
    nomor: _parseInt(json["nomor"]),
    timId: json["tim"]?.toString() ?? '',
    tim: json["tim_object"] != null ? Team.fromJson(json["tim_object"]) : null,
  );

  static int? _parseIntOrNull(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "nama": nama,
    "asal": asal,
    "umur": umur,
    "nomor": nomor,
    "tim": timId,
    if (tim != null) "tim_object": tim!.toJson(),
  };
}

// Lineup Model - sesuai dengan Django Lineup
Lineup lineupFromJson(String str) => Lineup.fromJson(json.decode(str));
String lineupToJson(Lineup data) => json.encode(data.toJson());

class Lineup {
  String id;
  String matchId;
  Team team;
  List<Player> players;

  Lineup({
    required this.id,
    required this.matchId,
    required this.team,
    required this.players,
  });

  factory Lineup.fromJson(Map<String, dynamic> json) => Lineup(
    id: json["id"]?.toString() ?? '',
    matchId: json["match"]?.toString() ?? '',
    team: Team.fromJson(json["team"] ?? {}),
    players: List<Player>.from(
      (json["players"] ?? []).map((x) => Player.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "match": matchId,
    "team": team.toJson(),
    "players": List<dynamic>.from(players.map((x) => x.toJson())),
  };
}

// Match Lineup Response - untuk menampung kedua lineup (home & away)
MatchLineupResponse matchLineupResponseFromJson(String str) =>
    MatchLineupResponse.fromJson(json.decode(str));
String matchLineupResponseToJson(MatchLineupResponse data) =>
    json.encode(data.toJson());

class MatchLineupResponse {
  ScoreboardEntry match;
  Lineup? homeLineup;
  Lineup? awayLineup;

  MatchLineupResponse({required this.match, this.homeLineup, this.awayLineup});

  factory MatchLineupResponse.fromJson(Map<String, dynamic> json) =>
      MatchLineupResponse(
        match: ScoreboardEntry.fromJson(json["match"] ?? {}),
        homeLineup: json["home_lineup"] != null
            ? Lineup.fromJson(json["home_lineup"])
            : null,
        awayLineup: json["away_lineup"] != null
            ? Lineup.fromJson(json["away_lineup"])
            : null,
      );

  Map<String, dynamic> toJson() => {
    "match": match.toJson(),
    "home_lineup": homeLineup?.toJson(),
    "away_lineup": awayLineup?.toJson(),
  };
}
