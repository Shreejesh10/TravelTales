class UserInfo {
  final int id;
  final String email;
  final String userName;
  final String roles;
  final String status;
  final String? profilePictureUrl;

  UserInfo({
    required this.id,
    required this.email,
    required this.userName,
    required this.roles,
    required this.status,
    required this.profilePictureUrl,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: (json['id'] as num).toInt(),
      email: json['email']?.toString() ?? '',
      userName: json['user_name']?.toString() ?? '',
      roles: json['roles']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      profilePictureUrl: json['profile_picture_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'user_name': userName,
      'roles': roles,
      'status': status,
      'profile_picture_url': profilePictureUrl,
    };
  }
}