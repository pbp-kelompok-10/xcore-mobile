import 'scoreboard_entry.dart';

class Highlight {
  final int id;
  final String? video;
  final ScoreboardEntry match;

  Highlight({
    required this.id,
    required this.video,
    required this.match,
  });

  factory Highlight.fromJson(Map<String, dynamic> json) {
    final highlightJson = json["highlight"];  // 🔥 correct nested JSON
    final matchJson = json["match"];          // 🔥 match is also nested

    return Highlight(
      id: highlightJson["id"],
      video: highlightJson["video"],          // 🔥 this will now be correct
      match: ScoreboardEntry.fromJson(matchJson),
    );
  }
}
