import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traveltales/core/ui/resources/theme/dimens.dart';

class SearchFilterBar extends StatelessWidget {
  final String hintText;

  const SearchFilterBar({
    this.hintText = "Search Destination",
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: compactDimens.medium3,
      padding: EdgeInsets.symmetric(horizontal: compactDimens.small3),
      decoration: BoxDecoration(
        color: Color(0xFFEDF0F7),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search,
          ),
      const SizedBox(width: 10),
       Expanded(
          child: Text(
            hintText,
            style: TextStyle(
              color: Colors.black45,
              fontSize: 14,
            ),
          ),),
          IconButton(
            onPressed: (){},
            icon: const Icon(
              Icons.tune,

            ),
          ),
        ]
      ),
    );
  }
}
