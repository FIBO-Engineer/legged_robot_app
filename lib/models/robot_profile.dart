class RobotProfile {
  String robType;
  String ip;
  String camera;
  double linearSpeed;
  double angularSpeed;
  double samplingRate;

  RobotProfile({
    required this.robType,
    required this.ip,
    required this.camera,
    required this.linearSpeed,
    required this.angularSpeed,
    required this.samplingRate,
  });

  factory RobotProfile.fromJson(Map<String, dynamic> j) => RobotProfile(
    robType: j['robType'] ?? '',
    ip: j['ip'] ?? '',
    camera: j['camera'] ?? '',
    linearSpeed: (j['linearSpeed'] ?? 0.5).toDouble(),
    angularSpeed: (j['angularSpeed'] ?? 1.0).toDouble(),
    samplingRate: (j['samplingRate'] ?? 0.1).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'robType': robType,
    'ip': ip,
    'camera': camera,
    'linearSpeed': linearSpeed,
    'angularSpeed': angularSpeed,
    'samplingRate': samplingRate,
  };
}
