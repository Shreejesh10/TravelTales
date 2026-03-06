import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    this.onFilterTap
  });

  bool get _isTextField => controller != null;

  @override
  Widget build(BuildContext context) {
    final bar = Container(
      height: compactDimens.medium3,
      padding: EdgeInsets.symmetric(horizontal: compactDimens.small3),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF0F7),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0xFF0A2A4A)),
          const SizedBox(width: 10),
          Expanded(
            child: _isTextField
                ? TextField(
              controller: controller,
              onChanged: onChanged,
              autofocus: false,
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
                isCollapsed: true,
              ),
            )
                : Text(
              hintText,
              style: const TextStyle(
                color: Colors.black45,
                fontSize: 14,
              ),
            ),
          ),
          if (isFilter)
            IconButton(
              onPressed: onFilterTap,
              icon: const Icon(Icons.tune, color: Color(0xFF0A2A4A)),
            ),


        ],
      ),
    );

    if (!_isTextField) {
      return InkWell(onTap: onTap, child: bar);
    }

    return bar;
  }
}