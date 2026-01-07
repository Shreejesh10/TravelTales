import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traveltales/core/ui/resources/theme/appColors.dart';
import 'package:traveltales/core/ui/resources/theme/dimens.dart';

class DestinationCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String location;

  const DestinationCard({
    required this.imagePath,
    required this.title,
    required this.location,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 12.w),
      height: 220.h,
      width: 145.w,
      decoration: BoxDecoration(
        color:Theme.of(context).brightness == Brightness.light
          ?  AppColors.containerBoxColor
          :  AppColors.darkContainerBoxColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: (){},
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: SizedBox(
                width: double.infinity,
                height: 180.h,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
                padding: EdgeInsets.only(left: compactDimens.small1, right: compactDimens.small1),
              child: Column(

                children: [
                  Text(
                    title,
                    maxLines: 1,

                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      overflow: TextOverflow.ellipsis,

                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14.sp,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          location,
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.grey[600],
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),

                ]
              ),
            )

          ],
        ),
      ),
    );
  }
}
