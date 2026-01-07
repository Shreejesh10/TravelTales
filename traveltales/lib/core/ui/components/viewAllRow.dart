import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traveltales/core/ui/localization/sharedRes.dart';

class ViewAllRow extends StatelessWidget {
  final String firstText;
  final VoidCallback? onPressed;

  const ViewAllRow({
    super.key,
    this.firstText = "Recommended for You",
    required this.onPressed
  });


  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          firstText,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        TextButton(
          onPressed: onPressed,
          child: Text(
              SharedRes.strings(context).viewAll,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 13.sp,
              )
          )
        ),
      ],
    );
  }
}
