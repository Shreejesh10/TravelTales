import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:traveltales/api/api.dart';
import 'package:traveltales/core/model/booking_model.dart';
import 'package:traveltales/core/model/esewa_payment_response.dart';

class BookingService {


  Future<Booking> createBooking({
    required int eventId,
    required int totalPeople,
  }) async {
    final url = Uri.parse('$API_URL/bookings/');
    final headers = await getHeaders();

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        "event_id": eventId,
        "total_people": totalPeople,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Booking.fromJson(jsonDecode(response.body));
    }

    log("Create booking failed: ${response.statusCode} ${response.body}");
    throw Exception("Create booking failed");
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