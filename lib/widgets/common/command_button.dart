// ===========================================
// lib/widgets/common/command_button.dart
// ===========================================
import 'package:flutter/material.dart';

class CommandButton extends StatelessWidget {
  final String command;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color borderColor;
  final IconData icon;
  final double fontSize;

  const CommandButton({
    super.key,
    required this.command,
    required this.onTap,
    this.backgroundColor = const Color(0x66800080), // Colors.purple.withOpacity(0.4)
    this.borderColor = const Color(0x4D800080), // Colors.purple.withOpacity(0.3)
    this.icon = Icons.play_arrow_rounded,
    this.fontSize = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(8), border: Border.all(color: borderColor, width: 0.5)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Row(
              children: [
                Icon(icon, size: 12, color: Colors.white),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    command,
                    overflow: TextOverflow.fade,
                    style: TextStyle(fontSize: fontSize, color: Colors.white, fontWeight: FontWeight.w500, height: 1.2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
