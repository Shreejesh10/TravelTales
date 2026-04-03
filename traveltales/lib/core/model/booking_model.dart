class BookingInvitedFriend {
  final int id;
  final String userName;
  final String? profilePictureUrl;

  BookingInvitedFriend({
    required this.id,
    required this.userName,
    required this.profilePictureUrl,
  });

  factory BookingInvitedFriend.fromJson(Map<String, dynamic> json) {
    return BookingInvitedFriend(
      id: (json["id"] as num).toInt(),
      userName: json["user_name"]?.toString() ?? "",
      profilePictureUrl: json["profile_picture_url"]?.toString(),
    );
  }
}

class Booking {
  final int bookingId;
  final String transactionUuid;
  final int userId;
  final int eventId;
  final double totalPrice;
  final DateTime bookedAt;
  final int totalPeople;
  final String status;
  final List<BookingInvitedFriend> invitedFriends;

  Booking({
    required this.bookingId,
    required this.transactionUuid,
    required this.userId,
    required this.eventId,
    required this.totalPrice,
    required this.bookedAt,
    required this.totalPeople,
    required this.status,
    required this.invitedFriends,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      bookingId: json["booking_id"],
      transactionUuid: json["transaction_uuid"] ?? "",
      userId: json["user_id"],
      eventId: json["event_id"],
      totalPrice: (json["total_price"] as num).toDouble(),
      bookedAt: DateTime.parse(json["booked_at"]),
      totalPeople: json["total_people"],
      status: json["status"] ?? "pending",
      invitedFriends: List<Map<String, dynamic>>.from(
        json["invited_friends"] ?? const [],
      ).map(BookingInvitedFriend.fromJson).toList(),
    );
  }
}
