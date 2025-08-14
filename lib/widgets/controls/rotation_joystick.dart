import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:legged_robot_app/units/app_colors.dart';
import '../../controllers/main_conroller.dart';
import '../../services/talker_service.dart';
import '../../units/robot_commands.dart';

class RotationJoystick extends StatelessWidget {
  final MainController controller;
  final double sizeJoy;
  final double sizeBall;
  const RotationJoystick({
    super.key,
    required this.controller,
    this.sizeJoy = 200,
    this.sizeBall = 50,
  });

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerUp: (event) => _onPointerUp(),
      child: Joystick(
        includeInitialAnimation: false,
        base: JoystickBase(
          size: sizeJoy,
          mode: JoystickMode.horizontal,
          decoration: JoystickBaseDecoration(
            color: AppColors.card.withValues(alpha: 0.1),
            drawOuterCircle: false,
          ),
          arrowsDecoration: JoystickArrowsDecoration(
            color: AppColors.primary.withValues(alpha: 70),
            enableAnimation: false,
          ),
        ),
        stick: JoystickStick(
          size: sizeBall,
          decoration: JoystickStickDecoration(
            color: AppColors.primary.withValues(alpha: 30),
          ),
        ),
        period: Duration(
          milliseconds: controller.samplingRate.value.toInt() * 1000,
        ),
        listener: _onJoystickMove,
        onStickDragEnd: _onStickDragEnd,
      ),
    );
  }

  void _onPointerUp() {
    talker.info('onPointerUp');
    _sendStopCommand();
  }

  void _onJoystickMove(StickDragDetails details) {
    if (details.x > 0.6 || details.x < -0.6) {
      final double angularZ = -details.x;
      final double angularScale = controller.angularSpeed.value;
      final double cmdLinearY = angularZ * angularScale;

      _sendRotationCommand(cmdLinearY);
    }
  }

  void _onStickDragEnd() {
    talker.info('onStickDragEnd');
    _sendStopCommand();
  }

  void _sendRotationCommand(double angularZ) {
    final data = RobotCommands.createRotationCommand(angularZ);

    controller.sendData(jsonEncode(data));
  }

  void _sendStopCommand() {
    final data = RobotCommands.createStopCommand();

    controller.sendData(jsonEncode(data));
  }
}
