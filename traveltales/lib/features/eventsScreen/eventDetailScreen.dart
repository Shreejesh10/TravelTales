import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:traveltales/api/api.dart';
import 'package:traveltales/api/bookingAPI.dart';
import 'package:traveltales/core/model/booking_model.dart';
import 'package:traveltales/core/model/event_model.dart';
import 'package:traveltales/core/route_config/route_names.dart';
import 'package:traveltales/core/ui/components/button.dart';
import 'package:traveltales/core/ui/components/functions/dateTime/app_formatters.dart';
import 'package:traveltales/core/ui/components/viewAllRow.dart';
import 'package:traveltales/core/ui/localization/sharedRes.dart';
import 'package:traveltales/core/ui/resources/theme/appColors.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;

  const EventDetailScreen({
    super.key,
    required this.event,
  });

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  final BookingApi _bookingService = BookingApi();
  final GlobalKey _eventDateKey = GlobalKey();
  final GlobalKey _checklistKey = GlobalKey();
  late Future<List<Booking>> _bookingsFuture;

  double screenHeight = 1.sh;
  bool isDescriptionExpanded = false;
  bool isEventDateExpanded = false;
  bool isChecklistExpanded = false;

  Event get event => widget.event;


  @override
  void initState() {
    super.initState();
    _bookingsFuture = _bookingService.getMyBookings();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSection(GlobalKey key) {
    final targetContext = key.currentContext;
    if (targetContext != null) {
      Future.delayed(const Duration(milliseconds: 260), () {
        if (!mounted) return;
        Scrollable.ensureVisible(
          targetContext,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          alignment: 0.12,
        );
      });
    }
  }

  String get bannerImageUrl =>
      "$API_URL${event.destination.extraInfo.backdropPath.first}";

  String get cardImageUrl =>
      "$API_URL${event.destination.extraInfo.frontImagePath.first}";

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }



  @override
  Widget build(BuildContext context) {
    screenHeight = 1.sh;


    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.all(8.h),
          child: Center(
            child: Container(
              height: 40.h,
              width: 40.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.leadingDetailPageColor,
              ),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          SizedBox(
            height: screenHeight * 0.3,
            width: double.infinity,
            child:
                Image.network(
              bannerImageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Container(
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: Icon(Icons.image_not_supported, size: 40),
                  ),
                );
              },
            )
          ),
          Padding(
            padding: EdgeInsets.only(top: screenHeight * 0.25),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.getDetailBackgroundColor(context),
                borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 25,
                    offset: const Offset(0, -8),
                    color: Colors.black.withOpacity(0.08),
                  ),
                ],
              ),
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12.r),
                              child: SizedBox(
                                height: 170.h,
                                width: 135.w,
                                child: Image.network(
                                  cardImageUrl,
                                  fit: BoxFit.cover,
                                )

                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event.title,
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  4.h.verticalSpace,
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 14.sp,
                                        color: AppColors.getIconColors(context),
                                      ),
                                      4.w.horizontalSpace,
                                      Expanded(
                                        child: Text(
                                          event.destination.location,
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w500,
                                            color:
                                            AppColors.getSmallTextColor(
                                              context,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  8.h.verticalSpace,
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _statCard(
                                          icon: Icons.schedule,
                                          value: AppFormatters.formatDuration(event.fromDate, event.toDate),
                                          label: SharedRes.strings(
                                            context,
                                          ).duration,
                                          onTap: () {},
                                          iconColor: const Color(0xFF2ECC71),
                                        ),
                                      ),
                                      8.w.horizontalSpace,
                                      Expanded(
                                        child: _statCard(
                                          icon: Icons.group_outlined,
                                          value:
                                          "${event.maxPeople}",
                                          label: SharedRes.strings(context)
                                              .maxPeople,
                                          onTap: () {},
                                          iconColor: const Color(0xFF2ECC71),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        ViewAllRow(
                          firstText: SharedRes.strings(context).aboutThePlace,
                          onPressed: () {},
                          isViewAll: false,
                        ),
                        SizedBox(height: 4.h),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.eventDescription.trim().isNotEmpty == true
                                  ? event.eventDescription
                                  : "No description available",
                              maxLines: isDescriptionExpanded ? null : 6,
                              overflow: isDescriptionExpanded
                                  ? TextOverflow.visible
                                  : TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.grey,
                                height: 1.4,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isDescriptionExpanded =
                                  !isDescriptionExpanded;
                                });
                              },
                              child: Text(
                                isDescriptionExpanded
                                    ? SharedRes.strings(context).seeLess
                                    : SharedRes.strings(context).seeMore,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.getIconColors(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        _fullDetailCard(
                          icon: Icons.verified_user_outlined,
                          value: SharedRes.strings(context).postedBy,
                          label:
                              "Unknown Company",
                          iconColor: AppColors.getIconColors(context),
                          onTap: () {},
                        ),
                        SizedBox(height: 12.h),
                        _fullDetailCard(
                          icon: Icons.calendar_today_outlined,
                          value: AppFormatters.formatFullDate(event.fromDate),
                          label: AppFormatters.formatTime(event.meetingTime),
                          iconColor: AppColors.getIconColors(context),
                          onTap: () {},
                        ),
                        SizedBox(height: 12.h),
                        _fullDetailCard(
                          icon: Icons.place,
                          value: SharedRes.strings(context).meetupPoint,
                          label: event.meetingPoint,
                          iconColor: AppColors.getIconColors(context),
                          onTap: () {},
                        ),
                        SizedBox(height: 12.h),
                        ViewAllRow(
                          firstText: SharedRes.strings(context).moreInformation,
                          onPressed: () {},
                          isViewAll: false,
                        ),
                        SizedBox(height: 4.h),
                        Container(
                          key: _eventDateKey,
                          child: _contentBox(
                            context,
                            heading: SharedRes.strings(context).eventDate,
                            icon: Icons.date_range,
                            isExpanded: isEventDateExpanded,
                            onTap: () {
                              final willExpand = !isEventDateExpanded;
                              setState(() {
                                isEventDateExpanded = willExpand;
                              });
                              if (willExpand) {
                                _scrollToSection(_eventDateKey);
                              }
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _fullDetailCard(
                                  icon: Icons.golf_course,
                                  value: SharedRes.strings(context).fromDate,
                                  label: AppFormatters.formatDate(event.fromDate),
                                  iconColor: Colors.green,
                                  onTap: () {},
                                ),
                                SizedBox(height: 8.h),
                                _fullDetailCard(
                                  icon: Icons.pin_end_outlined,
                                  value: SharedRes.strings(context).toDate,
                                  label: AppFormatters.formatDate(event.fromDate),
                                  iconColor: Colors.green,
                                  onTap: () {},
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Container(
                          key: _checklistKey,
                          child: _contentBox(
                            context,
                            heading:
                            SharedRes.strings(context).essentialChecklist,
                            icon: Icons.checklist,
                            isExpanded: isChecklistExpanded,
                            onTap: () {
                              final willExpand = !isChecklistExpanded;
                              setState(() {
                                isChecklistExpanded = willExpand;
                              });
                              if (willExpand) {
                                _scrollToSection(_checklistKey);
                              }
                            },
                            child: Column(
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
                          ),
                        ),
                        SizedBox(height: 12.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: FutureBuilder<List<Booking>>(
        future: _bookingsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox.shrink();

          final today = _dateOnly(DateTime.now());
          final isExpired = _dateOnly(event.toDate).isBefore(today);

          if (isExpired) {
            return const SizedBox.shrink();
          }

          final bookings = snapshot.data!;

          final alreadyBooked = bookings.any(
                (b) =>
            b.eventId == event.eventId &&
                (b.status == "pending" || b.status == "completed"),
          );

          if (alreadyBooked) {
            return const SizedBox.shrink();
          }

          return Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 18.h),
            child: _priceBottomBar(),
          );
        },
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
                    AppFormatters.formatPrice(event.price),
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
                onPressed: () {
                  Navigator.pushNamed(context, RouteName.eventBookingScreen, arguments: event);
                },
                text: SharedRes.strings(context).bookNow,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contentBox(
      BuildContext context, {
        required String heading,
        required bool isExpanded,
        required VoidCallback onTap,
        required Widget child,
        required IconData icon,
      }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
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
                  Icon(
                    icon,
                    size: 20,
                    color: AppColors.getIconColors(context),
                  ),
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
                  AnimatedRotation(
                    turns: isExpanded ? 0 : -0.5,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_up,
                      color: AppColors.getIconColors(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: isExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: child,
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
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
              border: Border.all(color: const Color(0xFF22C55E)),
              color: const Color(0xFFECFDF5),
            ),
            child: const Icon(
              Icons.check,
              size: 14,
              color: Color(0xFF22C55E),
            ),
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

  Widget _statCard({
    required IconData icon,
    required String value,
    required String label,
    required VoidCallback onTap,
    required Color iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20.sp, color: iconColor),
            SizedBox(height: 8.h),
            Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fullDetailCard({
    required IconData icon,
    required String value,
    required String label,
    required VoidCallback onTap,
    required Color iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, size: 20.sp, color: iconColor),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.getSmallTextColor(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
