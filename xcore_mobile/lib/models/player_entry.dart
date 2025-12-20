class Player {
  final int id;
  final String nama;
  final String asal;
  final int? umur;
  final int nomor;
  final int teamId;
  final String teamName;
  final String teamCode;

  Player({
    required this.id,
    required this.nama,
    required this.asal,
    required this.umur,
    required this.nomor,
    required this.teamId,
    required this.teamName,
    required this.teamCode,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      nama: json['nama'],
      asal: json['asal'],
      umur: json['umur'],
      nomor: json['nomor'],
      teamId: json['team_id'],
      teamName: json['team_name'],
      teamCode: json['team_code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'asal': asal,
      'umur': umur,
      'nomor': nomor,
      'team_id': teamId,
      'team_name': teamName,
      'team_code': teamCode,
    };
  }
}
