import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traveltales/api/api.dart';
import 'package:traveltales/api/bookingAPI.dart';
import 'package:traveltales/core/ui/components/button.dart';
import 'package:traveltales/core/ui/localization/sharedRes.dart';
import 'package:traveltales/core/ui/resources/theme/appColors.dart';
import 'package:traveltales/features/bookedEventsDetail/esewa_webview_screen.dart';

import '../../../core/model/booking_model.dart';
import '../../../core/model/event_model.dart';


class EventBookingScreen extends StatefulWidget {
  final Event event;
  const EventBookingScreen({super.key, required this.event});

  @override
  State<EventBookingScreen> createState() => _EventBookingScreenState();
}

class _EventBookingScreenState extends State<EventBookingScreen> {
  int selectedPayment = 0;
  bool isEsewaSelected = false;
  final BookingApi _bookingService = BookingApi();
  bool isLoading = false;
  Event get event => widget.event;

  Future<void> _handleEsewaPayment() async {
    if (!isEsewaSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select eSewa")),
      );
      return;
    }

    try {
      setState(() => isLoading = true);

      final booking = await _bookingService.createBooking(
        eventId: event.eventId,
        totalPeople: 1,
      );

      final paymentData = await _bookingService.initiateEsewaPayment(
        booking.bookingId,
      );
      debugPrint("paymentUrl: ${paymentData.paymentUrl}");
      debugPrint("formData: ${paymentData.formData}");

      setState(() => isLoading = false);

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EsewaWebViewScreen(
            paymentUrl: paymentData.paymentUrl,
            formData: paymentData.formData,
            successUrlPrefix: '$API_URL/bookings/esewa/success',
            failureUrlPrefix: '$API_URL/bookings/esewa/failure',
          ),
        ),
      );

      if (!mounted) return;

      if (result == true) {
        setState(() => isLoading = true);

        Booking? updatedBooking;

        for (int i = 0; i < 6; i++) {
          await Future.delayed(const Duration(seconds: 2));
          updatedBooking = await _bookingService.getBookingById(booking.bookingId);

          if (updatedBooking.status.toLowerCase() == "completed") {
            break;
          }
        }

        if (!mounted) return;
        setState(() => isLoading = false);

        if (updatedBooking != null &&
            updatedBooking.status.toLowerCase() == "completed") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Payment successful")),
          );
        } else if (updatedBooking != null &&
            updatedBooking.status.toLowerCase() == "pending") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Payment received, but verification is still pending"),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Payment verification failed")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Payment cancelled or failed")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Proceed to Payment")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _paymentBox(onTap: () {}),
            SizedBox(height: 4.h),
            _contentBox(
              context,
              heading: "Esewa",
              isSelected: isEsewaSelected,
              onTap: () {
                setState(() {
                  isEsewaSelected = true;
                });
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 18.h),
        child: _priceBottomBar(),
      ),
    );
  }

  Widget _priceBottomBar() {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.getContainerBoxColor(context),
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.08),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    SharedRes.strings(context).totalPrice,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.getSmallTextColor(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    event.price.toString(),
                    // AppFormatters.formatPrice(event.price),
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 14.w),
            SizedBox(
              width: 160.w,
              height: 54.h,
              child: AppButton(
                onPressed: isLoading ? null : _handleEsewaPayment,
                text: isLoading ? "Processing..." : SharedRes.strings(context).bookNow,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentBox({required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.getContainerBoxColor(context),
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.08),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 60.h,
                  width: 60.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6EE),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(Icons.backpack, color: Colors.green, size: 28.sp),
                ),

                SizedBox(width: 12.w),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "RS ${event.price.toString()}",
                              style: TextStyle(
                                color: AppColors.getRichTextColor(context),
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            TextSpan(
                              text: "/person",
                              style: TextStyle(
                                color: AppColors.getSmallTextColor(context),
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        "Basic Details",
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 22.h),

            Text(
              "Everything included in the Package:",
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 6.h,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: (event.whatToBring.isNotEmpty)
                  ? event.whatToBring
                  .map(
                    (item) => checklistItem(context, item),
              )
                  .toList()
                  : [
                checklistItem(
                  context,
                  "No checklist available",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget checklistItem(BuildContext context, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 20.h,
            width: 20.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(color: Colors.green),
              color: const Color(0xFFECFDF5),
            ),
            child: const Icon(Icons.check, size: 14, color: Colors.green),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                height: 1.4,
                color: AppColors.getSmallTextColor(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _contentBox(
  BuildContext context, {
  required String heading,
  required VoidCallback onTap,
  required bool isSelected,
}) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(12.w),
    decoration: BoxDecoration(
      color: AppColors.getContainerBoxColor(context),
      borderRadius: BorderRadius.circular(14.r),
      border: Border.all(
        color: Theme.of(context).dividerColor.withOpacity(0.08),
      ),
      boxShadow: [
        BoxShadow(
          blurRadius: 10,
          offset: const Offset(0, 4),
          color: Colors.black.withOpacity(0.05),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 2.h),
            child: Row(
              children: [
                Image.asset("assets/images/esewa.png", height: 24.h),

                SizedBox(width: 8.w),

                Expanded(
                  child: Text(
                    heading,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                Radio<bool>(
                  value: true,
                  groupValue: isSelected, // pass this from parent
                  onChanged: (_) => onTap(),
                  activeColor: AppColors.getIconColors(context),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
