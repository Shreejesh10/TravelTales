import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traveltales/api/api.dart';
import 'package:traveltales/api/bookmarkAPI.dart';
import 'package:traveltales/api/destinationAPI.dart';
import 'package:traveltales/core/model/destination_model.dart';
import 'package:traveltales/core/route_config/route_names.dart';
import 'package:traveltales/core/ui/components/app_flushbar.dart';
import 'package:traveltales/core/ui/components/destinationCard.dart';
import 'package:traveltales/core/ui/components/shimmerView.dart';
import 'package:traveltales/core/ui/components/viewAllRow.dart';
import 'package:traveltales/core/ui/localization/sharedRes.dart';
import 'package:traveltales/core/ui/resources/theme/appColors.dart';

class DestinationDetailScreen extends StatefulWidget {
  const DestinationDetailScreen({super.key});

  @override
  State<DestinationDetailScreen> createState() =>
      _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends State<DestinationDetailScreen> {
  Future<Destination?>? destinationFuture;
  late Future<List<Destination>> recommendedFuture;
  bool _isLoaded = false;
  bool isDescriptionExpanded = false;
  bool isSafetyTipsExpanded = false;
  bool isHighlightsExpanded = false;
  bool isBookmarked = false;
  bool isBookmarkLoading = false;
  int? currentDestinationId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isLoaded) return;
    _isLoaded = true;

    recommendedFuture = getRecommendedDestinations();

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is int) {
      currentDestinationId = args;
      destinationFuture = getDestinationByID(args);
      _loadBookmarkStatus(args);
    } else {
      destinationFuture = Future.value(null);
    }
  }
  Future<void> _loadBookmarkStatus(int destinationId) async {
    try {
      final result = await checkBookmark(destinationId);
      setState(() {
        isBookmarked = result;
      });
    } catch (e) {
      print("Bookmark load error: $e");
    }
  }

  Future<void> _toggleBookmark(int destinationId) async {
    if (isBookmarkLoading) return;

    setState(() => isBookmarkLoading = true);

    try {
      if (isBookmarked) {
        await removeBookmark(destinationId);
        isBookmarked = false;
        AppFlushbar.error(context, "Bookmark removed");
      } else {
        await addBookmark(destinationId);
        isBookmarked = true;
        AppFlushbar.success(context, "Bookmark added");
      }
    } catch (e) {
      AppFlushbar.errorFrom(
        context,
        e,
        fallbackMessage: "Couldn't update bookmark. Please try again.",
      );
    }

    setState(() => isBookmarkLoading = false);
  }

  @override
  Widget build(BuildContext context) {
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
        actions: [
          Padding(
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
                  onPressed: () => _toggleBookmark(currentDestinationId!),
                  icon: Icon(
                    isBookmarked
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    color: isBookmarked ? Colors.orange : Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<Destination?>(
        future: destinationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingShimmer();
          }

          if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text("Failed to load destination"));
          }

          final destination = snapshot.data!;
          final extra = destination.extraInfo;

          final backdrop = extra.backdropPath.isNotEmpty
              ? extra.backdropPath.first
              : "";

          final frontImage = extra.frontImagePath.isNotEmpty
              ? extra.frontImagePath.first
              : "";
          return _buildPage(destination, backdrop, frontImage);
        },
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    final screenHeight = 1.sh;

    Widget recommendationCard() {
      return Container(
        width: 170.w,
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerView(width: double.infinity, height: 140.h, radius: 16),
            SizedBox(height: 12.h),
            ShimmerView(width: 110.w, height: 14.h, radius: 8),
            SizedBox(height: 8.h),
            ShimmerView(width: 80.w, height: 12.h, radius: 8),
          ],
        ),
      );
    }

    return Stack(
      children: [
        ShimmerView(
          width: double.infinity,
          height: screenHeight * 0.3,
          radius: 0,
        ),
        Padding(
          padding: EdgeInsets.only(top: screenHeight * 0.25),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.getDetailBackgroundColor(context),
              borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
            ),
            child: ListView(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerView(width: 135.w, height: 170.h, radius: 12),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerView(width: 140.w, height: 18.h, radius: 8),
                          SizedBox(height: 10.h),
                          ShimmerView(width: 110.w, height: 12.h, radius: 8),
                          SizedBox(height: 12.h),
                          Row(
                            children: [
                              Expanded(
                                child: ShimmerView(
                                  width: double.infinity,
                                  height: 82.h,
                                  radius: 14,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: ShimmerView(
                                  width: double.infinity,
                                  height: 82.h,
                                  radius: 14,
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
                ShimmerView(width: 130.w, height: 18.h, radius: 8),
                SizedBox(height: 8.h),
                ShimmerView(width: double.infinity, height: 70.h, radius: 12),
                SizedBox(height: 10.h),
                ShimmerView(width: double.infinity, height: 56.h, radius: 12),
                SizedBox(height: 10.h),
                ShimmerView(width: double.infinity, height: 18.h, radius: 8),
                SizedBox(height: 8.h),
                ShimmerView(width: double.infinity, height: 18.h, radius: 8),
                SizedBox(height: 8.h),
                ShimmerView(width: double.infinity, height: 18.h, radius: 8),
                SizedBox(height: 16.h),
                ShimmerView(width: 150.w, height: 18.h, radius: 8),
                SizedBox(height: 12.h),
                SizedBox(
                  height: 220.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    separatorBuilder: (_, __) => SizedBox(width: 12.w),
                    itemBuilder: (_, __) => recommendationCard(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPage(
    Destination destination,
    String backdrop,
    String frontImage,
  ) {
    double screenHeight = 1.sh;

    return Stack(
      children: [
        SizedBox(
          height: screenHeight * 0.3,
          width: double.infinity,

          child: Image.network("$API_URL$backdrop", fit: BoxFit.cover),
        ),
        Padding(
          padding: EdgeInsets.only(top: screenHeight * 0.25),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(12.w, 18.h, 12.w, 18.h),
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
                            child: frontImage.isNotEmpty
                                ? Image.network(
                                    "$API_URL$frontImage",
                                    height: 182.h,
                                    width: 138.w,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) {
                                      return Image.asset(
                                        'assets/images/Annapurna.png',
                                        height: 182.h,
                                        width: 138.w,
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  )
                                : Image.asset(
                                    'assets/images/Annapurna.png',
                                    height: 182.h,
                                    width: 138.w,
                                    fit: BoxFit.cover,
                                  ),
                          ),

                          SizedBox(width: 14.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  destination.placeName,
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                    height: 1.25,
                                  ),
                                ),

                                8.h.verticalSpace,
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 14.sp,
                                      color: AppColors.getIconColors(context),
                                    ),
                                    4.w.horizontalSpace,
                                    Expanded(
                                      child: Text(
                                        destination.location,
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.getSmallTextColor(
                                            context,
                                          ),
                                          height: 1.35,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 16.h),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _statCard(
                                        icon: Icons.schedule,
                                        value: destination.extraInfo.duration,
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
                                        icon: Icons.height,
                                        value:
                                            destination
                                                .extraInfo
                                                .elevation
                                                .isNotEmpty
                                            ? '${destination.extraInfo.elevation.first}m'
                                            : 'N/A',
                                        label: SharedRes.strings(
                                          context,
                                        ).elevation,
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
                      SizedBox(height: 18.h),
                      ViewAllRow(
                        firstText: SharedRes.strings(context).aboutThePlace,
                        onPressed: () {},
                        isViewAll: false,
                      ),
                      SizedBox(height: 8.h),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            destination.description,
                            maxLines: isDescriptionExpanded ? null : 6,
                            overflow: isDescriptionExpanded
                                ? TextOverflow.visible
                                : TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.5.sp,
                              color: Colors.grey,
                              height: 1.45,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isDescriptionExpanded = !isDescriptionExpanded;
                              });
                            },
                            child: Text(
                              isDescriptionExpanded ? "See less" : "See more",
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.getIconColors(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 14.h),
                      _bestSeasonCard(
                        seasonText: destination.extraInfo.bestTimeToVisit,
                      ),

                      SizedBox(height: 16.h),
                      _infoRow(
                        mainText: SharedRes.strings(context).attraction,
                        contentText: destination.extraInfo.attractions.join(
                          ", ",
                        ),
                      ),
                      _infoRow(
                        mainText: SharedRes.strings(context).transportation,
                        contentText: destination.extraInfo.transportation,
                      ),
                      _infoRow(
                        mainText: SharedRes.strings(context).accommodation,
                        contentText: destination.extraInfo.accommodation,
                      ),
                      SizedBox(height: 4.h),
                      _contentBox(
                        context,
                        heading: SharedRes.strings(context).safetyTips,
                        icon: Icons.health_and_safety_outlined,
                        isExpanded: isSafetyTipsExpanded,
                        onTap: () {
                          setState(() {
                            isSafetyTipsExpanded = !isSafetyTipsExpanded;
                          });
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: destination.extraInfo.safetyTips.isNotEmpty
                              ? destination.extraInfo.safetyTips
                                  .map((tip) => _bulletItem(tip))
                                  .toList()
                              : [_bulletItem("No safety tips available")],
                        ),
                      ),
                      SizedBox(height: 10.h),
                      _contentBox(
                        context,
                        heading: SharedRes.strings(context).highlights,
                        icon: Icons.auto_awesome_outlined,
                        isExpanded: isHighlightsExpanded,
                        onTap: () {
                          setState(() {
                            isHighlightsExpanded = !isHighlightsExpanded;
                          });
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: destination.extraInfo.highlights.isNotEmpty
                              ? destination.extraInfo.highlights
                                  .map((highlight) => _bulletItem(highlight))
                                  .toList()
                              : [_bulletItem("No highlights available")],
                        ),
                      ),

                      ViewAllRow(
                        firstText: SharedRes.strings(context).recommendedForYou,
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            RouteName.viewAllScreen,
                            arguments: SharedRes.strings(
                              context,
                            ).recommendedForYou,
                          );
                        },
                      ),

                      SizedBox(height: 8.h),
                      SizedBox(
                        height: 220.h,
                        child: FutureBuilder(
                          future: recommendedFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: 3,
                                separatorBuilder: (_, __) => SizedBox(width: 12.w),
                                itemBuilder: (_, __) => Container(
                                  width: 170.w,
                                  padding: EdgeInsets.all(10.w),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18.r),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ShimmerView(
                                        width: double.infinity,
                                        height: 140.h,
                                        radius: 16,
                                      ),
                                      SizedBox(height: 12.h),
                                      ShimmerView(
                                        width: 110.w,
                                        height: 14.h,
                                        radius: 8,
                                      ),
                                      SizedBox(height: 8.h),
                                      ShimmerView(
                                        width: 80.w,
                                        height: 12.h,
                                        radius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            if (snapshot.hasError ||
                                !snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return const Center(
                                child: Text("No recommendations found"),
                              );
                            }

                            final recommendedList = snapshot.data!
                                .where(
                                  (item) =>
                                      item.destinationId !=
                                      destination.destinationId,
                                )
                                .toList();

                            if (recommendedList.isEmpty) {
                              return const Center(
                                child: Text("No recommendations found"),
                              );
                            }
                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: recommendedList.length,
                              itemBuilder: (context, index) {
                                final item = recommendedList[index];

                                final image =
                                    item.extraInfo.frontImagePath.isNotEmpty
                                    ? item.extraInfo.frontImagePath.first
                                    : item.extraInfo.photos.isNotEmpty
                                    ? item.extraInfo.photos.first
                                    : "";
                                return DestinationCard(
                                  imagePath: image.isNotEmpty
                                      ? "$API_URL$image"
                                      : "",
                                  title: item.placeName,
                                  location: item.location,
                                  isNetworkImage: image.isNotEmpty,
                                  destinationId: item.destinationId,
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoRow({required String mainText, required String contentText}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mainText,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            contentText,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.5.sp,
              color: AppColors.getSmallTextColor(context),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bulletItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 2.h),
            height: 18.h,
            width: 18.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(color: const Color(0xFF22C55E)),
              color: const Color(0xFFECFDF5),
            ),
            child: const Icon(
              Icons.check,
              size: 12,
              color: Color(0xFF22C55E),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13.sp,
                height: 1.35,
                color: AppColors.getSmallTextColor(context),
              ),
            ),
          ),
        ],
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
            crossFadeState:
                isExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
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

  Widget _bestSeasonCard({required String seasonText}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
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
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.lightBlue.withOpacity(0.06),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.calendar_month,
              size: 22.sp,
              color: AppColors.getIconColors(context),
            ),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                SharedRes.strings(context).bestSeason,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              Text(
                seasonText,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                  height: 1.35,
                ),
              ),
            ],
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
    required iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              offset: const Offset(0, 6),
              color: Colors.black.withOpacity(0.1),
            ),
          ],
          color: AppColors.getContainerBoxColor(context),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20.sp, color: iconColor),
            SizedBox(height: 10.h),
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
}
