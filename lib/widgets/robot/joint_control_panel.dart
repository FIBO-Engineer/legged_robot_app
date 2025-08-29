import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/main_conroller.dart';
import '../../controllers/urdf_controller.dart';
import '../../units/app_colors.dart';
import '../custom_widget.dart';
import 'joint_slider.dart';

class JointControlPanel extends StatelessWidget {
  const JointControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final UrdfController controller = Get.find<UrdfController>();
    final MainController mainController = Get.find();
    return Column(
      spacing: 6,
      children: [
        Row(
          spacing: 8,
          children: [
            CustomButton(
              text: 'Free',
              foregroundColor: AppColors.primary,
              icon: Icons.lock_reset,
              onPressed: () {
                Map data = {
                  "op": "call_service",
                  "service": "/humanoid_arm_control/run_manipulator",
                  "type": "std_srvs/srv/SetBool",
                  "args": {"data": true},
                };
                mainController.sendData(jsonEncode(data));
              },
            ),
            CustomButton(
              text: 'Lock',
              foregroundColor: AppColors.red,
              icon: Icons.lock,
              onPressed: () {
                Map data = {
                  "op": "call_service",
                  "service": "/humanoid_arm_control/run_manipulator",
                  "type": "std_srvs/srv/SetBool",
                  "args": {"data": false},
                };
                mainController.sendData(jsonEncode(data));
              },
            ),

            MouseRegion(
              onEnter: (_) {
                controller.cancelMove.value = true;
              },
              onExit: (_) {
                controller.cancelMove.value = false;
              },
              cursor: SystemMouseCursors.click,
              child: CircleButton(
                borderRadius: 12,
                iconColor: AppColors.grey,
                icon: Icons.clear,
                onPressed: () {
                  // Also handle tap to cancel
                  // controller.stopJointMovement(joint.name);
                  // talker.info('Cancel joint movement ----- 2');
                },
              ),
            ),
            Spacer(),
              CustomButton(
                text: 'Save',
                foregroundColor: AppColors.green,
                icon: Icons.save_rounded,
                onPressed: () {
                  _showSaveDialog(context, mainController);
                },
              ),
          ],
        ),
        Expanded(
          child: Obx(() {
            final joints = controller.getControllableJoints();

            if (joints.isEmpty) {
              return const Center(child: Text('No controllable joints found'));
            }

            return ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: joints.length,
              itemBuilder: (context, index) {
                return JointSlider(joint: joints[index]);
              },
            );
          }),
        ),
      ],
    );
  }
}

void _showSaveDialog(BuildContext context, MainController controller) {
  final textCon = TextEditingController(text: '');

  showDialog(
    useSafeArea: true,
    barrierDismissible: true,
    context: context,
    builder:
        (context) => AlertDialog(
          title: Text(
            'Save Capture',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Degrees Input
              TextField(
                controller: textCon,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]')),
                ],
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: Colors.grey[600]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                  ),
                  // hintText: 'Enter a name for the capture',
                ),
                onChanged: (value) {},
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () {
                Map data = {
                  "op": "publish",
                  "topic": "/add_arms_tasks",
                  "msg": {"data": textCon.text},
                };
                controller.sendData(jsonEncode(data));
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
  );
}
