
import 'dart:convert';

Destination destinationFromJson(String str) => Destination.fromJson(json.decode(str));

String destinationToJson(Destination data) => json.encode(data.toJson());

class Destination {
  final int destinationId;
  final String placeName;
  final String location;
  final String description;
  final ExtraInfo extraInfo;

  Destination({
    required this.destinationId,
    required this.placeName,
    required this.location,
    required this.description,
    required this.extraInfo,
  });

  factory Destination.fromJson(Map<String, dynamic> json) => Destination(
    destinationId: json["destination_id"],
    placeName: json["place_name"],
    location: json["location"],
    description: json["description"],
    extraInfo: ExtraInfo.fromJson(json["extra_info"]),
  );

  Map<String, dynamic> toJson() => {
    "destination_id": destinationId,
    "place_name": placeName,
    "location": location,
    "description": description,
    "extra_info": extraInfo.toJson(),
  };
}

class ExtraInfo {
  final List<String> highlights;
  final List<String> attractions;
  final String bestTimeToVisit;
  final String transportation;
  final String accommodation;
  final List<String> safetyTips;
  final List<String> photos;
  final List<int> genreVector;
  final String difficultyLevel;
  final String duration;
  final List<int> elevation;
  final List<String> backdropPath;
  final List<String> frontImagePath;

  ExtraInfo({
    required this.highlights,
    required this.attractions,
    required this.bestTimeToVisit,
    required this.transportation,
    required this.accommodation,
    required this.safetyTips,
    required this.photos,
    required this.genreVector,
    required this.difficultyLevel,
    required this.duration,
    required this.elevation,
    required this.backdropPath,
    required this.frontImagePath,
  });

  factory ExtraInfo.fromJson(Map<String, dynamic> json) => ExtraInfo(
    highlights: List<String>.from(json["highlights"].map((x) => x)),
    attractions: List<String>.from(json["attractions"].map((x) => x)),
    bestTimeToVisit: json["best_time_to_visit"],
    transportation: json["transportation"],
    accommodation: json["accommodation"],
    safetyTips: List<String>.from(json["safety_tips"].map((x) => x)),
    photos: List<String>.from(json["photos"].map((x) => x)),
    genreVector: List<int>.from(json["genre_vector"].map((x) => x)),
    difficultyLevel: json["difficulty_level"],
    duration: json["duration"],
    elevation: List<int>.from(json["elevation"].map((x) => x)),
    backdropPath: List<String>.from(json["backdrop_path"].map((x) => x)),
    frontImagePath: List<String>.from(json["front_image_path"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "highlights": List<dynamic>.from(highlights.map((x) => x)),
    "attractions": List<dynamic>.from(attractions.map((x) => x)),
    "best_time_to_visit": bestTimeToVisit,
    "transportation": transportation,
    "accommodation": accommodation,
    "safety_tips": List<dynamic>.from(safetyTips.map((x) => x)),
    "photos": List<dynamic>.from(photos.map((x) => x)),
    "genre_vector": List<dynamic>.from(genreVector.map((x) => x)),
    "difficulty_level": difficultyLevel,
    "duration": duration,
    "elevation": List<dynamic>.from(elevation.map((x) => x)),
    "backdrop_path": List<dynamic>.from(backdropPath.map((x) => x)),
    "front_image_path": List<dynamic>.from(frontImagePath.map((x) => x)),
  };
}
