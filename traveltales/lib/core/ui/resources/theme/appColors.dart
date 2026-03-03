import 'package:flutter/material.dart';

class AppColors {
  static const containerBoxColor = Color(0xFFEDF0F7);
  static const detailBackgroundColor = Color(0xFFF7FCFF);
  static const darkDetailBackgroundColor = Color(0xFF0A2A4A);
  static const darkContainerBoxColor = Color(0xFF0C3047);
  static const leadingDetailPageColor = Color(0x60000000);

  static Color getContainerBoxColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? containerBoxColor
        : darkContainerBoxColor;
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
}