import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traveltales/api/api.dart';
import 'package:traveltales/api/bookingAPI.dart';
import 'package:traveltales/core/model/booking_model.dart';
import 'package:traveltales/core/model/event_model.dart';
import 'package:traveltales/core/route_config/route_names.dart';
import 'package:traveltales/core/ui/components/shimmerView.dart';
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
    _loadData();
  }


  void _loadData() {
    _bookingsFuture = _bookingService.getMyBookings();
    _eventsFuture = getAllEvents();
  }

  Future<void> _refreshData() async {
    setState(() {
      _loadData();
    });
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool _shouldShowInBookedHome(Booking booking) {
    final status = booking.status.toLowerCase().trim();
    return status != "pending" && status != "failed";
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

  Widget _emptySection(String text) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: AppColors.getContainerBoxColor(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.08),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13.sp,
          color: AppColors.getSmallTextColor(context),
        ),
      ),
    );
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
                  ShimmerView(width: 140.w, height: 12.h, radius: 8),
                  SizedBox(height: 8.h),
                  ShimmerView(width: 110.w, height: 12.h, radius: 8),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            ShimmerView(width: 54.w, height: 24.h, radius: 999),
          ],
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: compactDimens.small3),
      children: [
        SizedBox(height: 12.h),
        ShimmerView(width: 190.w, height: 34.h, radius: 14),
        SizedBox(height: 10.h),
        Row(
          children: [
            ShimmerView(width: 140.w, height: 34.h, radius: 14),
            SizedBox(width: compactDimens.small1),
            ShimmerView(
              width: compactDimens.homeScreenImageSize,
              height: 34.h,
              radius: 16,
            ),
          ],
        ),
        SizedBox(height: 16.h),
        ShimmerView(width: 120.w, height: 18.h, radius: 8),
        SizedBox(height: 8.h),
        card(),
        SizedBox(height: 8.h),
        card(),
        SizedBox(height: 16.h),
        ShimmerView(width: 120.w, height: 18.h, radius: 8),
        SizedBox(height: 8.h),
        card(),
      ],
    );
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
            return _buildLoadingShimmer();
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Failed to load bookings"));
          }

          final bookings = (snapshot.data![0] as List<Booking>)
              .where(_shouldShowInBookedHome)
              .toList();
          final events = snapshot.data![1] as List<Event>;

          final Map<int, Event> eventMap = {
            for (final event in events) event.eventId: event,
          };
          final today = _dateOnly(DateTime.now());

          final upcoming = bookings.where((booking) {
            final event = eventMap[booking.eventId];
            if (event == null) return false;

            return !_dateOnly(event.toDate).isBefore(today);
          }).toList();

          final completed = bookings.where((booking) {
            final event = eventMap[booking.eventId];
            if (event == null) return false;

            return _dateOnly(event.toDate).isBefore(today);
          }).toList();
          upcoming.sort((a, b) {
            final eventA = eventMap[a.eventId]!;
            final eventB = eventMap[b.eventId]!;
            return eventA.fromDate.compareTo(eventB.fromDate);
          });
          completed.sort((a, b) {
            final eventA = eventMap[a.eventId]!;
            final eventB = eventMap[b.eventId]!;
            return eventB.toDate.compareTo(eventA.toDate);
          });

          return RefreshIndicator(
            backgroundColor: Colors.white,
            onRefresh: _refreshData,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding:
              EdgeInsets.symmetric(horizontal: compactDimens.small3),
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

                    if (upcoming.isEmpty)
                      _emptySection("No upcoming events booked yet.")
                    else
                      ...upcoming.map((booking) {
                        final event = eventMap[booking.eventId];
                        if (event == null) return const SizedBox.shrink();

                        final destination = event.destination;

                        final List<String> frontImages =
                            destination.extraInfo.backdropPath;

                        final String imageUrl = frontImages.isNotEmpty
                            ? "$API_URL${frontImages.first}"
                            : "";

                        return Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: _bookedEventCard(
                            context,
                            imageAsset: imageUrl,
                            title: destination.placeName,
                            statusText:
                                "Coming on ${_formatEventDate(event.fromDate)}",
                            organizerText:
                                "Booked for ${booking.totalPeople} people",
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

                    if (completed.isEmpty)
                      _emptySection("No completed events yet.")
                    else
                      ...completed.map((booking) {
                        final event = eventMap[booking.eventId];
                        if (event == null) return const SizedBox.shrink();

                        final destination = event.destination;

                        final List<String> frontImages =
                            destination.extraInfo.backdropPath;

                        final String imageUrl = frontImages.isNotEmpty
                            ? "$API_URL${frontImages.first}"
                            : "";

                        return Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: _bookedEventCard(
                            context,
                            imageAsset: imageUrl,
                            title: destination.placeName,
                            statusText:
                                "Completed on ${_formatEventDate(event.toDate)}",
                            organizerText:
                                "Booked for ${booking.totalPeople} people",
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

                  _infoRow(
                      Icons.check_circle_outline, statusText, Colors.green),

                  SizedBox(height: 4.h),

                  _infoRow(Icons.verified_outlined, organizerText,
                      Colors.green),
                ],
              ),
            ),

            SizedBox(width: 10.w),

            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 10.w, vertical: 6.h),
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
