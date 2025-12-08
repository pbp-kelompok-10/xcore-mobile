// lib/models/prediction_entry.dart
import 'dart:convert';

int _toInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  if (v is num) return v.toInt();
  return 0;
}

List<Prediction> predictionFromJson(String str) {
  final decoded = json.decode(str);
  if (decoded is List) {
    return List<Prediction>.from(decoded.map((x) {
      try {
        return Prediction.fromJson(Map<String, dynamic>.from(x));
      } catch (e) {
        // Jika parsing item gagal, skip item dan lanjut
        // (tidak melempar agar list bisa tetap dipakai)
        return null;
      }
    }).where((e) => e != null).map((e) => e!));
  }
  return [];
}

class Prediction {
  final String id;
  final String matchId;
  final String homeTeam;
  final String awayTeam;
  final DateTime matchDate;
  final String stadium;
  final String status;
  final String? logoHomeTeam;
  final String? logoAwayTeam;
  final int votesHomeTeam;
  final int votesAwayTeam;
  final int homePercentage;
  final int awayPercentage;
  final int totalVotes;
  final List<Vote> votes;

  Prediction({
    required this.id,
    required this.matchId,
    required this.homeTeam,
    required this.awayTeam,
    required this.matchDate,
    required this.stadium,
    required this.status,
    this.logoHomeTeam,
    this.logoAwayTeam,
    required this.votesHomeTeam,
    required this.votesAwayTeam,
    required this.homePercentage,
    required this.awayPercentage,
    required this.totalVotes,
    required this.votes,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) {
    // safe field getters
    String _str(dynamic v) => v == null ? '' : v.toString();

    // parse date safely
    DateTime dt;
    try {
      dt = DateTime.parse(_str(json['match_date']));
    } catch (_) {
      dt = DateTime.now();
    }

    // parse votes array
    List<Vote> votesList = [];
    if (json['votes'] is List) {
      try {
        votesList = List<Vote>.from(
          (json['votes'] as List).map((v) {
            try {
              return Vote.fromJson(Map<String, dynamic>.from(v));
            } catch (_) {
              return null;
            }
          }).where((e) => e != null).map((e) => e!),
        );
      } catch (_) {
        votesList = [];
      }
    }

    return Prediction(
      id: _str(json['id']),
      matchId: _str(json['match_id']),
      homeTeam: _str(json['home_team']),
      awayTeam: _str(json['away_team']),
      matchDate: dt,
      stadium: _str(json['stadium']),
      status: _str(json['status']).isEmpty ? 'UPCOMING' : _str(json['status']).toUpperCase(),
      logoHomeTeam: json['logo_home_team'] == null ? null : _str(json['logo_home_team']),
      logoAwayTeam: json['logo_away_team'] == null ? null : _str(json['logo_away_team']),
      votesHomeTeam: _toInt(json['votes_home_team']),
      votesAwayTeam: _toInt(json['votes_away_team']),
      homePercentage: _toInt(json['home_percentage']),
      awayPercentage: _toInt(json['away_percentage']),
      totalVotes: _toInt(json['total_votes']),
      votes: votesList,
    );
  }
}

class Vote {
  final int userId;
  final String choice;
  final DateTime votedAt;

  Vote({
    required this.userId,
    required this.choice,
    required this.votedAt,
  });

  factory Vote.fromJson(Map<String, dynamic> json) {
    String _str(dynamic v) => v == null ? '' : v.toString();
    DateTime dt;
    try {
      dt = DateTime.parse(_str(json['voted_at']));
    } catch (_) {
      dt = DateTime.now();
    }

    return Vote(
      userId: _toInt(json['user_id']),
      choice: _str(json['choice']),
      votedAt: dt,
    );
  }
}
