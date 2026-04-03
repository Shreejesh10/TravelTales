import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:traveltales/api/api.dart';
import 'package:traveltales/core/model/booking_model.dart';
import 'package:traveltales/core/model/esewa_payment_response.dart';

class BookingApi {

  Future<List<Booking>> getAllBookings() async {
    final url = Uri.parse('$API_URL/bookings/');
    final headers = await getHeaders();

    try {
      final response = await http.get(url, headers: headers);

      log("GET ALL BOOKINGS STATUS: ${response.statusCode}");
      log("GET ALL BOOKINGS RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((b) => Booking.fromJson(b)).toList();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error["detail"] ?? "Failed to fetch bookings");
      }
    } catch (e) {
      log("GET ALL BOOKINGS ERROR: $e");
      rethrow;
    }
  }

  Future<Booking> createBooking({
    required int eventId,
    required int totalPeople,
    List<int> friendUserIds = const [],
  }) async {
    final url = Uri.parse('$API_URL/bookings/create');
    final headers = await getHeaders();

    final body = {
      "event_id": eventId,
      "total_people": totalPeople,
      "friend_user_ids": friendUserIds,
    };

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Booking.fromJson(jsonDecode(response.body));
    }

    log("Create booking failed: ${response.statusCode} ${response.body}");
    String? detailMessage;
    try {
      final decodedBody = jsonDecode(response.body);
      if (decodedBody is Map<String, dynamic>) {
        detailMessage = decodedBody["detail"]?.toString();
      }
    } catch (_) {
      // Fall back to the generic error below when the body is not JSON.
    }
    throw Exception(detailMessage ?? "Create booking failed");
  }

  Future<List<Booking>> getMyBookings() async {
    final headers = await getHeaders();
    final url = Uri.parse('$API_URL/bookings/my');

    final response = await http.get(
      url,
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Booking.fromJson(e)).toList();
    } else {
      log("Get my bookings failed: ${response.statusCode} ${response.body}");
      throw Exception(
        "Failed to load my bookings: ${response.statusCode}",
      );
    }
  }

  Future<EsewaPaymentResponse> initiateEsewaPayment(int bookingId) async {
    final url = Uri.parse('$API_URL/bookings/$bookingId/esewa');
    final headers = await getHeaders();

    final response = await http.post(
      url,
      headers: headers,
    );

    if (response.statusCode == 200) {
      return EsewaPaymentResponse.fromJson(jsonDecode(response.body));
    }

    log("Initiate eSewa failed: ${response.statusCode} ${response.body}");
    throw Exception("Failed to initiate eSewa payment");
  }

  Future<void> confirmEsewaSuccess(String redirectUrl) async {
    final redirectUri = Uri.tryParse(redirectUrl);
    final data = redirectUri?.queryParameters['data'];

    if (data == null || data.isEmpty) {
      throw Exception("Missing eSewa success payload");
    }

    final url = Uri.parse('$API_URL/bookings/esewa/success').replace(
      queryParameters: {'data': data},
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      log("eSewa success confirmed: ${response.body}");
      return;
    }

    log("eSewa success confirmation failed: ${response.statusCode} ${response.body}");
    throw Exception("Failed to confirm eSewa payment");
  }

  Future<Booking> getBookingById(int bookingId) async {
    final url = Uri.parse('$API_URL/bookings/$bookingId');
    final headers = await getHeaders();

    final response = await http.get(
      url,
      headers: headers,
    );

    if (response.statusCode == 200) {
      return Booking.fromJson(jsonDecode(response.body));
    }

    log("Get booking failed: ${response.statusCode} ${response.body}");
    throw Exception("Failed to fetch booking");
  }
}
