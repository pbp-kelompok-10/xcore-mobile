class Team {
  final String code;
  final String name;

  Team({
    required this.code,
    required this.name,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      code: json['code'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
    };
  }
}
