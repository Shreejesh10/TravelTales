import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traveltales/core/ui/resources/theme/appColors.dart';
import 'package:traveltales/core/ui/resources/theme/dimens.dart';

class SearchFilterBar extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;
  final VoidCallback? onTap;
  final bool isFilter;

  const SearchFilterBar({
    super.key,
    this.hintText = "Search Destination",
    this.onTap,
    this.controller,
    this.onChanged,
    this.isFilter = true,
    this.onFilterTap,
  });

  bool get _isTextField => controller != null;

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = kIsWeb || MediaQuery.of(context).size.width >= 700;

    final double barHeight = isWideScreen ? 48 : compactDimens.medium3;
    final double horizontalPadding = isWideScreen ? 16 : compactDimens.small3;
    final double borderRadius = isWideScreen ? 24 : 24.r;
    final double iconSize = isWideScreen ? 20 : 20;
    final double textSize = isWideScreen ? 14 : 14;

    final bar = Container(
      height: barHeight,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF0F7),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: const Color(0xFF0A2A4A),
            size: iconSize,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _isTextField
                ? TextField(
              style: TextStyle(
                color: const Color(0xFF0A2A4A),
                fontSize: textSize,

              ),
              controller: controller,
              onChanged: onChanged,
              autofocus: false,
              decoration: InputDecoration(

                hintText: hintText,
                hintStyle: TextStyle(
                  color: const Color(0xFF0A2A4A),
                  fontSize: textSize,
                ),
                border: InputBorder.none,
                isCollapsed: true,
                filled: false
              ),
            )
                : Text(
              hintText,
              style: TextStyle(
                color: const Color(0xFF0A2A4A),
                fontSize: textSize,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isFilter)
            IconButton(
              onPressed: onFilterTap,
              icon: Icon(
                Icons.tune,
                color: const Color(0xFF0A2A4A),
                size: iconSize,
              ),
              splashRadius: isWideScreen ? 20 : 20,
              constraints: BoxConstraints(
                minHeight: isWideScreen ? 40 : 40,
                minWidth: isWideScreen ? 40 : 40,
              ),
              padding: EdgeInsets.zero,
            ),
        ],
      ),
    );

    if (!_isTextField) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: bar,
      );
    }

    return bar;
  }
}