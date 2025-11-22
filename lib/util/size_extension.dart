import 'package:flutter/material.dart';

/// Extension for responsive sizing
extension SizeExtension on num {
  double get h => this * SizeConfig.safeBlockVertical;
  double get w => this * SizeConfig.safeBlockHorizontal;
  double get sp => this * SizeConfig.safeBlockHorizontal; // for font size
}

class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double safeBlockHorizontal;
  static late double safeBlockVertical;

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;

    safeBlockHorizontal = screenWidth / 100;
    safeBlockVertical = screenHeight / 100;
  }
}
