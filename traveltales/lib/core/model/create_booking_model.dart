class BookingCreateModel {
  final int eventId;
  final int totalPeople;

  BookingCreateModel({
    required this.eventId,
    required this.totalPeople,
  });

  Map<String, dynamic> toJson() {
    return {
      "event_id": eventId,
      "total_people": totalPeople,
    };
  }
}