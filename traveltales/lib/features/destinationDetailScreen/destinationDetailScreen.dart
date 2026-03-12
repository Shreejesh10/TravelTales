import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traveltales/api/api.dart';
import 'package:traveltales/core/model/destination_model.dart';
import 'package:traveltales/core/route_config/route_names.dart';
import 'package:traveltales/core/ui/components/destinationCard.dart';
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isLoaded) return;
    _isLoaded = true;

    recommendedFuture = getRecommendedDestinations();

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is int) {
      destinationFuture = getDestinationByID(args);
    } else {
      destinationFuture = Future.value(null);
    }
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
      ),
      body: FutureBuilder<Destination?>(
        future: destinationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
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
            padding: EdgeInsets.all(13.w),
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
                              height: 170.h,
                              width: 135.w,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) {
                                return Image.asset(
                                  'assets/images/Annapurna.png',
                                  height: 170.h,
                                  width: 135.w,
                                  fit: BoxFit.cover,
                                );
                              },
                            )
                                : Image.asset(
                              'assets/images/Annapurna.png',
                              height: 170.h,
                              width: 135.w,
                              fit: BoxFit.cover,
                            ),
                          ),

                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  destination.placeName,
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
                                    Text(
                                      destination.location,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.getSmallTextColor(
                                          context,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                8.h.verticalSpace,
                                SizedBox(height: 4.h),
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
                                        value: destination.extraInfo.elevation.isNotEmpty
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
                            destination.description,
                            maxLines: isDescriptionExpanded ? null : 6,
                            overflow: isDescriptionExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
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
                      SizedBox(height: 8.h),
                      _bestSeasonCard(
                        seasonText: destination.extraInfo.bestTimeToVisit,
                      ),

                      SizedBox(height: 10.h),
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
                      _infoRow(
                        mainText: SharedRes.strings(context).safetyTips,
                        contentText: destination.extraInfo.safetyTips.join(
                          ", ",
                        ),
                      ),
                      _infoRow(
                        mainText: SharedRes.strings(context).highlights,
                        contentText: destination.extraInfo.highlights.join(
                          ", ",
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

                      SizedBox(
                        height: 220.h,
                        child: FutureBuilder(
                          future: recommendedFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }

                            if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                              return const Center(child: Text("No recommendations found"));
                            }

                            final recommendedList = snapshot.data!
                                .where((item) => item.destinationId != destination.destinationId)
                                .toList();

                            if (recommendedList.isEmpty) {
                              return const Center(child: Text("No recommendations found"));
                            }
                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: recommendedList.length,
                              itemBuilder: (context, index){
                                final item = recommendedList[index];

                                final image =
                                item.extraInfo.frontImagePath.isNotEmpty
                                    ? item.extraInfo.frontImagePath.first
                                    : item.extraInfo.photos.isNotEmpty
                                    ? item.extraInfo.photos.first
                                    : "";
                                return DestinationCard(
                                  imagePath: image.isNotEmpty ? "$API_URL$image" : "",
                                  title: item.placeName,
                                  location: item.location,
                                  isNetworkImage: image.isNotEmpty,
                                  destinationId: item.destinationId,
                                );
                              },
                            );
                          }
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
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mainText,
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
          ),
          6.w.horizontalSpace,
          Expanded(
            child: Text(
              contentText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.getSmallTextColor(context),
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bestSeasonCard({required String seasonText}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.getContainerBoxColor(context),
        borderRadius: BorderRadius.circular(12.r),
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
              size: 24.sp,
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
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
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
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
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
}
