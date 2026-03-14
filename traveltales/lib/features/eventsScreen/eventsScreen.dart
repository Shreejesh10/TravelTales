import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traveltales/api/api.dart';
import 'package:traveltales/core/model/event_model.dart';
import 'package:traveltales/core/route_config/route_names.dart';
import 'package:traveltales/core/ui/components/button.dart';
import 'package:traveltales/core/ui/components/functions/dateTime/app_formatters.dart';
import 'package:traveltales/core/ui/localization/sharedRes.dart';
import 'package:traveltales/core/ui/resources/theme/dimens.dart';
import '../../core/ui/resources/theme/appColors.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  late Future<List<Event>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _eventsFuture = getAllEvents();
  }

  Future<void> _reloadEvents() async {
    setState(() {
      _eventsFuture = getAllEvents();
    });
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
      body: FutureBuilder<List<Event>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
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

          final events = snapshot.data ?? [];

          if (events.isEmpty) {
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
            child: ListView.separated(
              padding: EdgeInsets.symmetric(
                horizontal: compactDimens.small3,
                vertical: 12.h,
              ),
              itemCount: events.length,
              separatorBuilder: (_, __) => SizedBox(height: 16.h),
              itemBuilder: (context, index) {
                final event = events[index];
                final destination = event.destination;

                final List<String> frontImages =
                    destination.extraInfo.backdropPath;

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
                  onShareTap: () {},
                  onViewDetailsTap: () {
                    Navigator.pushNamed(
                      context,
                      RouteName.eventDetailScreen,
                      arguments: event,
                    );
                  },
                );
              },
            ),
          );
        },
      ),
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
    VoidCallback? onShareTap,
    VoidCallback? onViewDetailsTap,
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
                  )
                      : Container(
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image, size: 42),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.18),
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
                        style: const TextStyle(fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
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
                      text: SharedRes.strings(context).viewDetails,
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