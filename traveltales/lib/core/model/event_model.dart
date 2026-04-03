import 'package:traveltales/core/model/destination_model.dart';

class Event {
  final int eventId;
  final int companyUserId;
  final String companyName;
  final String title;
  final String eventDescription;
  final DateTime fromDate;
  final DateTime toDate;
  final String meetingTime;
  final String meetingPoint;
  final List<String> whatToBring;
  final int maxPeople;
  final double price;
  final DateTime createdAt;
  final Destination destination;

  Event({
    required this.eventId,
    required this.companyUserId,
    required this.companyName,
    required this.title,
    required this.eventDescription,
    required this.fromDate,
    required this.toDate,
    required this.meetingTime,
    required this.meetingPoint,
    required this.whatToBring,
    required this.maxPeople,
    required this.price,
    required this.createdAt,
    required this.destination,
  });

  factory Event.fromJson(Map<String, dynamic> json) => Event(
    eventId: json["event_id"] ?? 0,
    companyUserId: json["company_user_id"] ?? 0,
    companyName: json["company_name"] ?? "",
    title: json["title"] ?? "",
    eventDescription: json["event_description"] ?? "",
    fromDate: DateTime.parse(json["from_date"]),
    toDate: DateTime.parse(json["to_date"]),
    meetingTime: json["meeting_time"] ?? "",
    meetingPoint: json["meeting_point"] ?? "",
    whatToBring: List<String>.from(json["what_to_bring"] ?? []),
    maxPeople: json["max_people"] ?? 0,
    price: (json["price"] ?? 0).toDouble(),
    createdAt: DateTime.parse(json["created_at"]),
    destination: Destination.fromJson(json["destination"]),
  );
}
