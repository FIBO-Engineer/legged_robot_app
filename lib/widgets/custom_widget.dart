import 'package:flutter/material.dart';

import '../units/app_colors.dart';

class CircleButton extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final double size;
  final double iconSize;
  final VoidCallback onPressed;

  const CircleButton({
    super.key,
    required this.icon,
    this.backgroundColor = AppColors.card,
    this.iconColor = Colors.white,
    this.size = 32,
    this.iconSize = 18,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor, size: iconSize),
        onPressed: onPressed,
        splashRadius: size / 2,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
