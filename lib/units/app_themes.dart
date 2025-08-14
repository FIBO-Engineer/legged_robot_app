import 'package:flutter/material.dart';
import 'app_colors.dart';

TextTheme textTheme() {
  return const TextTheme(
    bodyLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: Colors.white,
      overflow: TextOverflow.ellipsis,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: Colors.white,
      overflow: TextOverflow.ellipsis,
    ),
    bodySmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: AppColors.grey,
      overflow: TextOverflow.ellipsis,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: Colors.white,
      overflow: TextOverflow.ellipsis,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Colors.white,
      overflow: TextOverflow.ellipsis,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
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
      color: AppColors.grey,
      overflow: TextOverflow.ellipsis,
    ),
  );
}

InputDecorationTheme inputDecorationTheme() {
  const borderRadius = BorderRadius.all(Radius.circular(12));

  return InputDecorationTheme(
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
    filled: true,
    alignLabelWithHint: true,
    fillColor: AppColors.scaffold,
    prefixIconColor: AppColors.grey,
    suffixIconColor: AppColors.grey,
    helperStyle: const TextStyle(color: AppColors.grey, fontSize: 14),
    errorStyle: const TextStyle(color: AppColors.red, fontSize: 14),
    labelStyle: const TextStyle(
      color: AppColors.grey,
      fontSize: 14,
      fontWeight: FontWeight.normal,
    ),
    hintStyle: const TextStyle(
      color: AppColors.grey,
      fontSize: 14,
      fontWeight: FontWeight.normal,
    ),
    prefixStyle: const TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.normal,
    ),
    floatingLabelStyle: const TextStyle(
      color: AppColors.grey,
      fontSize: 14,
      fontWeight: FontWeight.normal,
    ),
  );
}
