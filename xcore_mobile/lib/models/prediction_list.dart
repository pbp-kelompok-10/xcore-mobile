// To parse this JSON data, do
//
//     final prediction = predictionFromJson(jsonString);

import 'dart:convert';

List<Prediction> predictionFromJson(String str) => List<Prediction>.from(json.decode(str).map((x) => Prediction.fromJson(x)));

String predictionToJson(List<Prediction> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Prediction {
    String id;
    String question;
    String match; 
    int votesHomeTeam;
    int votesAwayTeam;
    String? logoHomeTeam; 
    String? logoAwayTeam; 
    int totalVotes;
    int homePercentage;
    int awayPercentage;
    List<Vote> votes;

    Prediction({
        required this.id,
        required this.question,
        required this.match,
        required this.votesHomeTeam,
        required this.votesAwayTeam,
        required this.logoHomeTeam,
        required this.logoAwayTeam,
        required this.totalVotes,
        required this.homePercentage,
        required this.awayPercentage,
        required this.votes,
    });

    factory Prediction.fromJson(Map<String, dynamic> json) => Prediction(
        id: json["id"],
        question: json["question"],
        match: json["match"].toString(), // .toString() untuk jaga-jaga kalau json kirim int
        votesHomeTeam: json["votes_home_team"],
        votesAwayTeam: json["votes_away_team"],
        logoHomeTeam: json["logo_home_team"],
        logoAwayTeam: json["logo_away_team"],
        totalVotes: json["total_votes"],
        homePercentage: json["home_percentage"],
        awayPercentage: json["away_percentage"],
        votes: List<Vote>.from(json["votes"].map((x) => Vote.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "question": question,
        "match": match,
        "votes_home_team": votesHomeTeam,
        "votes_away_team": votesAwayTeam,
        "logo_home_team": logoHomeTeam,
        "logo_away_team": logoAwayTeam,
        "total_votes": totalVotes,
        "home_percentage": homePercentage,
        "away_percentage": awayPercentage,
        "votes": List<dynamic>.from(votes.map((x) => x.toJson())),
    };
}

class Vote {
    int userId;
    String choice;
    DateTime votedAt;

    Vote({
        required this.userId,
        required this.choice,
        required this.votedAt,
    });

    factory Vote.fromJson(Map<String, dynamic> json) => Vote(
        userId: json["user_id"],
        choice: json["choice"],
        votedAt: DateTime.parse(json["voted_at"]),
    );

    Map<String, dynamic> toJson() => {
        "user_id": userId,
        "choice": choice,
        "voted_at": votedAt.toIso8601String(),
    };
}