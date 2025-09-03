import 'package:flutter/material.dart';
import '../units/app_colors.dart';

class CircleButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color borderColor;
  final double size;
  final double iconSize;
  final double borderRadius;
  final String tooltip;
  final VoidCallback onPressed;

  const CircleButton({
    super.key,
    required this.icon,
    this.iconColor = Colors.white,
    this.backgroundColor = AppColors.card,
    this.borderColor = Colors.transparent,
    this.size = 44,
    this.iconSize = 20,
    this.borderRadius = 28,
    this.tooltip = "",
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, color: iconColor, size: iconSize),
      style: IconButton.styleFrom(
        fixedSize: Size(size, size),
        minimumSize: Size(size, size),
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: BorderSide(color: borderColor, width: 1.2),
        ),
      ),
    );
  }
}
class CustomButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String text;
  final Color backgroundColor;
  final Color foregroundColor;
  final double borderRadius;
  final double height;

  const CustomButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.text = '',
    this.backgroundColor = AppColors.card,
    this.foregroundColor = AppColors.grey,
    this.borderRadius = 28,
    this.height = 44, 
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: foregroundColor, size: 18),
      label: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: foregroundColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: TextButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical:8),
        fixedSize: Size.fromHeight(height),
        minimumSize: Size(0, height),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        elevation: 2,
      ),
    );
  }
}
