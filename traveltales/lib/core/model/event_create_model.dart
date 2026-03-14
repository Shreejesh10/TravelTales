
import 'dart:convert';

import 'destination_model.dart';

EventCreateModel eventFromJson(String str) => EventCreateModel.fromJson(json.decode(str));

String eventToJson(EventCreateModel data) => json.encode(data.toJson());

class EventCreateModel {
  final int destinationId;
  final String title;
  final String eventDescription;
  final DateTime fromDate;
  final DateTime toDate;
  final String meetingTime;
  final String meetingPoint;
  final List<String> whatToBring;
  final int maxPeople;
  final double price;


  EventCreateModel({
    required this.destinationId,
    required this.title,
    required this.eventDescription,
    required this.fromDate,
    required this.toDate,
    required this.meetingTime,
    required this.meetingPoint,
    required this.whatToBring,
    required this.maxPeople,
    required this.price,
  });

  factory EventCreateModel.fromJson(Map<String, dynamic> json) => EventCreateModel(
    destinationId: json["destination_id"],
    title: json["title"],
    eventDescription: json["event_description"],
    fromDate: DateTime.parse(json["from_date"]),
    toDate: DateTime.parse(json["to_date"]),
    meetingTime: json["meeting_time"],
    meetingPoint: json["meeting_point"],
    whatToBring: List<String>.from(json["what_to_bring"].map((x) => x)),
    maxPeople: json["max_people"],
    price: (json["price"] ?? 0).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "destination_id": destinationId,
    "title": title,
    "event_description": eventDescription,
    "from_date": fromDate.toIso8601String(),
    "to_date": toDate.toIso8601String(),
    "meeting_time": meetingTime,
    "meeting_point": meetingPoint,
    "what_to_bring": List<dynamic>.from(whatToBring.map((x) => x)),
    "max_people": maxPeople,
    "price": price,
  };
}
