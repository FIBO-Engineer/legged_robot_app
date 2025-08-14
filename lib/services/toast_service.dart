import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import '../units/app_colors.dart';

class ToastService {
  static void showToast({
    required String title,
    required String description,
    ToastificationType type = ToastificationType.info,
    ToastificationStyle style = ToastificationStyle.minimal,
    Alignment alignment = Alignment.bottomCenter,
    Duration duration = const Duration(seconds: 2),
  }) {
    late Color accent;
    late IconData icon;

    switch (type) {
      case ToastificationType.success:
        accent = AppColors.green;
        icon = Icons.check_circle_rounded;
        break;
      case ToastificationType.warning:
        accent = AppColors.orange;
        icon = Icons.warning_rounded;
        break;
      case ToastificationType.error:
        accent = AppColors.red;
        icon = Icons.error_rounded;
        break;
      case ToastificationType.info:
        accent = AppColors.primary;
        icon = Icons.info_rounded;
        break;
    }

    toastification.show(
      type: type,
      alignment: alignment,
      autoCloseDuration: duration,
      backgroundColor: AppColors.card,
      foregroundColor: Colors.white,
      borderSide: BorderSide(color: AppColors.grey, width: 0.8),
      title: Text(
        title,
        style: TextStyle(color: accent, fontWeight: FontWeight.bold),
      ),
      description: Text(description, style: TextStyle(color: accent)),
      icon: Icon(icon, color: accent),
    );
  }
}
