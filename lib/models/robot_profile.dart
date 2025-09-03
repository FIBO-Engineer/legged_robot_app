class Profile {
  final String robotType;
  String ip;
  String camera;
  double linearSpeed;
  double angularSpeed;
  double samplingRate;

  Profile({
    required this.robotType,
    required this.ip,
    required this.camera,
    required this.linearSpeed,
    required this.angularSpeed,
    required this.samplingRate,
  });

  factory Profile.fromMap(Map<String, dynamic> m) => Profile(
    robotType: (m['robotType'] ?? m['robType'] ?? '') as String,
    ip: (m['ip'] ?? '') as String,
    camera: (m['camera'] ?? '') as String,
    linearSpeed: ((m['linearSpeed'] ?? m['linear'] ?? 0.0) as num).toDouble(),
    angularSpeed:
        ((m['angularSpeed'] ?? m['angular'] ?? 0.0) as num).toDouble(),
    samplingRate: ((m['samplingRate'] ?? m['sample'] ?? 0.0) as num).toDouble(),
  );

  Map<String, dynamic> toMap() => {
    'robotType': robotType,
    'ip': ip,
    'camera': camera,
    'linearSpeed': linearSpeed,
    'angularSpeed': angularSpeed,
    'samplingRate': samplingRate,
  };
}

List<Profile> defaultProfiles() => [
  Profile(
    robotType: 'G1',
    ip: 'ws://0.0.0.1:1',
    camera: 'http://000.0000:920',
    linearSpeed: 0.5,
    angularSpeed: 1.0,
    samplingRate: 0.1,
  ),
  Profile(
    robotType: 'H1',
    ip: '',
    camera: '',
    linearSpeed: 0.2,
    angularSpeed: 1.0,
    samplingRate: 0.1,
  ),
  Profile(
    robotType: 'Go2',
    ip: '',
    camera: '',
    linearSpeed: 0.3,
    angularSpeed: 1.0,
    samplingRate: 0.1,
  ),
  Profile(
    robotType: 'B2W',
    ip: '',
    camera: '',
    linearSpeed: 0.4,
    angularSpeed: 1.0,
    samplingRate: 0.1,
  ),
];
