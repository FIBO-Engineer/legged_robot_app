import 'dart:ui';
import 'package:flutter/material.dart';

class DisplayGrid extends StatelessWidget {
  const DisplayGrid({
    super.key,
    required this.step,
    required this.width,
    required this.height,
    this.majorEvery = 5,
    this.minorSize = 1.5,
    this.majorSize = 2.5,
  });

  final double step;
  final double width;
  final double height;
  final int majorEvery;
  final double minorSize;
  final double majorSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final minorColor = (isDark ? Colors.white : Colors.black).withAlpha(60);
    final majorColor = (isDark ? Colors.white : Colors.black).withAlpha(110);

    return RepaintBoundary(
      child: CustomPaint(
        isComplex: true,
        willChange: false,
        size: Size(width, height),
        painter: GridPainter(
          step: step,
          minorColor: minorColor,
          majorColor: majorColor,
          majorEvery: majorEvery,
          minorSize: minorSize,
          majorSize: majorSize,
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  GridPainter({
    required this.step,
    required this.minorColor,
    required this.majorColor,
    required this.majorEvery,
    required this.minorSize,
    required this.majorSize,
  });

  final double step;
  final Color minorColor;
  final Color majorColor;
  final int majorEvery;
  final double minorSize;
  final double majorSize;

  @override
  void paint(Canvas canvas, Size size) {
    if (step <= 0) return;

    final minorPaint =
        Paint()
          ..color = minorColor
          ..strokeWidth = minorSize
          ..strokeCap =
              StrokeCap
                  .round 
          ..isAntiAlias = false; 

    final majorPaint =
        Paint()
          ..color = majorColor
          ..strokeWidth = majorSize
          ..strokeCap = StrokeCap.round
          ..isAntiAlias = false;

    final minorPts = <Offset>[];
    final majorPts = <Offset>[];

    final minorOffset = (minorSize % 2 == 1) ? 0.5 : 0.0;
    final majorOffset = (majorSize % 2 == 1) ? 0.5 : 0.0;

    int ix = 0;
    for (double x = 0; x <= size.width + 0.01; x += step, ix++) {
      int iy = 0;
      final isMajorX = (ix % majorEvery == 0);
      final xoMinor = x + minorOffset;
      final xoMajor = x + majorOffset;

      for (double y = 0; y <= size.height + 0.01; y += step, iy++) {
        final isMajorY = (iy % majorEvery == 0);
        if (isMajorX && isMajorY) {
          majorPts.add(Offset(xoMajor, y + majorOffset));
        } else {
          minorPts.add(Offset(xoMinor, y + minorOffset));
        }
      }
    }

    if (minorPts.isNotEmpty) {
      canvas.drawPoints(PointMode.points, minorPts, minorPaint);
    }
    if (majorPts.isNotEmpty) {
      canvas.drawPoints(PointMode.points, majorPts, majorPaint);
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter old) {
    return step != old.step ||
        minorColor != old.minorColor ||
        majorColor != old.majorColor ||
        majorEvery != old.majorEvery ||
        minorSize != old.minorSize ||
        majorSize != old.majorSize;
  }
}
