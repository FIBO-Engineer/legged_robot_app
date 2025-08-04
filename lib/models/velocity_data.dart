class VelocityData {
  final String op;
  final String topic;
  final VelocityMessage msg;

  VelocityData({required this.op, required this.topic, required this.msg});

  Map<String, dynamic> toJson() {
    return {'op': op, 'topic': topic, 'msg': msg.toJson()};
  }
}

class VelocityMessage {
  final LinearVelocity linear;
  final AngularVelocity angular;

  VelocityMessage({required this.linear, required this.angular});

  Map<String, dynamic> toJson() {
    return {'linear': linear.toJson(), 'angular': angular.toJson()};
  }
}

class LinearVelocity {
  final double x;
  final double y;
  final double z;

  LinearVelocity({required this.x, required this.y, required this.z});

  Map<String, dynamic> toJson() {
    return {'x': x, 'y': y, 'z': z};
  }
}

class AngularVelocity {
  final double x;
  final double y;
  final double z;

  AngularVelocity({required this.x, required this.y, required this.z});

  Map<String, dynamic> toJson() {
    return {'x': x, 'y': y, 'z': z};
  }
}
