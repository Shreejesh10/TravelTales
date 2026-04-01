import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traveltales/api/api.dart';
import 'package:traveltales/core/model/booking_model.dart';
import 'package:traveltales/core/model/event_model.dart';
import 'package:traveltales/core/route_config/route_names.dart';
import 'package:traveltales/core/ui/components/button.dart';
import 'package:traveltales/core/ui/components/functions/dateTime/app_formatters.dart';
import 'package:traveltales/core/ui/components/shimmerView.dart';
import 'package:traveltales/core/ui/localization/sharedRes.dart';
import 'package:traveltales/core/ui/resources/theme/dimens.dart';
import 'package:traveltales/api/bookingAPI.dart';
import '../../core/ui/components/actionDialogBox.dart';
import '../../core/ui/components/viewAllRow.dart';
import '../../core/ui/resources/theme/appColors.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final BookingApi _bookingService = BookingApi();
  late Future<List<Event>> _eventsFuture;
  late Future<List<Booking>> _bookingsFuture;

  String? currentCompanyId;

  @override
  void initState() {
    super.initState();
    _eventsFuture = getAllEvents();
    _bookingsFuture = _bookingService.getMyBookings();
    _loadCompanyId();
  }
  Future<void> _loadCompanyId() async{
    currentCompanyId = await storage.read(key: 'user_id');
    setState(() {

    });
  }

  Future<void> _reloadEvents() async {
    setState(() {
      _eventsFuture = getAllEvents();
      _bookingsFuture = _bookingService.getMyBookings();
    });
  }
  Future<void> _deleteEvent(int eventId) async {
    await showAppActionDialog(
      context: context,
      title: "Delete Event",
      isDestructive: true,
      confirmText: "Yes",
      cancelText: "No",
      contentWidget: [
        Text(
          "Are you sure you want to delete this event?",
          style: TextStyle(fontSize: 14.sp),
        ),
      ],
      onConfirm: () async {
        try {
          await deleteEvent(eventId);

          _reloadEvents();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Event deleted successfully")),
            );
          }
        } catch (e) {
          print("Delete failed: $e");

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Failed to delete event")),
            );
          }
        }
      },
    );
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
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
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerView(width: double.infinity, height: 180.h, radius: 14),
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerView(width: 70.w, height: 24.h, radius: 999),
                  SizedBox(height: 14.h),
                  ShimmerView(width: 160.w, height: 16.h, radius: 8),
                  SizedBox(height: 14.h),
                  ShimmerView(width: double.infinity, height: 84.h, radius: 18),
                  SizedBox(height: 16.h),
                  ShimmerView(width: double.infinity, height: 18.h, radius: 8),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: compactDimens.small3,
        vertical: 12.h,
      ),
      children: [
        card(),
        SizedBox(height: 16.h),
        card(),
        SizedBox(height: 8.h),
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
            icon: Icon(Icons.notifications_none, size: compactDimens.medium1),
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          _eventsFuture,
          _bookingsFuture,
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
                    const Icon(Icons.error_outline, size: 42),
                    SizedBox(height: 12.h),
                    Text(
                      "Failed to load events",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    AppButton(
                      text: "Retry",
                      onPressed: _reloadEvents,
                    ),
                  ],
                ),
              ),
            );
          }

          final allEvents = snapshot.data![0] as List<Event>;
          final myBookings = snapshot.data![1] as List<Booking>;

          final bookedEventIds = myBookings
              .map((booking) => booking.eventId)
              .toSet();

          final events = allEvents
              .where((event) => !bookedEventIds.contains(event.eventId))
              .toList();
          final today = _dateOnly(DateTime.now());
          final availableEvents =
              events
                  .where((event) => !_dateOnly(event.toDate).isBefore(today))
                  .toList();
          final expiredEvents =
              events
                  .where((event) => _dateOnly(event.toDate).isBefore(today))
                  .toList();
          availableEvents.sort((a, b) => a.fromDate.compareTo(b.fromDate));
          expiredEvents.sort((a, b) => b.toDate.compareTo(a.toDate));

          if (availableEvents.isEmpty && expiredEvents.isEmpty) {
            return Center(
              child: Text(
                "No events found",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _reloadEvents,
            backgroundColor: Colors.white,
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: compactDimens.small3,
                vertical: 12.h,
              ),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                if (availableEvents.isNotEmpty) ...[
                  ...availableEvents.map((event) => Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: _buildEventCard(event),
                  )),
                ] else ...[
                  _emptySection("No active events available right now."),
                ],
                if (expiredEvents.isNotEmpty) ...[
                  SizedBox(height: availableEvents.isNotEmpty ? 8.h : 0),
                  const ViewAllRow(
                    firstText: "Expired Events",
                    onPressed: null,
                    isViewAll: false,
                  ),
                  SizedBox(height: 8.h),
                  ...expiredEvents.map((event) => Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: _buildEventCard(event, isExpired: true),
                  )),
                ] else ...[
                  SizedBox(height: 12.h),
                  const ViewAllRow(
                    firstText: "Expired Events",
                    onPressed: null,
                    isViewAll: false,
                  ),
                  SizedBox(height: 8.h),
                  _emptySection("No expired events to show."),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventCard(Event event, {bool isExpired = false}) {
    final destination = event.destination;

    print("currentCompanyId: $currentCompanyId");
    print("event.companyUserId: ${event.companyUserId}");

    final List<String> frontImages = destination.extraInfo.backdropPath;

    final String imageUrl = frontImages.isNotEmpty
        ? "$API_URL${frontImages.first}"
        : "";

    return eventCard(
      imageUrl: imageUrl,
      title: destination.placeName,
      difficulty: destination.extraInfo.difficultyLevel,
      elevation: destination.extraInfo.elevation.join(", "),
      duration: destination.extraInfo.duration,
      location: destination.location,
      description: event.eventDescription,
      addedText: AppFormatters.addedText(event.createdAt),
      difficultyColor: AppColors.difficultyColor(
        destination.extraInfo.difficultyLevel,
      ),
      difficultyBgColor: AppColors.difficultyBgColor(
        destination.extraInfo.difficultyLevel,
      ),
      isExpired: isExpired,
      isMyEvent: currentCompanyId == event.companyUserId.toString(),
      onDeleteTap: () => _deleteEvent(event.eventId),
      onShareTap: () {},
      onViewDetailsTap: () {
        Navigator.pushNamed(
          context,
          RouteName.eventDetailScreen,
          arguments: event,
        );
      },
    );
  }

  Widget eventCard({
    required String imageUrl,
    required String title,
    required String difficulty,
    required String elevation,
    required String duration,
    required String location,
    required String description,
    required String addedText,
    required Color difficultyColor,
    required Color difficultyBgColor,
    required bool isExpired,
    required bool isMyEvent,
    VoidCallback? onShareTap,
    VoidCallback? onViewDetailsTap,
    VoidCallback? onDeleteTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.getContainerBoxColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Stack(
              children: [
                SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          color: isExpired ? Colors.black.withOpacity(0.18) : null,
                          colorBlendMode:
                              isExpired ? BlendMode.darken : null,
                        )
                      : Container(
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.image, size: 42),
                        ),
                ),
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(isExpired ? 0.3 : 0.18),
                  ),
                ),
                if (isExpired)
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        "Expired",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  left: 18,
                  bottom: 18,
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: difficultyBgColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        difficulty,
                        style: TextStyle(
                          color: difficultyColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.route_outlined,
                      size: 16,
                      color: AppColors.getIconColors(context),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      elevation,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.getSmallTextColor(context),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Icon(
                      Icons.access_time_outlined,
                      size: 16,
                      color: AppColors.getIconColors(context),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      duration,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.getSmallTextColor(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 18,
                      color: AppColors.getIconColors(context),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        location,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.getContainerReverseBoxColor(context),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: Theme.of(context).dividerColor.withOpacity(0.08),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: AppColors.getSmallTextColor(context),
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        addedText,
                        style: TextStyle(
                          fontSize: 13,
                          color: isExpired
                              ? AppColors.getSmallTextColor(context)
                              : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isMyEvent)
                      Container(
                        height: 42,
                          width: 42,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.getBorderColor(context),
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: IconButton(
                          onPressed: onDeleteTap,
                          icon: const Icon(Icons.delete_outline, color: Colors.red,),
                        )
                      ),
                    if (isMyEvent) const SizedBox(width: 12),
                    Container(
                      height: 42,
                      width: 42,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.getBorderColor(context),
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: IconButton(
                        onPressed: onShareTap,
                        icon: Icon(
                          Icons.share_outlined,
                          size: 20,
                          color: AppColors.getIconColors(context),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    AppButton(
                      text: isExpired
                          ? "View Recap"
                          : SharedRes.strings(context).viewDetails,
                      onPressed: onViewDetailsTap,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
