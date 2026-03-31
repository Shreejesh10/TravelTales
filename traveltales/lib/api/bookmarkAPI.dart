import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:traveltales/api/api.dart'; // for API_URL



Future<void> addBookmark(int destinationId) async {
  final response = await http.post(
    Uri.parse("$API_URL/bookmarks/"),
    headers: await getHeaders(),
    body: jsonEncode({
      "destination_id": destinationId,
    }),
  );

  if (response.statusCode != 200 && response.statusCode != 201) {
    throw Exception("Failed to add bookmark: ${response.body}");
  }
}

Future<void> removeBookmark(int destinationId) async {
  final response = await http.delete(
    Uri.parse("$API_URL/bookmarks/$destinationId"),
    headers: await getHeaders(),
  );

  if (response.statusCode != 200) {
    throw Exception("Failed to remove bookmark: ${response.body}");
  }
}


Future<bool> checkBookmark(int destinationId) async {
  final response = await http.get(
    Uri.parse("$API_URL/bookmarks/check/$destinationId"),
    headers: await getHeaders(),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data["bookmarked"] ?? false;
  } else {
    throw Exception("Failed to check bookmark");
  }
}


Future<List<dynamic>> getBookmarks() async {
  final response = await http.get(
    Uri.parse("$API_URL/bookmarks/"),
    headers: await getHeaders(),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception("Failed to load bookmarks");
  }
}