// post_entry.dart
import 'dart:convert';

List<PostEntry> postEntryFromJson(String str) =>
    List<PostEntry>.from(json.decode(str).map((x) => PostEntry.fromJson(x)));

String postEntryToJson(List<PostEntry> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PostEntry {
  String id;
  int authorId;
  String authorName;
  String message;
  String? authorPicture;
  DateTime createdAt;
  bool isEdited;
  DateTime? editedAt;

  PostEntry({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.message,
    required this.authorPicture,
    required this.createdAt,
    required this.isEdited,
    required this.editedAt,
  });

  factory PostEntry.fromJson(Map<String, dynamic> json) => PostEntry(
    id: json["id"]?.toString() ?? '',
    authorId: _parseInt(json["author_id"]),
    authorName: json["author_name"]?.toString() ?? 'Unknown',
    message: json["message"]?.toString() ?? '',
    authorPicture: json["author_picture"]?.toString(),
    // Gunakan key yang benar dan handle parsing
    createdAt: _parseDateTime(json["created_at"] ?? json["created_at"]),
    isEdited: json["is_edited"] ?? false,
    editedAt: _parseDateTime(json["edited_at"]),
  );

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static DateTime _parseDateTime(dynamic dateString) {
    if (dateString == null) return DateTime.now();
    try {
      return DateTime.parse(dateString.toString());
    } catch (e) {
      return DateTime.now();
    }
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "author_id": authorId,
    "author_name": authorName,
    "message": message,
    "author_picture": authorPicture,
    "created_at": createdAt.toIso8601String(),
    "is_edited": isEdited,
    "edited_at": editedAt?.toIso8601String(),
  };
}