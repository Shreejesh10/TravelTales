import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traveltales/core/ui/localization/sharedRes.dart';

class ViewAllRow extends StatefulWidget {
  final String firstText;
  final VoidCallback? onPressed;

  const ViewAllRow({
    super.key,
    this.firstText = "Recommended for You",
    this.onPressed
  });

  @override
  State<ViewAllRow> createState() => _ViewAllRowState();
}

class _ViewAllRowState extends State<ViewAllRow> {

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.firstText,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        TextButton(
          onPressed: widget.onPressed,
          child: Text(
              SharedRes.strings(context).viewAll,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 14.sp,
              )
          )
        ),
      ],
    );
  }
}
