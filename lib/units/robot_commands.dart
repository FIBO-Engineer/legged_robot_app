import '../models/velocity_data.dart';

class RobotCommands {
  static const String velocityTopic = '/cmd_vel';
  static const String publishOp = 'publish';

  static Map<String, dynamic> createVelocityCommand({
    required double linearX,
    required double linearY,
    double linearZ = 0.0,
    double angularX = 0.0,
    double angularY = 0.0,
    double angularZ = 0.0,
  }) {
    final velocityData = VelocityData(
      op: publishOp,
      topic: velocityTopic,
      msg: VelocityMessage(
        linear: LinearVelocity(x: linearX, y: linearY, z: linearZ),
        angular: AngularVelocity(x: angularX, y: angularY, z: angularZ),
      ),
    );

    return velocityData.toJson();
  }

  static Map<String, dynamic> createStopCommand() {
    return createVelocityCommand(linearX: 0.0, linearY: 0.0);
  }

  static Map<String, dynamic> createRotationCommand(double angularZ) {
    return createVelocityCommand(
      linearX: 0.0,
      linearY: 0.0,
      angularZ: angularZ,
    );
  }

  static Map<String, dynamic> createServiceCommand({
    required String service,
    Map<String, dynamic>? args,
  }) {
    return {'op': 'call_service', 'service': service, 'args': args ?? {}};
  }

  static Map<String, dynamic> createPostureCommand({
    required String postureName,
    int isOptimization = 0,
    int orientationMode = 0,
    double controlLinearVel = 0.0,
  }) {
    return {
      'op': 'publish',
      'topic': '/arms_tasks_req',
      'msg': {
        'data': {
          'arms_tasks_name': postureName,
          'is_optimization': isOptimization,
          'orientation_mode': orientationMode,
          'control_linear_vel': controlLinearVel,
        },
      },
    };
  }
}
