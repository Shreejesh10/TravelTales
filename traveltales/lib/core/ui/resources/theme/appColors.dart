import 'package:flutter/material.dart';

class AppColors {
  static const containerBoxColor = Color(0xFFEDF0F7);
  static const darkContainerBoxColor = Color(0xFF0C3047);

  static Color getContainerBoxColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? containerBoxColor
        : darkContainerBoxColor;
  }
}