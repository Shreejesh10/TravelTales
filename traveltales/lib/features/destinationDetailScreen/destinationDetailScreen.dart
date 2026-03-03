import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  @override
  Widget build(BuildContext context) {
    double screenHeight = 1.sh;
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

            child: Image.asset('assets/images/Mustang.png', fit: BoxFit.cover),
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
                              child: Image.asset(
                                'assets/images/Annapurna.png',
                                width: 135.w,
                                height: 170.w,
                                fit: BoxFit.cover,
                              ),
                            ),
                    
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Muktinath, Mustang',
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
                                        "Mustang, Nepal",
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.getSmallTextColor(context),
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
                                          value: '6 Hours',
                                          label: 'Duration',
                                          onTap: () {},
                                          iconColor: const Color(0xFF2ECC71),
                                        ),
                                      ),
                                      8.w.horizontalSpace,
                                      Expanded(
                                        child: _statCard(
                                          icon: Icons.height,
                                          value: '3400m',
                                          label: 'Elevation',
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
                          firstText: "About This Place",
                          onPressed: () {},
                          isViewAll: false,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          "The Everest Base Camp trek is the quintessential high-altitude adventure, taking you through the heart of the Khumbu region. This iconic journey offers breathtaking views of the world's highest peaks, including Everest, Lhotse, and Nuptse. You'll traverse ancient Sherpa villages and vibrant monasteries before emerging onto the stark, beautiful alpine terrain",
                          style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                        ),
                        SizedBox(height: 8.h),
                        _bestSeasonCard(
                          seasonText: "March–May, September–November",
                        ),
                    
                        SizedBox(height: 10.h),
                        _infoRow(
                          mainText: "Attraction: ",
                          contentText: 'Aryaghat, Tengboche Monastery',
                        ),
                        _infoRow(
                          mainText: "Transportation: ",
                          contentText: 'Taxi or bus',
                        ),
                        _infoRow(
                          mainText: "Accomodation: ",
                          contentText: 'Hotels in Kathmandu',
                        ),
                        _infoRow(
                          mainText: "Safety Tips: ",
                          contentText: 'Dress modestly, Non-Hindus restricted',
                        ),
                        _infoRow(
                          mainText: "Highlights: ",
                          contentText:
                              'Religious significance, Bagmati River cremations',
                        ),
                    
                        ViewAllRow(
                          firstText: SharedRes.strings(context).recommendedForYou,
                          onPressed: (){
                            Navigator.pushNamed(
                                context,
                                RouteName.viewAllScreen,
                                arguments: SharedRes.strings(context).recommendedForYou
                            );
                          },
                    
                        ),
                    
                        SizedBox(
                          height: 220.h,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              DestinationCard(
                                imagePath: 'assets/images/Bouddha.png',
                                title: 'Bouddhanath Stupa',
                                location: 'Kathmandu, Nepal',
                              ),
                              DestinationCard(
                                imagePath: 'assets/images/Annapurna.png',
                                title: 'Annapurna Base Camp',
                                location: 'Annapurna, Nepal',
                              ),
                              DestinationCard(
                                imagePath: 'assets/images/Pathivara.png',
                                title: 'Pathivara Temple',
                                location: 'Mechi, Nepal',
                              ),
                            ],
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
      ),
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
                "Best Season",
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
