import 'dart:convert';

List<PendingCompany> pendingCompanyFromJson(String str) => List<PendingCompany>.from(json.decode(str).map((x) => PendingCompany.fromJson(x)));

String pendingCompanyToJson(List<PendingCompany> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PendingCompany {
  final int userId;
  final String email;
  final String userName;
  final DateTime registeredAt;

  PendingCompany({
    required this.userId,
    required this.email,
    required this.userName,
    required this.registeredAt,
  });

  factory PendingCompany.fromJson(Map<String, dynamic> json) => PendingCompany(
    userId: json["user_id"],
    email: json["email"],
    userName: json["user_name"],
    registeredAt: DateTime.parse(json["registered_at"]),
  );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "email": email,
    "user_name": userName,
    "registered_at": registeredAt.toIso8601String(),
  };
}
