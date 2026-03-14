import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;
import 'package:traveltales/core/model/destination_model.dart';
import 'package:traveltales/core/model/event_create_model.dart';
import 'package:traveltales/core/model/event_model.dart';
import 'package:traveltales/core/model/genre_model.dart';
import 'package:traveltales/core/model/user_info.dart';

final storage = FlutterSecureStorage();
// const String API_URL = 'http://10.0.2.2:8000';
final String API_URL = 'http://192.168.1.67:8000';
// final String API_URL = 'http://100.64.200.118:8000';

// final String API_URL = Platform.isAndroid
//     ? 'http://10.0.2.2:8000' // Android emulator → maps to PC localhost
//     : 'http://192.168.1.80:8000'; // physical device on same LAN


Future<Map<String, String>> getHeaders() async {
  final accessToken = await storage.read(key: 'access_token');

  if (accessToken == null) {
    throw Exception("No access token found. User may not be logged in.");
  }

  return {
    "Content-Type": "application/json",
    "Authorization": "Bearer $accessToken",
  };
}


Future<String?> getUserId() async {
  final accessToken = await storage.read(key: 'access_token');
  if (accessToken == null) return null;

  final parts = accessToken.split('.');
  if (parts.length != 3) return null;

  final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
  final payloadMap = jsonDecode(payload);
  return payloadMap['sub']?.toString();
}


Future<void> addUserData({
  required String userName,
  required String email,
}) async {
  try {
    final url = Uri.parse('$API_URL/add_user_data');

    final body = jsonEncode({
      "user_name": userName,
      "email": email,
    });

    final headers = await getHeaders();

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      log(" User data sent successfully: ${response.body}");
    } else {
      log(
        " Failed to send user data: ${response.statusCode} ${response.body}",
      );
    }
  } catch (e) {
    log("Error sending user data: $e");
  }
}

Future<void> refreshAccessToken() async {
  try {
    final refreshToken = await storage.read(key: 'refresh_token');
    if (refreshToken == null) {
      throw Exception("No refresh token found. User may need to log in again.");
    }

    final url = Uri.parse('$API_URL/refresh');
    final body = jsonEncode({"token": refreshToken});

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Save new access token
      await storage.write(key: 'access_token', value: data['access_token']);
      log("Access token refreshed successfully!");
    } else {
      log("Failed to refresh token: ${response.statusCode} ${response.body}");
      throw Exception("Failed to refresh token");
    }
  } catch (e) {
    log("Error refreshing token: $e");
    rethrow;
  }
}

Future<Map<String, dynamic>> login(String email, String password) async {
  final url = Uri.parse('$API_URL/users/login');
  final body = jsonEncode({
    "email": email,
    "password": password,
  });

  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      await storage.write(key: 'access_token', value: data['access_token']);
      await storage.write(key: 'refresh_token', value: data['refresh_token']);

      final String role = data['roles'] ?? "";
      final bool hasCompleted = data['has_completed_preference'] == true;

      await storage.write(key: 'roles', value: role);
      await storage.write(
        key: 'has_completed_preference',
        value: hasCompleted.toString(),
      );

      log("Login successful. has_completed_preference: $hasCompleted");
      log("Roles: $role");

      return {
        "roles": role,
        "has_completed_preference": hasCompleted,
      };
    } else {
      log("Login failed: ${response.statusCode} ${response.body}");
      throw Exception("Login failed: ${response.body}");
    }
  } catch (e) {
    log("Error during login: $e");
    rethrow;
  }
}
Future<void> signup(String email, String password, String userName) async {
  final url = Uri.parse('$API_URL/users/signup');
  final body = jsonEncode({
    "email": email,
    "password": password,
    "user_name": userName
  });

  try{
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,

    );

    if (response.statusCode == 201){
      final data = jsonDecode(response.body);
      log("Sign up successfully $data");

    }else{
      final error = jsonDecode(response.body);
      log("Sign up failed: ${response.statusCode} $error");
      throw Exception("Sign up failed: ${response.body}");
    }
  }catch(e){
    log("Error during signup: $e");
    rethrow;
  }
}
Future<List<Destination>>searchDestination(String query)async{
  final headers = await getHeaders();
  final url = Uri.parse(
    '$API_URL/destinations/search-destination',
  ).replace(
    queryParameters: {"query": query},
  );

  final response = await http.get(
    url,
    headers: headers,

  );
  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return data.map((e) => Destination.fromJson(e)).toList();
  } else {
    log("Destination search failed: ${response.statusCode} ${response.body}");
    throw Exception("Failed to search destinations");
  }
}
Future<Destination?> getDestinationByID(int destinationId) async {
  final url = Uri.parse('$API_URL/destinations/$destinationId');
  final headers = await getHeaders();

  try {
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Destination.fromJson(data);
    } else {
      log("Destination fetch failed: ${response.statusCode} ${response.body}");
      return null;
    }
  } catch (e) {
    log("Error during fetching destination: $e");
    return null;
  }
}
Future<List<Destination>> getRecommendedDestinations() async {
  final url = Uri.parse('$API_URL/destinations/recommend/me');
  final headers = await getHeaders();

  final response = await http.get(url, headers: headers);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    return List<Map<String, dynamic>>.from(data)
        .map((e) => Destination.fromJson(e))
        .toList();
  }

  throw Exception(
      "Recommended fetch failed: ${response.statusCode} ${response.body}");
}

Future<List<Map<String, dynamic>>> getBestDestinations() async {
  final url = Uri.parse('$API_URL/destinations/best');
  final headers = await getHeaders();

  final response = await http.get(url, headers: headers);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data);
  }

  throw Exception("Best fetch failed: ${response.statusCode} ${response.body}");

}


Future<List<Genre>> fetchAllGenres() async {
  final url = Uri.parse('$API_URL/users/genres');

  final headers = await getHeaders();

  final res = await http.get(url, headers: headers);

  if (res.statusCode == 200) {
    final List data = jsonDecode(res.body);

    return data.map((g) => Genre.fromJson(g)).toList();
  }

  throw Exception("GET /users/genres failed: ${res.statusCode} ${res.body}");
}

Future<UserInfo> fetchMeUserInfo() async {
  final url = Uri.parse('$API_URL/users/me/user_information');
  final headers = await getHeaders(); // uses access_token

  final response = await http.get(url, headers: headers);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    if (data is Map<String, dynamic> && data.containsKey('id')) {
      return UserInfo.fromJson(data);
    }

    if (data is Map<String, dynamic> && data.containsKey('User Information')) {
      final inner = data['User Information'];
      if (inner is Map<String, dynamic>) {
        return UserInfo.fromJson(inner);
      }
    }

    throw Exception("Unexpected user info format: ${response.body}");
  }

  throw Exception("GET /users/me/user_information failed: "
      "${response.statusCode} ${response.body}");
}


Future<List<int>> fetchUserPreferenceIds() async {
  final url = Uri.parse('$API_URL/users/get_preferences/me');
  final headers = await getHeaders();

  final res = await http.get(url, headers: headers);

  if (res.statusCode == 200) {
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final prefs = List<Map<String, dynamic>>.from(data["preferences"] ?? []);
    return prefs.map((p) => (p["id"] as num).toInt()).toList();
  }

  throw Exception(
    "GET /users/get_preferences/me failed: ${res.statusCode} ${res.body}",
  );
}

Future<void> saveUserPreferencesByIds(List<int> genreIds) async {
  final url = Uri.parse('$API_URL/users/update_preferences/me');
  final headers = await getHeaders();

  final body = jsonEncode({
    "preferences": {
      "genre_ids": genreIds,
    }
  });

  final res = await http.post(url, headers: headers, body: body);

  if (res.statusCode == 200 || res.statusCode == 201) return;

  throw Exception(
    "POST /users/update_preferences/me failed: ${res.statusCode} ${res.body}",
  );
}

Future<String> uploadProfilePicture(File imageFile) async {
  final url = Uri.parse('$API_URL/users/me/profile_photo');
  final accessToken = await storage.read(key: 'access_token');
  if (accessToken == null) throw Exception("Access token error.");

  final request = http.MultipartRequest('POST', url);
  request.headers['Authorization'] = 'Bearer $accessToken';

  final ext = p.extension(imageFile.path).toLowerCase();
  MediaType mediaType = MediaType('image', 'jpeg');
  if (ext == '.png') mediaType = MediaType('image', 'png');
  if (ext == '.webp') mediaType = MediaType('image', 'webp');

  request.files.add(
    await http.MultipartFile.fromPath(
      'photo',
      imageFile.path,
      contentType: mediaType,
    ),
  );

  final streamedResponse = await request.send();
  final responseBody = await streamedResponse.stream.bytesToString();

  if (streamedResponse.statusCode == 200) {
    final data = jsonDecode(responseBody);
    final String relativeUrl = data['profile_picture_url']?.toString() ?? "";

    if (relativeUrl.isEmpty) {
      throw Exception("Upload succeeded but no profile_picture_url returned.");
    }

    await storage.write(key: 'profile_picture_url', value: relativeUrl);
    return relativeUrl;
  }

  throw Exception("Upload failed: ${streamedResponse.statusCode} $responseBody");
}

Future<void> logoutAndClearAuth() async {
  await storage.delete(key: 'access_token');
  await storage.delete(key: 'refresh_token');

  await storage.delete(key: 'profile_picture_url');
}

Future<List<Destination>> getAllDestinations() async {
  final url = Uri.parse('$API_URL/destinations/');
  final headers = await getHeaders();

  final response = await http.get(url, headers: headers);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    return List<Map<String, dynamic>>.from(data)
        .map((e) => Destination.fromJson(e))
        .toList();
  }

  throw Exception(
      "All destinations fetch failed: ${response.statusCode} ${response.body}");
}



Future<void> createEvent(EventCreateModel event) async {
  final headers = await getHeaders();

  final url = Uri.parse('$API_URL/events/');

  final response = await http.post(
    url,
    headers: headers,
    body: jsonEncode(event.toJson()),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    log("Event created successfully");
  } else {
    log("Create event failed: ${response.statusCode} ${response.body}");
    throw Exception("Failed to create event");
  }
}

Future<EventCreateModel> getEventById(int eventId) async {
  final url = Uri.parse('$API_URL/events/$eventId');

  final response = await http.get(
    url,
    headers: {
      "Content-Type": "application/json",
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return EventCreateModel.fromJson(data);
  } else {
    log("Get event failed: ${response.statusCode} ${response.body}");
    throw Exception("Failed to load event");
  }
}

Future<EventCreateModel> updateEvent(int eventId, Map<String, dynamic> updatedData) async {
  final headers = await getHeaders();
  final url = Uri.parse('$API_URL/events/$eventId');

  final response = await http.patch(
    url,
    headers: headers,
    body: jsonEncode(updatedData),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    log("Event updated successfully");
    return EventCreateModel.fromJson(data);
  } else {
    log("Update event failed: ${response.statusCode} ${response.body}");
    throw Exception("Failed to update event");
  }
}

Future<void> deleteEvent(int eventId) async {
  final headers = await getHeaders();
  final url = Uri.parse('$API_URL/events/$eventId');

  final response = await http.delete(
    url,
    headers:headers
  );

  if (response.statusCode == 204) {
    log("Event deleted successfully");
  } else {
    log("Delete event failed: ${response.statusCode} ${response.body}");
    throw Exception("Failed to delete event");
  }
}
Future<List<EventCreateModel>> getMyEvents() async {
  final url = Uri.parse('$API_URL/events/me');
  final headers = await getHeaders();

  final response = await http.get(url, headers: headers);

  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return data.map((e) => EventCreateModel.fromJson(e)).toList();
  } else {
    log("Get my events failed: ${response.statusCode} ${response.body}");
    throw Exception("Failed to load my events");
  }
}
Future<List<Event>> getAllEvents() async {
  final url = Uri.parse('$API_URL/events/all');
  final headers = await getHeaders();

  try {
    final response = await http.get(url, headers: headers);

    log("STATUS CODE: ${response.statusCode}");
    log("RESPONSE BODY: ${response.body}");

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Event.fromJson(e)).toList();
    } else {
      throw Exception(
        "Failed to load all events: ${response.statusCode} ${response.body}",
      );
    }
  } catch (e, stackTrace) {
    log("GET ALL EVENTS ERROR: $e");
    log("STACKTRACE: $stackTrace");
    rethrow;
  }
}
