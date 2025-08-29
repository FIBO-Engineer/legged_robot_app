import 'dart:convert';
import 'package:flutter/widgets.dart';
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

  // Track current orientation for proper handling
  Orientation? _lastOrientation;
  final RxBool _isResizing = false.obs;

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
    orbitControls?.dispose();
    threeJs.dispose();
    three.loading.clear();
    super.onClose();
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
      
      // Set initial camera position based on orientation
      _setCameraPositionForOrientation();

      // Setup scene
      threeJs.scene = three.Scene();
     threeJs.scene.background = three.Color.fromHex32(0xFF171F2B);

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
      _setupOrbitControls();

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

  void _setCameraPositionForOrientation() {
    // Set different camera positions for different orientations
    if (_lastOrientation == Orientation.portrait) {
      // Portrait: camera further back to see full robot
      threeJs.camera.position.setValues(1.2, 1.2, 1.2);
    } else {
      // Landscape: closer camera position
      threeJs.camera.position.setValues(0.8, 0.8, 0.8);
    }
  }

  void _setupOrbitControls() {
    if (orbitControls != null) {
      orbitControls!.dispose();
    }
    
    orbitControls = three.OrbitControls(threeJs.camera, threeJs.globalKey);
    orbitControls!.enableDamping = true;
    orbitControls!.dampingFactor = 0.05;
    
    // Adjust min/max distance based on orientation
    if (_lastOrientation == Orientation.portrait) {
      orbitControls!.minDistance = 0.8;
      orbitControls!.maxDistance = 3.0;
    } else {
      orbitControls!.minDistance = 0.5;
      orbitControls!.maxDistance = 2.0;
    }
    
    orbitControls!.target.setValues(0, 0, 0);
    orbitControls!.zoomSpeed = 0.3;
    orbitControls!.panSpeed = 0.8;
    
    talker.info('OrbitControls setup for orientation: $_lastOrientation');
  }

  // Enhanced update size method with orientation handling
  void updateSize(double width, double height, {Orientation? orientation}) {
    talker.info('📐 updateSize called: ${width}x$height, orientation: $orientation');
    
    // Track orientation change
    if (orientation != null && orientation != _lastOrientation) {
      talker.info('🔄 Orientation changed from $_lastOrientation to $orientation');
      _lastOrientation = orientation;
    }

    if (!_isInitialized.value) {
      _pendingWidth = width;
      _pendingHeight = height;
      talker.info('ThreeJS not yet initialized, storing size update');
      return;
    }

    _updateSizeInternal(width, height);
  }

  void _updateSizeInternal(double width, double height) {
    if (_isResizing.value) {
      talker.info('Already resizing, skipping duplicate update');
      return;
    }

    _isResizing.value = true;

    try {
      if (threeJs.renderer == null || threeJs.camera == null) {
        talker.error('ThreeJS renderer or camera not initialized');
        return;
      }

      if (threeJs.camera is three.PerspectiveCamera) {
        final camera = threeJs.camera as three.PerspectiveCamera;

        // Calculate aspect ratio
        final newAspect = width / height;
        talker.info('📊 Updating camera aspect: $newAspect (${width}x$height)');

        // Update camera
        camera.aspect = newAspect;
        camera.updateProjectionMatrix();

        // Update renderer size
        threeJs.renderer?.setSize(width, height, false);

        // Reconfigure OrbitControls for new aspect ratio
        if (orbitControls != null) {
          // Adjust controls based on aspect ratio
          if (newAspect < 1.0) {
            // Portrait mode - adjust zoom and distance
            orbitControls!.minDistance = 0.8;
            orbitControls!.maxDistance = 3.0;
          } else {
            // Landscape mode
            orbitControls!.minDistance = 0.5;
            orbitControls!.maxDistance = 2.0;
          }

          // Reset camera position if aspect ratio changed significantly
          if (_lastOrientation != null) {
            _setCameraPositionForOrientation();
            orbitControls!.update();
          }
        }

        talker.info('✅ Size update completed successfully');
      }
    } finally {
      // Reset resizing flag after a brief delay
      Future.delayed(Duration(milliseconds: 100), () {
        _isResizing.value = false;
      });
    }
  }

  // Add method to handle orientation changes specifically
  void handleOrientationChange(Orientation newOrientation) {
    if (newOrientation != _lastOrientation) {
      talker.info('🔄 Handling orientation change to: $newOrientation');
      _lastOrientation = newOrientation;
      
      if (_isInitialized.value) {
        // Reconfigure camera and controls for new orientation
        _setCameraPositionForOrientation();
        _setupOrbitControls();
        
        // Force a size update
        if (_pendingWidth != null && _pendingHeight != null) {
          _updateSizeInternal(_pendingWidth!, _pendingHeight!);
        }
      }
    }
  }

  // Add method to reset camera view
  void resetCameraView() {
    if (threeJs.camera != null && orbitControls != null) {
      talker.info('🎯 Resetting camera view');
      
      _setCameraPositionForOrientation();
      orbitControls!.target.setValues(0, 0, 0);
      orbitControls!.update();
      
      talker.info('✅ Camera view reset completed');
    }
  }

  Future<void> loadRobot() async {
    try {
      // Clear existing robot
      if (robot.value != null) {
        threeJs.scene.remove(robot.value!.rootGroup);
      }

      final newRobot = URDFRobot();
      await newRobot.loadFromURDF('assets/robot/g1/urdf/g1.urdf');

      threeJs.scene.add(newRobot.rootGroup);
      newRobot.rootGroup.rotation.x = -math.pi / 2;

      robot.value = newRobot;
      talker.info('Robot loaded successfully with ${newRobot.links.length} links');
      
      // Reset camera after loading robot
      Future.delayed(Duration(milliseconds: 500), () {
        resetCameraView();
      });
    } catch (e) {
      talker.error('Failed to load robot: $e');
    }
  }

  // Rest of your existing methods...
  void highlightJoint(String jointName) {
    if (robot.value == null) return;

    final joint = robot.value!.joints.firstWhere((j) => j.name == jointName, orElse: () => robot.value!.joints.first);
    final childLink = robot.value!.links.firstWhere((link) => link.data.name == joint.child, orElse: () => robot.value!.links.first);

    if (childLink.mesh != null) {
      final meshName = childLink.data.name;

      if (!_originalMaterials.containsKey(meshName)) {
        _originalMaterials[meshName] = childLink.mesh!.material!;
      }

      final highlightMaterial = three.MeshPhongMaterial.fromMap({'color':  0xFF171F2B, 'transparent': false, 'shininess': 30, 'specular': 0x111111});
      childLink.mesh!.material = highlightMaterial;
    }
  }

  void unhighlightJoint(String jointName) {
    if (robot.value == null) return;

    final joint = robot.value!.joints.firstWhere((j) => j.name == jointName, orElse: () => robot.value!.joints.first);
    final childLink = robot.value!.links.firstWhere((link) => link.data.name == joint.child, orElse: () => robot.value!.links.first);

    if (childLink.mesh != null) {
      final meshName = childLink.data.name;

      if (_originalMaterials.containsKey(meshName)) {
        childLink.mesh!.material = _originalMaterials[meshName]!;
      }
    }
  }

  void setJointValue(String jointName, double value) {
    robot.value?.setJointValue(jointName, value);
    robot.refresh();
  }

  void moveJoint(String jointName, double value) {
    final bool isRight = jointName.startsWith('right_');
    final List<String> order = isRight ? rightArmOrder : leftArmOrder;

    final int idx = order.indexOf(jointName);
    if (idx == -1) {
      talker.warning('ขยับไม่ได้: $jointName ไม่อยู่ในลิสต์ที่อนุญาต');
      return;
    }

    final List<double> leftPositions = leftArmOrder.map<double>((name) => getJointValue(name)).toList();
    final List<double> rightPositions = rightArmOrder.map<double>((name) => getJointValue(name)).toList();

    if (isRight) {
      rightPositions[idx] = value;
    } else {
      leftPositions[idx] = value;
    }

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
    robot.refresh();
  }

  double getJointValue(String jointName) {
    return robot.value?.getJointValue(jointName) ?? 0.0;
  }

  List<URDFJoint> getControllableJoints() {
    return robot.value?.getControllableJoints() ?? [];
  }
}