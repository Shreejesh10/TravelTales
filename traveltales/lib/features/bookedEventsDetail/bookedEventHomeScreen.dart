import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traveltales/api/api.dart';
import 'package:traveltales/api/bookingAPI.dart';
import 'package:traveltales/core/model/booking_model.dart';
import 'package:traveltales/core/model/event_model.dart';
import 'package:traveltales/core/route_config/route_names.dart';
import 'package:traveltales/core/ui/components/viewAllRow.dart';
import 'package:traveltales/core/ui/localization/sharedRes.dart';
import 'package:traveltales/core/ui/resources/theme/appColors.dart';
import 'package:traveltales/core/ui/resources/theme/dimens.dart';

class BookedEventHomeScreen extends StatefulWidget {
  const BookedEventHomeScreen({super.key});

  @override
  State<BookedEventHomeScreen> createState() => _BookedEventHomeScreenState();
}

class _BookedEventHomeScreenState extends State<BookedEventHomeScreen> {
  final BookingApi _bookingService = BookingApi();
  late Future<List<Booking>> _bookingsFuture;
  late Future<List<Event>> _eventsFuture;


  @override
  void initState() {
    super.initState();
    _bookingsFuture = _bookingService.getMyBookings();
    _eventsFuture = getAllEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: compactDimens.extraLarge,
        leading: Padding(
          padding: EdgeInsets.only(left: compactDimens.small3),
          child: Image.asset(
            Theme.of(context).brightness == Brightness.dark
                ? 'assets/images/MountainDark.png'
                : 'assets/images/Mountain.png',
            height: compactDimens.medium2,
            fit: BoxFit.contain,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.notifications_none,
              size: compactDimens.medium1,
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          _bookingsFuture,
          _eventsFuture,
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Failed to load bookings"));
          }

          final bookings = snapshot.data![0] as List<Booking>;
          final events = snapshot.data![1] as List<Event>;

          final Map<int, Event> eventMap = {
            for (final event in events) event.eventId: event,
          };

          final upcoming = bookings
              .where((b) => b.status != "completed")
              .toList();

          final completed = bookings
              .where((b) => b.status == "completed")
              .toList();

          return ListView(
            padding: EdgeInsets.symmetric(horizontal: compactDimens.small3),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("This Journey is", style: _headingStyle()),
                  Row(
                    children: [
                      Text("Yours Now!", style: _headingStyle()),
                      SizedBox(width: compactDimens.small1),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16.r),
                        child: Image.asset(
                          'assets/images/CreatingEventImage.jpg',
                          height: 34.h,
                          width: compactDimens.homeScreenImageSize,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),
                  ViewAllRow(
                    firstText: "Upcoming Events",
                    onPressed: () {},
                    isViewAll: false,
                  ),
                  SizedBox(height: 8.h),

                  ...upcoming.map((booking) {
                    final event = eventMap[booking.eventId];
                    if (event == null) return const SizedBox.shrink();

                    final destination = event.destination;

                    final List<String> frontImages = destination.extraInfo.backdropPath;

                    final String imageUrl = frontImages.isNotEmpty
                        ? "$API_URL${frontImages.first}"
                        : "";
                    return Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: _bookedEventCard(
                        context,
                        imageAsset: imageUrl,
                        title: destination.placeName,
                        statusText: "Coming on ${event.fromDate}",
                        organizerText: "Booked for ${booking.totalPeople} people",
                        priceText: "Rs ${booking.totalPrice}",
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            RouteName.eventDetailScreen,
                            arguments: event,
                          );
                        },
                      ),
                    );
                  }),

                  SizedBox(height: 12.h),
                  ViewAllRow(
                    firstText: "Completed Events",
                    onPressed: () {},
                    isViewAll: false,
                  ),
                  SizedBox(height: 8.h),

                  ...completed.map((booking) {
                    final event = eventMap[booking.eventId];
                    if (event == null) return const SizedBox.shrink();

                    final destination = event.destination;
                    final List<String> frontImages = destination.extraInfo.backdropPath;

                    final String imageUrl = frontImages.isNotEmpty
                        ? "$API_URL${frontImages.first}"
                        : "";

                    return Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: _bookedEventCard(
                        context,
                        imageAsset: imageUrl,
                        title: destination.placeName,
                        statusText: "Completed",
                        organizerText: "Booked for ${booking.totalPeople} people",
                        priceText: "Rs ${booking.totalPrice}",
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            RouteName.eventDetailScreen,
                            arguments: event,
                          );
                        },
                      ),
                    );
                  }),
                ],
              ),
            ],
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
              child: Image.network(
                imageAsset,
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
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
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
  TextStyle _headingStyle() {
    return TextStyle(fontSize: 42.sp, height: 1.2);
  }
}
