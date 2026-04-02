import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:traveltales/core/ui/resources/theme/appColors.dart';

class ShimmerView extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final EdgeInsetsGeometry? margin;

  const ShimmerView({
    super.key,
    required this.width,
    required this.height,
    this.radius = 12,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Shimmer.fromColors(
        baseColor: AppColors.getShimmerBaseColor(context),
        highlightColor: AppColors.getShimmerHighlightColor(context),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.getContainerBoxColor(context),
            borderRadius: BorderRadius.circular(radius.r),
          ),
        ),
      ),
    );
  }
}
