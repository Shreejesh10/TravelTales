import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';
final storage = FlutterSecureStorage();
// const String API_URL = 'http://10.0.2.2:8000';




final String API_URL = Platform.isAndroid
    ? 'http://192.168.1.80:8000'
    : 'http://localhost:8000';



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
  return payloadMap['sub'];
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

Future<void> login(String email, String password) async {
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

      // Save tokens securely
      await storage.write(key: 'access_token', value: data['access_token']);
      await storage.write(key: 'refresh_token', value: data['refresh_token']);

      log(" Login successful!");
    } else {
      log(" Login failed: ${response.statusCode} ${response.body}");
      throw Exception("Login failed: ${response.body}");
    }
  } catch (e) {
    log("Error during login: $e");
    rethrow;
  }
}
Future<void> signup(String email, String password) async {
  final url = Uri.parse('$API_URL/users/signup');
  final body = jsonEncode({
    "email": email,
    "password": password,
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

