// ===========================================
// lib/widgets/common/glassmorphism_container.dart
// ===========================================
import 'dart:ui';
import 'package:flutter/material.dart';

class GlassmorphismContainer extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final double borderRadius;
  final double sigmaX;
  final double sigmaY;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;

  const GlassmorphismContainer({
    super.key,
    required this.child,
    required this.width,
    required this.height,
    this.borderRadius = 16,
    this.sigmaX = 15,
    this.sigmaY = 15,
    this.backgroundColor = const Color(0x4D000000), // Colors.black.withOpacity(0.3)
    this.borderColor = const Color(0x33FFFFFF), // Colors.white.withOpacity(0.2)
    this.borderWidth = 1,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: child,
        ),
      ),
    );
  }
}
