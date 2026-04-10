import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traveltales/api/api.dart';
import 'package:traveltales/core/model/event_model.dart';
import 'package:traveltales/core/route_config/route_names.dart';
import 'package:traveltales/core/ui/components/button.dart';
import 'package:traveltales/core/ui/components/functions/dateTime/app_formatters.dart';
import 'package:traveltales/core/ui/components/viewAllRow.dart';
import 'package:traveltales/core/ui/resources/theme/appColors.dart';
import 'package:traveltales/core/ui/resources/theme/dimens.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  late Future<List<Event>> _myEventsFuture;

  @override
  void initState() {
    super.initState();
    _myEventsFuture = _loadMyEvents();
  }

  Future<List<Event>> _loadMyEvents() async {
    final userId = await storage.read(key: 'user_id');
    final companyUserId = int.tryParse(userId ?? '');

    if (companyUserId == null) return [];

    final events = await getAllEvents();
    final myEvents = events
        .where((event) => event.companyUserId == companyUserId)
        .toList();

    myEvents.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return myEvents;
  }

  Future<void> _reloadEvents() async {
    setState(() {
      _myEventsFuture = _loadMyEvents();
    });
    await _myEventsFuture;
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Widget _emptyState(String text) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(compactDimens.small3),
      children: [
        SizedBox(height: 120.h),
        Icon(
          Icons.event_busy_outlined,
          size: 52,
          color: AppColors.getIconColors(context),
        ),
        SizedBox(height: 12.h),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.getSmallTextColor(context),
          ),
        ),
      ],
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Events")),
      body: RefreshIndicator(
        onRefresh: _reloadEvents,
        backgroundColor: Colors.white,
        child: FutureBuilder<List<Event>>(
          future: _myEventsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(20.w),
                children: [
                  SizedBox(height: 120.h),
                  const Icon(Icons.error_outline, size: 42),
                  SizedBox(height: 12.h),
                  Text(
                    "Failed to load your events",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  AppButton(text: "Retry", onPressed: _reloadEvents),
                ],
              );
            }

            final events = snapshot.data ?? [];
            if (events.isEmpty) {
              return _emptyState("You have not posted any events yet.");
            }

            final today = _dateOnly(DateTime.now());
            final activeEvents =
                events
                    .where((event) => !_dateOnly(event.toDate).isBefore(today))
                    .toList()
                  ..sort((a, b) => a.fromDate.compareTo(b.fromDate));
            final expiredEvents =
                events
                    .where((event) => _dateOnly(event.toDate).isBefore(today))
                    .toList()
                  ..sort((a, b) => b.toDate.compareTo(a.toDate));

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: compactDimens.small3,
                vertical: 12.h,
              ),
              children: [
                if (activeEvents.isNotEmpty) ...[
                  ...activeEvents.map(
                    (event) => Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: _buildEventCard(event),
                    ),
                  ),
                ] else ...[
                  _emptySection("No active events posted right now."),
                ],
                SizedBox(height: activeEvents.isNotEmpty ? 8.h : 12.h),
                const ViewAllRow(
                  firstText: "Expired Events",
                  onPressed: null,
                  isViewAll: false,
                ),
                SizedBox(height: 8.h),
                if (expiredEvents.isNotEmpty)
                  ...expiredEvents.map(
                    (event) => Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: _buildEventCard(event, isExpired: true),
                    ),
                  )
                else
                  _emptySection("No expired events to show."),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEventCard(Event event, {bool isExpired = false}) {
    final destination = event.destination;
    final frontImages = destination.extraInfo.backdropPath;
    final imageUrl = frontImages.isNotEmpty
        ? "$API_URL${frontImages.first}"
        : "";

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.getContainerBoxColor(context),
        borderRadius: BorderRadius.circular(12.r),
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
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12.r),
              topRight: Radius.circular(12.r),
            ),
            child: Stack(
              children: [
                SizedBox(
                  height: 180.h,
                  width: double.infinity,
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          color: isExpired
                              ? Colors.black.withOpacity(0.18)
                              : null,
                          colorBlendMode: isExpired ? BlendMode.darken : null,
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
                    top: 14.h,
                    right: 14.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        "Expired",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  left: 18.w,
                  bottom: 18.h,
                  right: 18.w,
                  child: Text(
                    event.title.trim().isNotEmpty
                        ? event.title
                        : destination.placeName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        AppFormatters.addedText(event.createdAt),
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.getSmallTextColor(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AppButton(
                      text: isExpired ? "View Recap" : "View Details",
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          RouteName.eventDetailScreen,
                          arguments: event,
                        ).then((updated) {
                          if (updated == true && mounted) {
                            _reloadEvents();
                          }
                        });
                      },
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
