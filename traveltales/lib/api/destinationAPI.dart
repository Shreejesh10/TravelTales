import 'package:traveltales/api/api.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:traveltales/core/model/destination_model.dart';
import 'package:traveltales/core/ui/components/functions/dateTime/app_formatters.dart';

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



Future<Destination?> createDestination(Map<String, dynamic> body) async {
  final url = Uri.parse('$API_URL/destinations/');
  final headers = await getHeaders();

  try {
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return Destination.fromJson(data);
    } else {
      log("Create destination failed: ${response.statusCode} ${response.body}");
      return null;
    }
  } catch (e) {
    log("Error during creating destination: $e");
    return null;
  }
}

Future<Destination?> uploadDestinationBackdropWeb({
  required int destinationId,
  required Uint8List bytes,
  required String filename,
}) async {
  final url = Uri.parse('$API_URL/destinations/$destinationId/upload-backdrop');
  final headers = await getHeaders();

  try {
    final request = http.MultipartRequest('POST', url);

    if (headers['Authorization'] != null) {
      request.headers['Authorization'] = headers['Authorization']!;
    }

    request.files.add(
      http.MultipartFile.fromBytes(
        'photo',
        bytes,
        filename: filename,
        contentType: getMediaType(filename),
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return Destination.fromJson(data);
    } else {
      log("Upload backdrop failed: ${response.statusCode} ${response.body}");
      return null;
    }
  } catch (e) {
    log("Error during backdrop upload: $e");
    return null;
  }
}

Future<Destination?> uploadDestinationFrontImageWeb({
  required int destinationId,
  required Uint8List bytes,
  required String filename,
}) async {
  final url =
  Uri.parse('$API_URL/destinations/$destinationId/upload-front-image');
  final headers = await getHeaders();

  try {
    final request = http.MultipartRequest('POST', url);

    if (headers['Authorization'] != null) {
      request.headers['Authorization'] = headers['Authorization']!;
    }

    request.files.add(
      http.MultipartFile.fromBytes(
        'photo',
        bytes,
        filename: filename,
        contentType: getMediaType(filename),
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return Destination.fromJson(data);
    } else {
      log("Upload front image failed: ${response.statusCode} ${response.body}");
      return null;
    }
  } catch (e) {
    log("Error during front image upload: $e");
    return null;
  }
}

Future<Destination> updateDestination({
  required int destinationId,
  required Map<String, dynamic> body,
}) async {
  final headers = await getHeaders();

  final response = await http.patch(
    Uri.parse('$API_URL/destinations/$destinationId'),
    headers: {
      ...headers,
      'Content-Type': 'application/json',
    },
    body: jsonEncode(body),
  );

  log("Update destination status: ${response.statusCode}");
  log("Update destination body: ${response.body}");

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return Destination.fromJson(data);
  } else {
    throw Exception(
      "Failed to update destination: ${response.statusCode} ${response.body}",
    );
  }
}

Future<void> deleteDestination(int destinationId) async {
  final headers = await getHeaders();

  final response = await http.delete(
    Uri.parse('$API_URL/destinations/$destinationId'),
    headers: headers,
  );

  if (response.statusCode == 204) {
    return;
  } else if (response.statusCode == 404) {
    log("Delete destination failed: ${response.statusCode} ${response.body}");
    throw Exception("Destination not found");
  } else if (response.statusCode == 403) {
    log("Delete destination failed: ${response.statusCode} ${response.body}");
    throw Exception("Only admin can delete destination");
  } else {
    log("Delete destination failed: ${response.statusCode} ${response.body}");
    throw Exception("Failed to delete destination");
  }
}