import 'dart:math' as math;

import 'package:flutter/material.dart';

class DashedPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double strokeWidth;
  final double dash;
  final double gap;

  DashedPainter({
    required this.color,
    this.radius = 16,
    this.strokeWidth = 1,
    this.dash = 6,
    this.gap = 5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final basePath = Path()..addRRect(rrect);

    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..color = color;

    for (final metric in basePath.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double next = math.min(distance + dash, metric.length);
        final segment = metric.extractPath(distance, next);
        canvas.drawPath(segment, paint);
        distance = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant DashedPainter old) =>
      color != old.color ||
      radius != old.radius ||
      strokeWidth != old.strokeWidth ||
      dash != old.dash ||
      gap != old.gap;
}
