import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traveltales/core/route_config/route_names.dart';
import 'package:traveltales/core/ui/resources/theme/appColors.dart';
import 'package:traveltales/core/ui/resources/theme/dimens.dart';

class DestinationCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String location;
  final bool isNetworkImage;
  final int destinationId;

  const DestinationCard({
    required this.imagePath,
    required this.title,
    required this.location,
    this.isNetworkImage = false,
    required this.destinationId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 12.w),
      padding: EdgeInsets.all(0),
      width: 155.w,
      decoration: BoxDecoration(
        color: AppColors.getContainerBoxColor(context),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () {
          Navigator.pushNamed(
            context,
            RouteName.destinationDetailScreen,
            arguments: destinationId,
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: SizedBox(
                width: double.infinity,
                height: 180.h,
                child: isNetworkImage && imagePath.isNotEmpty
                    ? Image.network(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/Annapurna.png',
                      fit: BoxFit.cover,
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: SizedBox(
                        height: 20.h,
                        width: 20.w,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
                )
                    : Image.asset(
                  imagePath.isNotEmpty
                      ? imagePath
                      : 'assets/images/Annapurna.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/Annapurna.png',
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: compactDimens.small2,
                right: compactDimens.small1,
                top: compactDimens.small1
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    style: const TextStyle(
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}