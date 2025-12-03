class Prediction {
    String id;
    String question;
    String match;
    int votesHomeTeam;
    int votesAwayTeam;
    dynamic logoHomeTeam;
    dynamic logoAwayTeam;
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

}