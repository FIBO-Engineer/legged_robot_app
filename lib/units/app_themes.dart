import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'app_colors.dart';

TextTheme textTheme() {
  return const TextTheme(
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: Colors.white,
      overflow: TextOverflow.ellipsis,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: AppColors.grey,
      overflow: TextOverflow.ellipsis,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: AppColors.grey,
      overflow: TextOverflow.ellipsis,
    ),
    titleLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.white,
      overflow: TextOverflow.ellipsis,
    ),
    titleMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.grey,
      overflow: TextOverflow.ellipsis,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.grey,
      overflow: TextOverflow.ellipsis,
    ),
    labelLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.grey,
      overflow: TextOverflow.ellipsis,
    ),
    labelMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Colors.white,
      overflow: TextOverflow.ellipsis,
    ),
    labelSmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: Colors.white,
      overflow: TextOverflow.ellipsis,
    ),
  );
}

InputDecorationTheme inputDecorationTheme(BuildContext context) {
  const borderRadius = BorderRadius.all(Radius.circular(12));

  final isMobile = defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
  final media = MediaQuery.of(context);
  final isPortrait = media.orientation == Orientation.portrait;
  final double font = isMobile ? 14 : 13;
  final double vPad = isMobile
      ? (isPortrait ? 10 : 12) 
      : 8;
  final double minH = isMobile ? 44 : 40;

  return InputDecorationTheme(
    isDense: true,
    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: vPad),
    constraints: BoxConstraints(minHeight: minH),

    prefixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 36),
    suffixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 36),

    filled: true,
    alignLabelWithHint: true,
    fillColor: AppColors.scaffold,

    border: const OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide.none,
    ),
    enabledBorder: const OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide.none,
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: AppColors.primary, width: 1),
    ),
    errorBorder: const OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: AppColors.red, width: 1),
    ),
    focusedErrorBorder: const OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: AppColors.red, width: 1),
    ),

    prefixIconColor: AppColors.grey,
    suffixIconColor: AppColors.grey,

    labelStyle: TextStyle(color: AppColors.grey, fontSize: font),
    hintStyle:  TextStyle(color: AppColors.grey, fontSize: font),
    helperStyle: const TextStyle(color: AppColors.grey, fontSize: 13),
    errorStyle:  const TextStyle(color: AppColors.red,  fontSize: 13),
    floatingLabelStyle: TextStyle(color: AppColors.grey, fontSize: font),
  );
}