class Destination {
  final int id;
  final String placeName;
  final String location;
  final String description;
  final DestinationExtraInfo? extraInfo;

  Destination({
    required this.id,
    required this.placeName,
    required this.location,
    required this.description,
    required this.extraInfo,
  });

  factory Destination.fromJson(Map<String, dynamic> json) {
    return Destination(
      id: (json['id'] as num?)?.toInt() ?? 0,
      placeName: json['place_name']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      extraInfo: json['extra_info'] != null
          ? DestinationExtraInfo.fromJson(
        json['extra_info'] as Map<String, dynamic>,
      )
          : null,
    );
  }
}

class DestinationExtraInfo {
  final List<String> photos;
  final List<String> frontImagePath;
  final List<String> backdropPath;

  DestinationExtraInfo({
    required this.photos,
    required this.frontImagePath,
    required this.backdropPath,
  });

  factory DestinationExtraInfo.fromJson(Map<String, dynamic> json) {
    return DestinationExtraInfo(
      photos: List<String>.from(json['photos'] ?? []),
      frontImagePath: List<String>.from(json['front_image_path'] ?? []),
      backdropPath: List<String>.from(json['backdrop_path'] ?? []),
    );
  }
}