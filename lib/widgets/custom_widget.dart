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
    this.size = 46,
    this.iconSize = 20,
    this.borderRadius = 28,
    this.tooltip = "",
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return  Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: IconButton(
          hoverColor: backgroundColor,
          icon: Icon(icon, color: iconColor, size: iconSize),
          onPressed: onPressed,
          tooltip: tooltip,
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
    this.borderRadius = 12,
    this.height = 46.0,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: Icon(icon, color: foregroundColor),
      label: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: foregroundColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: TextButton.styleFrom(
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        minimumSize: Size(0, height),
      ),
      onPressed: onPressed,
    );
  }
}
