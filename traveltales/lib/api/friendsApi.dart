import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:traveltales/api/api.dart';
import 'package:traveltales/core/model/friend_request_model.dart';

class FriendApi {
  static final String basePath = "$API_URL/friends";

  // Send friend request
  static Future<FriendRequestModel> sendFriendRequest({
    required int receiverId,
  }) async {
    final headers = await getHeaders();

    final response = await http.post(
      Uri.parse("$basePath/request"),
      headers: headers,
      body: jsonEncode({
        "receiver_id": receiverId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return FriendRequestModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to send friend request: ${response.body}");
    }
  }

  // Accept friend request
  static Future<FriendRequestModel> acceptFriendRequest({
    required int requestId,
  }) async {
    final headers = await getHeaders();

    final response = await http.patch(
      Uri.parse("$basePath/request/$requestId/accept"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return FriendRequestModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to accept friend request: ${response.body}");
    }
  }

  // Reject friend request
  static Future<FriendRequestModel> rejectFriendRequest({
    required int requestId,
  }) async {
    final headers = await getHeaders();

    final response = await http.patch(
      Uri.parse("$basePath/request/$requestId/reject"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return FriendRequestModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to reject friend request: ${response.body}");
    }
  }

  // Get incoming friend requests
  static Future<List<FriendRequestModel>> getIncomingFriendRequests() async {
    final headers = await getHeaders();

    final response = await http.get(
      Uri.parse("$basePath/requests/incoming"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => FriendRequestModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to fetch incoming requests: ${response.body}");
    }
  }

  // Get outgoing friend requests
  static Future<List<FriendRequestModel>> getOutgoingFriendRequests() async {
    final headers = await getHeaders();

    final response = await http.get(
      Uri.parse("$basePath/requests/outgoing"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => FriendRequestModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to fetch outgoing requests: ${response.body}");
    }
  }

  // Get friend list
  static Future<List<FriendModel>> getFriends() async {
    final headers = await getHeaders();

    final response = await http.get(
      Uri.parse(basePath),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => FriendModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to fetch friends: ${response.body}");
    }
  }

  // Remove friend
  static Future<Map<String, dynamic>> removeFriend({
    required int friendshipId,
  }) async {
    final headers = await getHeaders();

    final response = await http.delete(
      Uri.parse("$basePath/$friendshipId"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to remove friend: ${response.body}");
    }
  }
}
