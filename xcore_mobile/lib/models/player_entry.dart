import 'team_entry.dart';

class Player {
  final int id;
  final String nama;
  final String asal;
  final int umur;
  final int nomor;
  final Team tim;

  Player({
    required this.id,
    required this.nama,
    required this.asal,
    required this.umur,
    required this.nomor,
    required this.tim,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      nama: json['nama'],
      asal: json['asal'],
      umur: json['umur'],
      nomor: json['nomor'],
      tim: Team.fromJson(json['tim']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'asal': asal,
      'umur': umur,
      'nomor': nomor,
      'tim': tim.toJson(),
    };
  }
}
