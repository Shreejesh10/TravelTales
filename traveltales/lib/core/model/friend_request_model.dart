class FriendRequestModel {
  final int id;
  final int senderId;
  final int receiverId;
  final String status;
  final DateTime createdAt;
  final DateTime? respondedAt;

  FriendRequestModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.status,
    required this.createdAt,
    this.respondedAt,
  });

  factory FriendRequestModel.fromJson(Map<String, dynamic> json) {
    return FriendRequestModel(
      id: json["id"],
      senderId: json["sender_id"],
      receiverId: json["receiver_id"],
      status: json["status"],
      createdAt: DateTime.parse(json["created_at"]),
      respondedAt: json["responded_at"] != null
          ? DateTime.parse(json["responded_at"])
          : null,
    );
  }
}

class FriendModel {
  final int id;
  final int userId;
  final int friendUserId;

  FriendModel({
    required this.id,
    required this.userId,
    required this.friendUserId,
  });

  factory FriendModel.fromJson(Map<String, dynamic> json) {
    return FriendModel(
      id: json["id"],
      userId: json["user_id"],
      friendUserId: json["friend_user_id"],
    );
  }
}