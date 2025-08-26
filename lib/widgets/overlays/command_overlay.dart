import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:legged_robot_app/units/app_colors.dart';

import '../../controllers/main_conroller.dart';
import '../common/command_button.dart';

class CommandOverlay extends StatelessWidget {
  const CommandOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final MainController controller = Get.find();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        // ignore: deprecated_member_use
        color: Colors.white.withOpacity(0.1),
        // ignore: deprecated_member_use
        border: Border.all(color: AppColors.orange.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Obx(() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_buildHeader(), const SizedBox(height: 8), _buildCommandList(controller)],
          );
        }),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          // ignore: deprecated_member_use
          decoration: BoxDecoration(color: AppColors.orange.withOpacity(0.3), borderRadius: BorderRadius.circular(6)),
          child: const Icon(Icons.terminal, size: 14, color: Colors.white),
        ),
        const SizedBox(width: 6),
        const Text("Commands", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
      ],
    );
  }

  Widget _buildCommandList(MainController controller) {
    if (controller.command.isEmpty) {
      // ignore: deprecated_member_use
      return Expanded(child: Center(child: Text("No commands", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10))));
    }

    return Expanded(
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: controller.command.length,
        itemBuilder: (context, index) {
          final cmd = controller.command[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: CommandButton(command: cmd, onTap: () => _executeCommand(controller, cmd)),
          );
        },
      ),
    );
  }

  void _executeCommand(MainController controller, String cmd) {
    Map data = {"op": "call_service", "service": cmd, "args": {}};
    controller.sendData(jsonEncode(data));
    HapticFeedback.lightImpact();
  }
}
