import 'package:flutter/material.dart';

class AppColors {
  static const containerBoxColor = Color(0xFFEDF0F7);
  static const detailBackgroundColor = Color(0xFFF7FCFF);
  static const darkDetailBackgroundColor = Color(0xFF0A2A4A);
  static const darkContainerBoxColor = Color(0xFF0C3047);
  static const darkReverseContainerBoxColor = Color(0xFFDFE1E8);
  static const containerReverseBoxColor = Color(0xFFEDF0F7);
  static const leadingDetailPageColor = Color(0x60000000);
  static const borderColor = Color(0xFFE4E7EC);
  static const darkBorderColor = Color(0xFF2E587C);

  static Color getBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? borderColor
        : darkBorderColor;
  }
  static Color getContainerBoxColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? containerBoxColor
        : darkContainerBoxColor;
  }
  static Color getContainerReverseBoxColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? darkReverseContainerBoxColor
        : containerReverseBoxColor.withOpacity(0.10);
  }
  static Color getDetailBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? detailBackgroundColor
        : darkDetailBackgroundColor;
  }
  static Color getIconColors(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? Colors.lightBlue
        : Colors.lightBlue;
  }
  static Color getSmallTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? Colors.grey
        : Colors.grey;
  }
  static Color difficultyColor(String difficulty) {
    final value = difficulty.toLowerCase();

    if (value == "hard") return const Color(0xFFE53935);
    if (value == "medium") return Colors.orange;

    return Colors.green;
  }

  static Color difficultyBgColor(String difficulty) {
    final value = difficulty.toLowerCase();

    if (value == "hard") return const Color(0xFFFFE3E3);
    if (value == "medium") return const Color(0xFFFFF1DD);
    return const Color(0xFFE6F6EA);
  }
}