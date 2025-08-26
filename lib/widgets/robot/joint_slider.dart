import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:get/get.dart';
import 'package:legged_robot_app/units/app_colors.dart';
import 'dart:math' as math;
import '../../controllers/urdf_controller.dart';
import '../../models/urdf_joint.dart';

class JointSlider extends StatelessWidget {
  final URDFJoint joint;

  const JointSlider({super.key, required this.joint});

  Color _getJointColor(String jointName) {
    final name = jointName.toLowerCase();

    if (name.contains('left_hip') ||
        name.contains('left_knee') ||
        name.contains('left_ankle') ||
        name.contains('right_hip') ||
        name.contains('right_knee') ||
        name.contains('right_ankle')) {
      return const Color(0xFF2E7D32); // Darker green for legs
    } else if (name.contains('left_shoulder') ||
        name.contains('left_elbow') ||
        name.contains('left_wrist') ||
        name.contains('right_shoulder') ||
        name.contains('right_elbow') ||
        name.contains('right_wrist')) {
      return AppColors.grey; // Darker orange for arms
    } else if (name.contains('waist') || name.contains('torso')) {
      return const Color(0xFF1565C0); // Darker blue for torso
    } else if (name.contains('head') || name.contains('neck')) {
      return const Color(0xFFC2185B); // Darker pink for head
    } else {
      return const Color(0xFF455A64); // Darker blue-grey for others
    }
  }

  String _formatJointName(String name) {
    return name
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) =>
              word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '',
        )
        .join(' ');
  }

  void _showInputDialog(
    BuildContext context,
    UrdfController controller,
    Color jointColor,
  ) {
    final currentValue = controller.getJointValue(joint.name);
    final minValue = joint.limits?.lower ?? -math.pi;
    final maxValue = joint.limits?.upper ?? math.pi;

    final degreeController = TextEditingController(
      text: (currentValue * 180 / math.pi).toStringAsFixed(1),
    );
    final radianController = TextEditingController(
      text: currentValue.toStringAsFixed(3),
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              _formatJointName(joint.name),
              style: TextStyle(color: jointColor, fontWeight: FontWeight.w600),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Degrees Input
                TextField(
                  controller: degreeController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Degrees (°)',
                    // ignore: deprecated_member_use
                    labelStyle: TextStyle(color: jointColor.withOpacity(0.7)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: jointColor, width: 2),
                    ),
                    suffixText: '°',
                    hintText:
                        '${(minValue * 180 / math.pi).toStringAsFixed(0)} to ${(maxValue * 180 / math.pi).toStringAsFixed(0)}',
                  ),
                  onChanged: (value) {
                    final degrees = double.tryParse(value);
                    if (degrees != null) {
                      final radians = degrees * math.pi / 180;
                      radianController.text = radians.toStringAsFixed(3);
                    }
                  },
                ),
                const SizedBox(height: 16),
                // Radians Input
                TextField(
                  controller: radianController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Radians (r)',
                    // ignore: deprecated_member_use
                    labelStyle: TextStyle(color: jointColor.withOpacity(0.7)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: jointColor, width: 2),
                    ),
                    suffixText: 'r',
                    hintText:
                        '${minValue.toStringAsFixed(2)} to ${maxValue.toStringAsFixed(2)}',
                  ),
                  onChanged: (value) {
                    final radians = double.tryParse(value);
                    if (radians != null) {
                      final degrees = radians * 180 / math.pi;
                      degreeController.text = degrees.toStringAsFixed(1);
                    }
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'Range: ${(minValue * 180 / math.pi).toStringAsFixed(0)}° to ${(maxValue * 180 / math.pi).toStringAsFixed(0)}°',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  final radians = double.tryParse(radianController.text);
                  if (radians != null) {
                    final clampedValue = radians.clamp(minValue, maxValue);
                    // controller.setJointValue(joint.name, clampedValue);

                    controller.moveJoint(joint.name, clampedValue);
                  }
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: jointColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Apply'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final UrdfController controller = Get.find<UrdfController>();
    final minValue = joint.limits?.lower ?? -math.pi;
    final maxValue = joint.limits?.upper ?? math.pi;
    final jointColor = _getJointColor(joint.name);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: jointColor.withOpacity(0.15),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
        // ignore: deprecated_member_use
        border: Border.all(color: jointColor.withOpacity(0.4), width: 1.5),
      ),
      child: MouseRegion(
        onEnter: (_) => controller.highlightJoint(joint.name),
        onExit: (_) => controller.unhighlightJoint(joint.name),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Compact Header
              Row(
                children: [
                  // Color Indicator
                  Container(
                    width: 3,
                    height: 16,
                    decoration: BoxDecoration(
                      color: jointColor,
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                  const SizedBox(width: 6),

                  // Joint Name (Compact)
                  Expanded(
                    child: Text(
                      _formatJointName(joint.name),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: jointColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Axis Info
                  Icon(
                    Icons.rotate_90_degrees_ccw_outlined,
                    size: 12,
                    // ignore: deprecated_member_use
                    color: jointColor.withOpacity(0.6),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${joint.axis}',
                    style: TextStyle(
                      fontSize: 10,
                      // ignore: deprecated_member_use
                      color: jointColor.withOpacity(0.6),
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Values Display (Clickable)
                  Obx(() {
                    final currentValue = controller.getJointValue(joint.name);
                    final degrees = (currentValue * 180 / math.pi);
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap:
                            () => _showInputDialog(
                              context,
                              controller,
                              jointColor,
                            ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
                            color: jointColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              // ignore: deprecated_member_use
                              color: jointColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${degrees.toStringAsFixed(1)}°',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: jointColor,
                                ),
                              ),
                              Text(
                                '${currentValue.toStringAsFixed(2)}r',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  // ignore: deprecated_member_use
                                  color: jointColor.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(width: 4),

                  // Compact Info Button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        controller.highlightJoint(joint.name);
                        Future.delayed(const Duration(milliseconds: 1000), () {
                          controller.unhighlightJoint(joint.name);
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Icon(
                          Icons.visibility_outlined,
                          size: 24,
                          color: jointColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // Compact Slider with Inline Values
              Row(
                children: [
                  // Min Value (Compact)
                  SizedBox(
                    width: 32,
                    child: Column(
                      children: [
                        Text(
                          '${(minValue * 180 / math.pi).toStringAsFixed(0)}°',
                          style: TextStyle(
                            fontSize: 12,
                            // ignore: deprecated_member_use
                            color: jointColor.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${minValue.toStringAsFixed(1)}r',
                          style: TextStyle(
                            fontSize: 10,
                            // ignore: deprecated_member_use
                            color: jointColor.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Compact Slider
                  Expanded(
                    child: Obx(() {
                      final currentValue = controller.getJointValue(joint.name);
                      return SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: jointColor,
                          // ignore: deprecated_member_use
                          inactiveTrackColor: jointColor.withOpacity(0.25),
                          thumbColor: jointColor,
                          // ignore: deprecated_member_use
                          overlayColor: jointColor.withOpacity(0.2),
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 12,
                          ),
                        ),
                        child: Slider(
                          value: currentValue.clamp(minValue, maxValue),
                          min: minValue,
                          max: maxValue,
                          divisions: 100,
                          onChanged: (value) {
                            controller.disableReceiveJointState.value = true;
                            controller.setJointValue(joint.name, value);
                            // controller.moveJoint(joint.name, value);
                          },
                          onChangeEnd: (value) {
                            //
                            // talker.warning('-------------> ${joint.name}, $value');
                            if (!controller.cancelMove.value) {
                              controller.moveJoint(joint.name, value);
                            }

                            controller.disableReceiveJointState.value = false;
                          },
                        ),
                      );
                    }),
                  ),

                  // Max Value (Compact)
                  SizedBox(
                    width: 32,
                    child: Column(
                      children: [
                        Text(
                          '${(maxValue * 180 / math.pi).toStringAsFixed(0)}°',
                          style: TextStyle(
                            fontSize: 12,
                            // ignore: deprecated_member_use
                            color: jointColor.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${maxValue.toStringAsFixed(1)}r',
                          style: TextStyle(
                            fontSize: 10,
                            // ignore: deprecated_member_use
                            color: jointColor.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
