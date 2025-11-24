class StatistikEntry {
  final String id;
  final String matchId;
  final String homeTeam;
  final String awayTeam;
  final int homeScore;
  final int awayScore;
  final int homeShots;
  final int awayShots;
  final int homeShotsOnTarget;
  final int awayShotsOnTarget;
  final int homeCorners;
  final int awayCorners;
  final int homeYellowCards;
  final int awayYellowCards;
  final int homeRedCards;
  final int awayRedCards;
  final int homeOffsides;
  final int awayOffsides;
  final int homePasses;
  final int awayPasses;
  final double homePossession;
  final double awayPossession;
  final String matchDate;
  final String stadium;

  StatistikEntry({
    required this.id,
    required this.matchId,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeScore,
    required this.awayScore,
    required this.homeShots,
    required this.awayShots,
    required this.homeShotsOnTarget,
    required this.awayShotsOnTarget,
    required this.homeCorners,
    required this.awayCorners,
    required this.homeYellowCards,
    required this.awayYellowCards,
    required this.homeRedCards,
    required this.awayRedCards,
    required this.homeOffsides,
    required this.awayOffsides,
    required this.homePasses,
    required this.awayPasses,
    required this.homePossession,
    required this.awayPossession,
    required this.matchDate,
    required this.stadium,
  });

  factory StatistikEntry.fromJson(Map<String, dynamic> json) {
    return StatistikEntry(
      id: json['id'] ?? '',
      matchId: json['match_id'] ?? '',
      homeTeam: json['home_team'] ?? '',
      awayTeam: json['away_team'] ?? '',
      homeScore: json['home_score'] ?? 0,
      awayScore: json['away_score'] ?? 0,
      homeShots: json['home_shots'] ?? 0,
      awayShots: json['away_shots'] ?? 0,
      homeShotsOnTarget: json['home_shots_on_target'] ?? 0,
      awayShotsOnTarget: json['away_shots_on_target'] ?? 0,
      homeCorners: json['home_corners'] ?? 0,
      awayCorners: json['away_corners'] ?? 0,
      homeYellowCards: json['home_yellow_cards'] ?? 0,
      awayYellowCards: json['away_yellow_cards'] ?? 0,
      homeRedCards: json['home_red_cards'] ?? 0,
      awayRedCards: json['away_red_cards'] ?? 0,
      homeOffsides: json['home_offsides'] ?? 0,
      awayOffsides: json['away_offsides'] ?? 0,
      homePasses: json['home_passes'] ?? 0,
      awayPasses: json['away_passes'] ?? 0,
      homePossession: (json['home_possession'] ?? 0.0).toDouble(),
      awayPossession: (json['away_possession'] ?? 0.0).toDouble(),
      matchDate: json['match_date'] ?? '',
      stadium: json['stadium'] ?? '',
    );
  }
}