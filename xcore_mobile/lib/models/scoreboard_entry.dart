// To parse this JSON data, do
//
//     final scoreboardEntry = scoreboardEntryFromJson(jsonString);

import 'dart:convert';

List<ScoreboardEntry> scoreboardEntryFromJson(String str) => List<ScoreboardEntry>.from(json.decode(str).map((x) => ScoreboardEntry.fromJson(x)));

String scoreboardEntryToJson(List<ScoreboardEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ScoreboardEntry {
    String id;
    String homeTeam;
    String awayTeam;
    String homeTeamCode;
    String awayTeamCode;
    int homeScore;
    int awayScore;
    DateTime matchDate;
    String stadium;
    int round;
    String group;
    String status;

    ScoreboardEntry({
        required this.id,
        required this.homeTeam,
        required this.awayTeam,
        required this.homeTeamCode,
        required this.awayTeamCode,
        required this.homeScore,
        required this.awayScore,
        required this.matchDate,
        required this.stadium,
        required this.round,
        required this.group,
        required this.status,
    });

    factory ScoreboardEntry.fromJson(Map<String, dynamic> json) => ScoreboardEntry(
        id: json["id"],
        homeTeam: json["home_team"],
        awayTeam: json["away_team"],
        homeTeamCode: json["home_team_code"],
        awayTeamCode: json["away_team_code"],
        homeScore: json["home_score"],
        awayScore: json["away_score"],
        matchDate: DateTime.parse(json["match_date"]),
        stadium: json["stadium"],
        round: json["round"],
        group: json["group"],
        status: json["status"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "home_team": homeTeam,
        "away_team": awayTeam,
        "home_team_code": homeTeamCode,
        "away_team_code": awayTeamCode,
        "home_score": homeScore,
        "away_score": awayScore,
        "match_date": matchDate.toIso8601String(),
        "stadium": stadium,
        "round": round,
        "group": group,
        "status": status,
    };
}
