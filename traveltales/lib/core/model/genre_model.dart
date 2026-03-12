import 'dart:convert';

List<Genre> genreFromJson(String str) =>
    List<Genre>.from(json.decode(str).map((x) => Genre.fromJson(x)));

String genreToJson(List<Genre> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Genre {
  final int genreId;
  final String name;

  Genre({
    required this.genreId,
    required this.name,
  });

  factory Genre.fromJson(Map<String, dynamic> json) => Genre(
    genreId: (json["genre_id"] ?? json["id"]) as int,
    name: json["name"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "genre_id": genreId,
    "name": name,
  };
}