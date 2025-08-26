import 'dart:convert';
import 'package:get/get.dart';
import 'package:three_js/three_js.dart' as three;
import 'dart:math' as math;
import '../models/urdf_joint.dart';
import '../models/urdf_robot.dart';
import '../services/talker_service.dart';
import 'main_conroller.dart';

class UrdfController extends GetxController {
  late three.ThreeJS threeJs;
  three.OrbitControls? orbitControls;

  final Rx<URDFRobot?> robot = Rx<URDFRobot?>(null);
  final Map<String, three.Material> _originalMaterials = {};

  // Add initialization state tracking
  final RxBool _isInitialized = false.obs;
  bool get isInitialized => _isInitialized.value;

  // Store pending size updates
  double? _pendingWidth;
  double? _pendingHeight;

  static const List<String> rightArmOrder = [
    "right_shoulder_pitch_joint",
    "right_shoulder_roll_joint",
    "right_shoulder_yaw_joint",
    "right_elbow_joint",
    "right_wrist_roll_joint",
  ];

  static const List<String> leftArmOrder = [
    "left_shoulder_pitch_joint",
    "left_shoulder_roll_joint",
    "left_shoulder_yaw_joint",
    "left_elbow_joint",
    "left_wrist_roll_joint",
  ];

  RxBool disableReceiveJointState = false.obs;
  RxBool cancelMove = false.obs;

  final MainController mainController = Get.find<MainController>();

  @override
  void onInit() {
    super.onInit();
    initThreeJS();
  }

  @override
  void onClose() {
    // Remove resize listener
    orbitControls?.dispose();
    threeJs.dispose();
    three.loading.clear();
    super.onClose();
  }

  void disposeThree() {
    // Clean up resources
    orbitControls?.dispose();
    threeJs.dispose();
    three.loading.clear();
    super.dispose();
  }

  void initThreeJS() {
    threeJs = three.ThreeJS(
      onSetupComplete: () {
        talker.info('===================> ThreeJS setup complete');
        _isInitialized.value = true;

        // Apply any pending size updates
        if (_pendingWidth != null && _pendingHeight != null) {
          _updateSizeInternal(_pendingWidth!, _pendingHeight!);
          _pendingWidth = null;
          _pendingHeight = null;
        }
      },
      setup: setupScene,
      settings: three.Settings(useOpenGL: true, enableShadowMap: false),
    );
  }

  Future<void> setupScene() async {
    try {
      // Setup camera with initial aspect ratio
      threeJs.camera = three.PerspectiveCamera(75, 1.0, 0.01, 1000);
      threeJs.camera.position.setValues(0.8, 0.8, 0.8);

      // Setup scene
      threeJs.scene = three.Scene();
      threeJs.scene.background = three.Color.fromHex32(0xFF1F2733);

      // Setup lighting
      final ambientLight = three.AmbientLight(0xffffff, 0.6);
      threeJs.scene.add(ambientLight);

      final directionalLight = three.DirectionalLight(0xffffff, 0.8);
      directionalLight.position.setValues(5, 10, 5);
      directionalLight.castShadow = true;
      threeJs.scene.add(directionalLight);

      // Setup ground
      final groundGeometry = three.PlaneGeometry(20, 20);
      final groundMaterial = three.MeshLambertMaterial.fromMap({'color': 0xFF171F2B});
      final ground = three.Mesh(groundGeometry, groundMaterial);
      ground.rotation.x = -math.pi / 2;
      ground.position.y = -0.79;
      threeJs.scene.add(ground);

      // Setup camera controls
      orbitControls = three.OrbitControls(threeJs.camera, threeJs.globalKey);
      orbitControls!.enableDamping = true;
      orbitControls!.dampingFactor = 0.05;
      orbitControls!.minDistance = 0.5;
      orbitControls!.maxDistance = 2;
      orbitControls!.target.setValues(0, 0, 0);

      orbitControls!.zoomSpeed = 0.3; // ค่าต่ำ = zoom ช้าและละเอียดขึ้น (default = 1.0)

      // การหมุน
      // orbitControls!.rotateSpeed = 0.5; // ปรับความเร็วการหมุน

      // การเลื่อน
      orbitControls!.panSpeed = 0.8; // ปรับความเร็วการเลื่อน

      talker.info('-------------------------ThreeJS scene setup complete--------------------------');
      // Load URDF robot
      await loadRobot();

      // Animation loop
      threeJs.addAnimationEvent((dt) {
        orbitControls?.update();
        robot.value?.update(dt);
      });
    } catch (e) {
      talker.error('Error in setupScene: $e');
    }
  }

  // Public method that handles timing issues
  void updateSize(double width, double height) {
    if (!_isInitialized.value) {
      // Store the size update for later
      _pendingWidth = width;
      _pendingHeight = height;
      talker.info('ThreeJS not yet initialized, storing size update: ${width}x$height');
      return;
    }

    _updateSizeInternal(width, height);
  }

  // Internal method that actually updates the size
  void _updateSizeInternal(double width, double height) {
    if (threeJs.renderer == null) {
      talker.info('ThreeJS camera or renderer not initialized');
      return;
    }

    if (threeJs.camera is three.PerspectiveCamera) {
      final camera = threeJs.camera as three.PerspectiveCamera;

      // Update camera aspect ratio
      camera.aspect = width / height;
      camera.updateProjectionMatrix();

      // Update renderer size
      threeJs.renderer?.setSize(width, height, false);

      // talker.info('Updated ThreeJS size: ${width}x$height');
    }
  }

  Future<void> loadRobot() async {
    try {
      final newRobot = URDFRobot();
      await newRobot.loadFromURDF('assets/robot/g1/urdf/g1.urdf');

      threeJs.scene.add(newRobot.rootGroup);
      newRobot.rootGroup.rotation.x = -math.pi / 2;

      robot.value = newRobot;
      talker.info('Robot loaded successfully with ${newRobot.links.length} links');
    } catch (e) {
      talker.error('Failed to load robot: $e');
    }
  }

  void highlightJoint(String jointName) {
    if (robot.value == null) return;

    // หา joint ที่เคลื่อนไหว
    final joint = robot.value!.joints.firstWhere((j) => j.name == jointName, orElse: () => robot.value!.joints.first);

    // หา child link
    final childLink = robot.value!.links.firstWhere((link) => link.data.name == joint.child, orElse: () => robot.value!.links.first);

    // เปลี่ยนสีเพื่อเน้น
    if (childLink.mesh != null) {
      final meshName = childLink.data.name;

      // เก็บ material เดิมถ้ายังไม่เคยเก็บ
      if (!_originalMaterials.containsKey(meshName)) {
        _originalMaterials[meshName] = childLink.mesh!.material!;
      }

      // สร้าง highlight material
      final highlightMaterial = three.MeshPhongMaterial.fromMap({'color': 0xFF3BEB, 'transparent': false, 'shininess': 30, 'specular': 0x111111});

      // เปลี่ยน material
      childLink.mesh!.material = highlightMaterial;
    }
  }

  void unhighlightJoint(String jointName) {
    if (robot.value == null) return;

    // หา joint ที่เคลื่อนไหว
    final joint = robot.value!.joints.firstWhere((j) => j.name == jointName, orElse: () => robot.value!.joints.first);

    // หา child link
    final childLink = robot.value!.links.firstWhere((link) => link.data.name == joint.child, orElse: () => robot.value!.links.first);

    // คืนสีเดิม
    if (childLink.mesh != null) {
      final meshName = childLink.data.name;

      // คืน material เดิม
      if (_originalMaterials.containsKey(meshName)) {
        childLink.mesh!.material = _originalMaterials[meshName]!;
      }
    }
  }

  void setJointValue(String jointName, double value) {
    // talker.debug('joint : $jointName value: $value');
    robot.value?.setJointValue(jointName, value);
    robot.refresh(); // Notify observers
  }

  void moveJoint(String jointName, double value) {
    final bool isRight = jointName.startsWith('right_');
    final List<String> order = isRight ? rightArmOrder : leftArmOrder;

    final int idx = order.indexOf(jointName);
    if (idx == -1) {
      talker.warning('ขยับไม่ได้: $jointName ไม่อยู่ในลิสต์ที่อนุญาต');
      return;
    }

    // 1) ดึงค่าปัจจุบันของทุก joint ในแขนข้างนั้น ๆ
    final List<double> leftPositions = leftArmOrder.map<double>((name) => getJointValue(name)).toList();
    final List<double> rightPositions = rightArmOrder.map<double>((name) => getJointValue(name)).toList();

    // 2) ใส่ค่าที่ต้องการขยับทับลงไป
    if (isRight) {
      rightPositions[idx] = value;
    } else {
      leftPositions[idx] = value;
    }

    // 3) ส่งไปหา ROS ผ่าน sendMoveManual
    Map sendMoveManual = {
      "op": "publish",
      "topic": "/move_joint_manual",
      "msg": {
        "data": jsonEncode({"left": leftPositions, "right": rightPositions}),
      },
    };

    mainController.sendData(jsonEncode(sendMoveManual));
  }

  void resetAllJoints() {
    robot.value?.resetJoints();
    robot.refresh(); // Notify observers
  }

  double getJointValue(String jointName) {
    return robot.value?.getJointValue(jointName) ?? 0.0;
  }

  List<URDFJoint> getControllableJoints() {
    return robot.value?.getControllableJoints() ?? [];
  }
}
