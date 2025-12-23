
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Dimens {
  final double extraSmall;
  final double small1;
  final double small2;
  final double middle1;
  final double small3;
  final double medium1;
  final double medium2;
  final double medium3;
  final double large;
  final double extraLarge;
  final double borderWidth;
  final double loginImageSize;



  Dimens({
    this.extraSmall = 0.0,
    this.small1 = 0.0,
    this.small2 = 0.0,
    this.middle1 = 0.0,
    this.small3 = 0.0,
    this.medium1 = 0.0,
    this.medium2 = 0.0,
    this.medium3 = 0.0,
    this.large = 0.0,
    this.extraLarge = 0.0,
    this.borderWidth = 0.0,
    this.loginImageSize = 0.0,
  });
}

final compactDimens = Dimens(
  extraSmall: 2.0.w,
  small1: 4.0.w,
  small2: 8.0.w,
  middle1: 12.0.w,
  small3: 16.0.w,
  medium1: 24.0.w,
  medium2: 32.0.w,
  medium3: 48.0.w,
  borderWidth: 2.0.w,
  large: 56.0.w,
  extraLarge: 64.0.w,
  loginImageSize: 160.0.w,
);
