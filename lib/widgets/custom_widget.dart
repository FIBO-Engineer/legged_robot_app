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
    return Card(
      elevation: 2,
      color: AppColors.scaffold,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Container(
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

  const CustomButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.text = '',
    this.backgroundColor = AppColors.card,
    this.foregroundColor = AppColors.grey,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: Icon(icon, color: foregroundColor, size: 20),
      label: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: foregroundColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        elevation: 2,
        minimumSize: Size(0, 46),
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      onPressed: onPressed,
    );
  }
}
