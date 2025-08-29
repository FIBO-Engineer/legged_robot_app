import 'package:flutter/material.dart';
import 'package:legged_robot_app/units/app_colors.dart';
import '../common/glassmorphism_container.dart';
import 'command_overlay.dart';
import 'posture_overlay.dart';

class ControlOverlay extends StatelessWidget {
  const ControlOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 26,
      left: 66,
      child: GlassmorphismContainer(
        width: 330,
        height: 200,
        backgroundColor: Colors.transparent,
        borderColor: AppColors.blueGrey,
        borderWidth: 1.2,
        child: Row(
          children: [
            // Command Card
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(8),
                child: const CommandOverlay(),
              ),
            ),
            // Posture Card
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                child: const PostureOverlay(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
