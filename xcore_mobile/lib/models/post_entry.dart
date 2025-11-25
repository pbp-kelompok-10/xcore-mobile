// To parse this JSON data, do
//
//     final postEntry = postEntryFromJson(jsonString);

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
    id: json["id"],
    authorId: json["author_id"],
    authorName: json["author_name"],
    message: json["message"],
    authorPicture: json["author_picture"],
    // Perhatikan: Key di sini "creaated_at" (sesuai input awal Anda)
    // Pastikan backend memang mengirim typo ini, atau ubah jadi "created_at" jika perlu.
    createdAt: DateTime.parse(json["creaated_at"]),
    isEdited: json["is_edited"],
    editedAt: json["edited_at"] == null ? null : DateTime.parse(json["edited_at"]),
  );

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