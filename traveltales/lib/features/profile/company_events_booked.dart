import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traveltales/api/api.dart';
import 'package:traveltales/api/bookingAPI.dart';
import 'package:traveltales/core/model/booking_model.dart';
import 'package:traveltales/core/model/event_model.dart';
import 'package:traveltales/core/route_config/route_names.dart';
import 'package:traveltales/core/ui/components/shimmerView.dart';
import 'package:traveltales/core/ui/resources/theme/appColors.dart';
import 'package:traveltales/core/ui/resources/theme/dimens.dart';

class CompanyEventsBookedScreen extends StatefulWidget {
  const CompanyEventsBookedScreen({
    super.key,
    required this.companyUserId,
  });

  final int companyUserId;

  @override
  State<CompanyEventsBookedScreen> createState() =>
      _CompanyEventsBookedScreenState();
}

class _CompanyEventsBookedScreenState extends State<CompanyEventsBookedScreen> {
  final BookingApi _bookingService = BookingApi();

  late Future<List<Booking>> _bookingsFuture;
  late Future<List<Event>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _bookingsFuture = _bookingService.getAllBookings();
    _eventsFuture = getAllEvents();
  }

  Future<void> _refresh() async {
    setState(_loadData);
  }

  String _formatEventDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final day = date.day;
    final suffix =
        (day >= 11 && day <= 13)
            ? 'th'
            : switch (day % 10) {
              1 => 'st',
              2 => 'nd',
              3 => 'rd',
              _ => 'th',
            };

    return '$day$suffix ${months[date.month - 1]}';
  }

  String _statusText(Booking booking, Event event) {
    final status = booking.status.toLowerCase().trim();
    if (status == "completed") {
      return "Completed on ${_formatEventDate(event.toDate)}";
    }
    if (status == "pending") {
      return "Coming on ${_formatEventDate(event.fromDate)}";
    }
    return "Booked on ${_formatEventDate(booking.bookedAt)}";
  }

  Widget _buildLoadingShimmer() {
    Widget card() {
      return Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            ShimmerView(width: 54.w, height: 54.w, radius: 12),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerView(width: 120.w, height: 14.h, radius: 8),
                  SizedBox(height: 8.h),
                  ShimmerView(width: 150.w, height: 12.h, radius: 8),
                  SizedBox(height: 8.h),
                  ShimmerView(width: 100.w, height: 12.h, radius: 8),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            ShimmerView(width: 58.w, height: 24.h, radius: 999),
          ],
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: compactDimens.small3),
      children: [
        SizedBox(height: 12.h),
        card(),
        SizedBox(height: 8.h),
        card(),
        SizedBox(height: 8.h),
        card(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Company Event Bookings"),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          _bookingsFuture,
          _eventsFuture,
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingShimmer();
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 40),
                    SizedBox(height: 12.h),
                    const Text("Failed to load company bookings"),
                    SizedBox(height: 12.h),
                    ElevatedButton(
                      onPressed: _refresh,
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              ),
            );
          }

          final bookings = snapshot.data![0] as List<Booking>;
          final events = snapshot.data![1] as List<Event>;

          final companyEvents = events
              .where((event) => event.companyUserId == widget.companyUserId)
              .toList();
          final companyEventMap = {
            for (final event in companyEvents) event.eventId: event,
          };

          final companyBookings = bookings.where((booking) {
            final status = booking.status.toLowerCase().trim();
            return companyEventMap.containsKey(booking.eventId) &&
                status != "failed";
          }).toList()
            ..sort((a, b) => b.bookedAt.compareTo(a.bookedAt));

          if (companyBookings.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(20.w),
                children: const [
                  Text("No bookings found for your events."),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            backgroundColor: Colors.white,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: compactDimens.small3,
                vertical: 12.h,
              ),
              itemBuilder: (context, index) {
                final booking = companyBookings[index];
                final event = companyEventMap[booking.eventId];
                if (event == null) return const SizedBox.shrink();

                final destination = event.destination;
                final images = destination.extraInfo.backdropPath;
                final imageUrl = images.isNotEmpty
                    ? "$API_URL${images.first}"
                    : "";

                return _bookedEventCard(
                  context,
                  imageAsset: imageUrl,
                  title: destination.placeName,
                  statusText: _statusText(booking, event),
                  organizerText: "Booked for ${booking.totalPeople} people",
                  difficultyText: destination.extraInfo.difficultyLevel,
                  priceText: "Rs ${booking.totalPrice}",
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      RouteName.eventDetailScreen,
                      arguments: event,
                    );
                  },
                );
              },
              separatorBuilder: (_, __) => SizedBox(height: 8.h),
              itemCount: companyBookings.length,
            ),
          );
        },
      ),
    );
  }

  Widget _bookedEventCard(
    BuildContext context, {
    required String imageAsset,
    required String title,
    required String statusText,
    required String organizerText,
    required String difficultyText,
    required String priceText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.light
              ? AppColors.containerBoxColor
              : AppColors.darkContainerBoxColor,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: imageAsset.isNotEmpty
                  ? Image.network(
                      imageAsset,
                      height: 54.w,
                      width: 54.w,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Image.asset(
                          "assets/images/Annapurna.png",
                          height: 54.w,
                          width: 54.w,
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  : Image.asset(
                      "assets/images/Annapurna.png",
                      height: 54.w,
                      width: 54.w,
                      fit: BoxFit.cover,
                    ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  _infoRow(Icons.check_circle_outline, statusText, Colors.green),
                  SizedBox(height: 4.h),
                  _infoRow(Icons.verified_outlined, organizerText, Colors.green),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(99.r),
                  ),
                  child: Text(
                    priceText,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.green,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.difficultyBgColor(difficultyText),
                    borderRadius: BorderRadius.circular(99.r),
                  ),
                  child: Text(
                    difficultyText,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.difficultyColor(difficultyText),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, Color iconColor) {
    return Row(
      children: [
        Icon(icon, size: 14.sp, color: iconColor),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
