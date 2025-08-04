import 'package:flutter/widgets.dart';
import 'package:toastification/toastification.dart';

class ToastService {
  static void showToast({
    required String title,
    required String description,
    ToastificationType type = ToastificationType.info,
    ToastificationStyle style = ToastificationStyle.fillColored,
    Alignment alignment = Alignment.bottomCenter,
    Duration duration = const Duration(seconds: 5),
  }) {
    toastification.show(
      type: type,
      style: style,
      alignment: alignment,
      title: Text(title),
      description: Text(description),
      autoCloseDuration: duration,
    );
  }
}
