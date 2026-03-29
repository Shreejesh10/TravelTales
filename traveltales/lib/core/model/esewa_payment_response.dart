class EsewaPaymentResponse {
  final String paymentUrl;
  final Map<String, dynamic> formData;
  final int bookingId;
  final String transactionUuid;

  EsewaPaymentResponse({
    required this.paymentUrl,
    required this.formData,
    required this.bookingId,
    required this.transactionUuid,
  });

  factory EsewaPaymentResponse.fromJson(Map<String, dynamic> json) {
    return EsewaPaymentResponse(
      paymentUrl: json['payment_url'],
      formData: Map<String, dynamic>.from(json['form_data']),
      bookingId: json['booking_id'],
      transactionUuid: json['transaction_uuid'],
    );
  }
}