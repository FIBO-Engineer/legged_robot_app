import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import '../../controllers/main_conroller.dart';
import '../../services/talker_service.dart';
import '../../units/app_colors.dart';
import '../../units/robot_commands.dart';

class MovementJoystick extends StatelessWidget {
  final MainController controller;
  final double sizeJoy;
  final double sizeBall;

  const MovementJoystick({
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
          mode: JoystickMode.all,
          decoration: JoystickBaseDecoration(
            color: AppColors.card.withValues(alpha: 100),
            drawOuterCircle: false,
          ),
          arrowsDecoration: JoystickArrowsDecoration(
            color: AppColors.red.withValues(alpha: 70),
            enableAnimation: false,
          ),
        ),
        stick: JoystickStick(
          size: sizeBall,
          decoration: JoystickStickDecoration(
            color: AppColors.red.withValues(alpha: 30),
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
    final double linearX = -details.y;
    final double angularZ = -details.x;

    final double linearScale = controller.linearSpeed.value;
    final double angularScale = controller.angularSpeed.value;

    final double cmdLinear = linearX * linearScale;
    final double cmdAngular = angularZ * angularScale;

    talker.info('Joystick -> linearX: $cmdLinear, angularZ: $cmdAngular');

    _sendVelocityCommand(cmdLinear, cmdAngular, 0.0);
  }

  void _onStickDragEnd() {
    talker.info('onStickDragEnd');
    _sendStopCommand();
  }

  void _sendVelocityCommand(double linearX, double linearY, double angularZ) {
    final data = RobotCommands.createVelocityCommand(
      linearX: linearX,
      linearY: linearY,
      angularZ: angularZ,
    );
    controller.sendData(jsonEncode(data));
  }

  void _sendStopCommand() {
    final data = RobotCommands.createStopCommand();

    controller.sendData(jsonEncode(data));
  }
}
