import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traveltales/core/ui/localization/sharedRes.dart';

class ViewAllRow extends StatelessWidget {
  final String firstText;
  final VoidCallback? onPressed;
  final bool isViewAll;

  const ViewAllRow({
    super.key,
    required this.firstText ,
    required this.onPressed,
    this.isViewAll = true

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
            fontWeight: FontWeight.w600,
          ),
        ),
        if(isViewAll)
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
