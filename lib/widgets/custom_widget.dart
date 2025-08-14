import 'package:flutter/material.dart';

import '../units/app_colors.dart';

class CircleButton extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final Color borderColor;
  final double size;
  final double iconSize;
  final VoidCallback onPressed;

  const CircleButton({
    super.key,
    required this.icon,
    this.backgroundColor = AppColors.card,
    this.iconColor = Colors.white,
    this.borderColor = Colors.transparent,
    this.size = 46,
    this.iconSize = 20,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.scaffold,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: borderColor, width: 1.2),
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
