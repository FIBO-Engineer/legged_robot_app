import 'package:flutter/material.dart';

class ScreenSize {
  final BuildContext context;
  final double width;
  final double height;
  final bool isTablet;
  final bool isDesktop;
  final bool isMobile;
  final bool isPortrait;

  ScreenSize(this.context)
    : width = MediaQuery.of(context).size.width,
      height = MediaQuery.of(context).size.height,
      isTablet =
          MediaQuery.of(context).size.width >= 900 &&
          MediaQuery.of(context).size.width < 1024,
      isDesktop = MediaQuery.of(context).size.width >= 1024,
      isMobile = MediaQuery.of(context).size.width < 900,
      isPortrait =
          MediaQuery.of(context).size.height >
          MediaQuery.of(context).size.width;
}

class AppIcons {
  static const IconData gamePad = IconData(0xea45, fontFamily: 'GamePad');
}
