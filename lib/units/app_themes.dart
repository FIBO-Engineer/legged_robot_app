import 'package:flutter/material.dart';
import 'app_colors.dart';

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
    fillColor: AppColors.card,
    prefixIconColor: AppColors.grey,
    suffixIconColor: AppColors.grey,
    helperStyle: const TextStyle(color: AppColors.grey, fontSize: 12),
    errorStyle: const TextStyle(color: AppColors.red, fontSize: 12),
    labelStyle: const TextStyle(
      color: AppColors.grey,
      fontSize: 12,
      fontWeight: FontWeight.normal,
    ),
    hintStyle: const TextStyle(
      color: AppColors.grey,
      fontSize: 12,
      fontWeight: FontWeight.normal,
    ),
    prefixStyle: const TextStyle(
      color: Colors.black,
      fontSize: 12,
      fontWeight: FontWeight.normal,
    ),
    floatingLabelStyle: const TextStyle(
      color: AppColors.grey,
      fontSize: 12,
      fontWeight: FontWeight.normal,
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
  );
}
