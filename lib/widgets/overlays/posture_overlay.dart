import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:legged_robot_app/units/app_colors.dart';
import '../../controllers/main_conroller.dart';
import '../common/command_button.dart' show CommandButton;

class PostureOverlay extends StatelessWidget {
  const PostureOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final MainController controller = Get.find();

    return Obx(() {
      final hidden = controller.isHide.value;
      final hasData = controller.postures.isNotEmpty;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildToggleHeader(controller, hidden),
          const SizedBox(height: 6),
          if (!hidden) _buildPostureContent(controller, hasData),
        ],
      );
    });
  }

  Widget _buildToggleHeader(MainController controller, bool hidden) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: AppColors.primary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        // ignore: deprecated_member_use
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              controller.isHide.value = !controller.isHide.value;
              HapticFeedback.mediumImpact();
            },
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                hidden
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 6),
          const Icon(
            Icons.accessibility_new_rounded,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          const Expanded(
            child: Text(
              "Postures",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Speed Control Icon
          _buildSpeedControl(controller),
        ],
      ),
    );
  }

  Widget _buildSpeedControl(MainController controller) {
    return Obx(() {
      final currentSpeed = controller.speedLevel.value;
      final speedValues = [0.0, 0.2, 0.3];
      final speedIcons = [
        Icons.speed_outlined,
        Icons.speed,
        Icons.speed_rounded,
      ];
      final speedColors = [
        // ignore: deprecated_member_use
        Colors.white.withOpacity(0.9),
        // ignore: deprecated_member_use
        Colors.yellow.withOpacity(0.9),
        // ignore: deprecated_member_use
        Colors.amber.withOpacity(0.9),
      ];

      return GestureDetector(
        onTap: () {
          // Cycle through speed levels
          final nextLevel = (currentSpeed + 1) % 3;
          controller.speedLevel.value = nextLevel;
          HapticFeedback.selectionClick();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              // ignore: deprecated_member_use
              color: speedColors[currentSpeed].withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                speedIcons[currentSpeed],
                size: 14,
                color: speedColors[currentSpeed],
              ),
              const SizedBox(width: 3),
              Text(
                speedValues[currentSpeed] == 0.0
                    ? ".0"
                    : speedValues[currentSpeed] == 0.2
                    ? ".2"
                    : ".3",
                style: TextStyle(
                  color: speedColors[currentSpeed],
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildPostureContent(MainController controller, bool hasData) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          // ignore: deprecated_member_use
          color: Colors.white.withOpacity(0.1),
          // ignore: deprecated_member_use
          border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
        ),
        padding: const EdgeInsets.all(8.0),
        child: hasData ? _buildPostureList(controller) : _buildEmptyState(),
      ),
    );
  }

  Widget _buildPostureList(MainController controller) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: controller.postures.length,
      itemBuilder: (context, index) {
        final posture = controller.postures[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: CommandButton(
            command: posture,
            // ignore: deprecated_member_use
            backgroundColor: AppColors.primary.withOpacity(0.4),
            // ignore: deprecated_member_use
            borderColor: AppColors.primary.withOpacity(0.3),
            icon: Icons.sports_gymnastics_rounded,
            onTap: () => _executePosture(controller, posture),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        "No postures",
        // ignore: deprecated_member_use
        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10),
      ),
    );
  }

  void _executePosture(MainController controller, String posture) {
    // Get current speed level
    final speedValues = [0.0, 0.2, 0.3];
    final currentSpeed = controller.speedLevel.value;
    final controlLinearVel = speedValues[currentSpeed];

    Map data = {
      "op": "publish",
      "topic": "/arms_tasks_req",
      "msg": {
        "data": jsonEncode({
          "arms_tasks_name": posture,
          "is_optimization": 0,
          "orientation_mode": 1,
          "control_linear_vel": controlLinearVel,
        }),
      },
    };
    controller.sendData(jsonEncode(data));
    HapticFeedback.lightImpact();
  }
}
