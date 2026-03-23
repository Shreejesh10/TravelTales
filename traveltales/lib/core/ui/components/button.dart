import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double height;
  final double? width;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.height = 40,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final bool isWeb = kIsWeb;

    return SizedBox(
      width: width,
      height: isWeb ? height : height.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              isWeb ? 12 : 12.r,
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isWeb ? 22 : 22.w,
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            fontSize: isWeb ? 16 : 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}