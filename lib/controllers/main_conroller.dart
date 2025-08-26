import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:legged_robot_app/services/toast_service.dart';
import 'package:toastification/toastification.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/robot_profile.dart';
import '../services/talker_service.dart';
import 'urdf_controller.dart';

class MainController extends GetxController {
  WebSocketChannel? channel;
  Timer? _heartbeatTimer;
  RxString connectionRos = 'Disconnected'.obs;
  RxBool disconnect = true.obs;

  final Map<String, int> jointIndexMap = {
    "left_hip_pitch_joint": 0,
    "left_hip_roll_joint": 1,
    "left_hip_yaw_joint": 2,
    "left_knee_joint": 3,
    "left_ankle_pitch_joint": 4,
    "left_ankle_roll_joint": 5,
    "right_hip_pitch_joint": 6,
    "right_hip_roll_joint": 7,
    "right_hip_yaw_joint": 8,
    "right_knee_joint": 9,
    "right_ankle_pitch_joint": 10,
    "right_ankle_roll_joint": 11,
    "waist_yaw_joint": 12,
    "left_shoulder_pitch_joint": 13,
    "left_shoulder_roll_joint": 14,
    "left_shoulder_yaw_joint": 15,
    "left_elbow_joint": 16,
    "left_wrist_roll_joint": 17,
    "right_shoulder_pitch_joint": 18,
    "right_shoulder_roll_joint": 19,
    "right_shoulder_yaw_joint": 20,
    "right_elbow_joint": 21,
    "right_wrist_roll_joint": 22,
  };
  RxList postures =
      <String>[
        // 'stand',
        // 'sit',
        // 'lay',
        // 'walk',
        // 'run',
        // 'jump',
        // 'dance',
        // 'wave',
        // 'greet',
        // 'pick_up',
        // 'drop_off',
        // 'turn_left',
        // 'turn_right',
        // 'set_continuous_movement',
      ].obs;

  RxList command =
      <String>[
        // "/robot_mover/stand",
        // "/robot_mover/sit",
        // "robot_mover/set_continuous_movement",
        // "robot_mover/set_continuous_movement_test_in_fibonaci",
      ].obs;
  RxBool isHide = false.obs;
  RxInt speedLevel = 0.obs;

  /*------------------------------ Setting --------------------------------------*/
  final box = GetStorage('setting');
  final profiles = <Profile>[].obs;
  final selectedIndex = 0.obs;

  final Rx<TextEditingController> ipWebSocket =
      TextEditingController(text: '').obs;
  final Rx<TextEditingController> ipCamera =
      TextEditingController(text: '').obs;

  final RxString robotType = ''.obs;
  final RxDouble samplingRate = 0.0.obs;
  final RxDouble angularSpeed = 0.0.obs;
  final RxDouble linearSpeed = 0.0.obs;

  Profile get current =>
      profiles.isEmpty
          ? defaultProfiles().first
          : profiles[selectedIndex.value];

  // Observable variables
  RxBool showLayer = false.obs;
  var showGlobalCostmap = false.obs;
  var showLocalCostmap = false.obs;
  var showLaser = false.obs;
  var showPointCloud = false.obs;
  RxBool showRelocation = false.obs;
  RxBool showCamera = true.obs;
  RxBool showJoy = true.obs;

  @override
  void onInit() async {
    await GetStorage.init('setting');
    try {
      _loadProfiles();
    } catch (e, st) {
      talker.handle(e, st, 'main controller / onInit');
    }
    super.onInit();
  }

  /*------------------------------ Websocket--------------------------------------*/

  void reDisconnectAndConnect() async {
    talker.info('reDisconnectAndConnect');
    await disconnectRobot();
    await Future.delayed(const Duration(seconds: 1));
    connectRobot();
  }

  Future disconnectRobot() async {
    disconnect.value = true;
    connectionRos.value = 'Disconnected';

    channel?.sink.close();
    channel = null;
  }

  void connectRobot() {
    disconnect.value = false;
    connectWS();
  }

  Future connectWS() async {
    try {
      // talker.info('connect_ws ');

      if (channel != null) {
        talker.warning('connect_ws_already_connected ');
        return;
      }

      connectionRos.value = 'Connecting';
      talker.info('connect_ws ${ipWebSocket.value.text}');

      channel = WebSocketChannel.connect(Uri.parse(ipWebSocket.value.text));

      await channel!.ready;

      connectionRos.value = 'Connected';
      channel!.stream.listen(
        (data) async {
          if (data is String) {
            Map decodeData = jsonDecode(data);

            switch (decodeData['op']) {
              case 'publish':
                try {
                  handlePublish(decodeData);
                } catch (e, st) {
                  talker.handle(e, st, 'ros_publish  $data');
                }
                break;
              case 'service_response':
                try {
                  // handleServiceResponse(decodeData);
                  if (decodeData['values']['success']) {
                    ToastService.showToast(
                      title: 'Response ${decodeData['service']}',
                      description: '${decodeData['values']['message']}',
                      type: ToastificationType.info,
                    );
                  } else {
                    talker.warning('Service Response: $decodeData');
                  }
                  // talker.warning('Service Response: $decodeData');

                  // if (decodeData['id'] == 'audio') {
                  //   if (decodeData['values']['success']) {
                  //     final MicController micController = Get.find<MicController>();
                  //     micController.playAudio(decodeData['values']['message']);
                  //     // talker.info(decodeData);
                  //     talker.info('audio res.');
                  //   } else {
                  //     talker.error('Service Response: ${decodeData['values']}');
                  //     ToastService.showToast(title: 'ผิดพลาด', description: '${decodeData['values']}', type: ToastificationType.error);
                  //   }
                  // }

                  // talker.debug('ros_service_response $data');
                } catch (e, st) {
                  talker.handle(e, st, 'ros_service_response ');
                }

                break;
              case 'call_service':
                try {
                  talker.debug('ros_call_service $data ');
                } catch (e, st) {
                  talker.handle(e, st, 'ros_publish ');
                }
                break;

              default:
                // _log('tryConnect()', 'Listen Data (default)', '$decodeData');
                talker.warning('ros_out_topic $data');
                break;
            }
          } else {
            talker.warning('Unknown message type received $data');
          }

          // talker.info('listen: ${jsonDecode(data)}');
        },
        onDone: () async {
          connectionRos.value = 'Disconnected';
          talker.error('ros_done ');
          resetReconnect();
        },
        onError: (e, st) async {
          talker.handle(e, st, 'ros_error ');
          connectionRos.value = 'Disconnected';
          resetReconnect();
        },
        cancelOnError: true,
      );
      startHeartbeat();
      statusRobot();
    } catch (e, st) {
      connectionRos.value = 'Disconnected';
      talker.handle(e, st, 'ros_crash');
      resetReconnect();
    }
  }

  void startHeartbeat() async {
    Map data = {
      "op": "publish",
      "topic": "/heartbeat_web",
      "msg": {"data": true},
    };
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (channel != null) {
        // talker.info('startHeartbeat');
        channel!.sink.add(jsonEncode(data));
      }
    });
  }

  void statusRobot() async {
    Map advertiseMoveJoint = {
      "op": "advertise",
      "topic": "/move_joint_manual",
      "type": "std_msgs/msg/String",
    };
    sendData(jsonEncode(advertiseMoveJoint));

    await Future.delayed(const Duration(milliseconds: 100));

    Map publishJoyStick = {
      "op": "advertise",
      "topic": "/cmd_vel",
      "type": "geometry_msgs/Twist",
    };
    sendData(jsonEncode(publishJoyStick));

    await Future.delayed(const Duration(milliseconds: 100));

    Map advertiseSpeech = {
      "op": "advertise",
      "topic": "/speech_input",
      "type": "std_msgs/msg/String",
    };
    sendData(jsonEncode(advertiseSpeech));

    await Future.delayed(const Duration(milliseconds: 100));

    //------------- subscribe topics -------------
    Map textAi = {
      "op": "subscribe",
      "topic": "/agent_reasoning",
      "type": "std_msgs/msg/String",
    };
    sendData(jsonEncode(textAi));

    await Future.delayed(const Duration(milliseconds: 100));

    Map cmdList = {
      "op": "subscribe",
      "topic": "/robot_mover/unitree_high_level_cmd_list",
      "type": "std_msgs/msg/String",
      "throttle_rate": 5000,
    };
    sendData(jsonEncode(cmdList));

    await Future.delayed(const Duration(milliseconds: 100));

    Map cmdMover = {
      "op": "subscribe",
      "topic": "/robot_mover/response_loco",
      "type": "std_msgs/msg/String",
      "throttle_rate": 1000,
    }; //status robot
    sendData(jsonEncode(cmdMover));

    await Future.delayed(const Duration(milliseconds: 100));

    Map cmdCapture = {
      "op": "subscribe",
      "topic": "/g1_left_arms_joint_state_publisher/arms_postures_list",
      "type": "std_msgs/msg/String",
      "throttle_rate": 1000,
    };
    sendData(jsonEncode(cmdCapture));

    await Future.delayed(const Duration(milliseconds: 100));

    Map cmdReadJoint = {
      "op": "subscribe",
      "topic": "/joint_states",
      "type": "sensor_msgs/msg/JointState",
      "throttle_rate": 100,
    };
    sendData(jsonEncode(cmdReadJoint));

    Map subScribeAudio = {
      "op": "subscribe",
      "topic": "/agent_audio_gen",
      "type": "std_msgs/msg/String",
      "throttle_rate": 1000,
    }; //status robot
    sendData(jsonEncode(subScribeAudio));

    await Future.delayed(const Duration(milliseconds: 100));

    Map humanoidArmControl = {
      "op": "call_service",
      "service": "/humanoid_arm_control/run_manipulator",
      "type": "std_srvs/srv/SetBool",
      "args": {"data": false},
    };
    sendData(jsonEncode(humanoidArmControl));
  }

  void resetReconnect() async {
    if (disconnect.value) return;

    if (channel != null) {
      channel!.sink.close();
      channel = null;
    }
    await Future.delayed(const Duration(seconds: 3));
    connectWS();
  }

  void sendData(String data) {
    try {
      if (channel != null) {
        // ตัดข้อความให้เหลือ 30 ตัวอักษร
        final truncatedData =
            data.length > 80 ? '${data.substring(0, 80)}...' : data;
        talker.debug('ros_send $truncatedData');
        channel!.sink.add(data);
      } else {
        final truncatedData =
            data.length > 80 ? '${data.substring(0, 80)}...' : data;
        talker.warning('ros_send_not_ready $truncatedData');
      }
    } catch (e, st) {
      talker.handle(e, st, 'ros_send_data');
    }
  }

  void handlePublish(Map data) {
    final UrdfController urdfController = Get.find<UrdfController>();

    switch (data['topic']) {
      case '/joint_states':
        try {
          if (urdfController.disableReceiveJointState.value) {
            // talker.info('Joint states updates are disabled');
            return;
          }

          final msg = data['msg'];
          final List<dynamic> positions = msg['position'] ?? [];

          // เก็บเฉพาะค่าที่เปลี่ยนแปลง
          Map<String, double> changedValues = {};

          jointIndexMap.forEach((jointName, index) {
            if (index < positions.length) {
              final double newValue = positions[index].toDouble();
              final double currentValue = urdfController.getJointValue(
                jointName,
              );

              // ตรวจสอบการเปลี่ยนแปลงด้วย tolerance
              if ((newValue - currentValue).abs() > 0.001) {
                changedValues[jointName] = newValue;
              }
            }
          });

          // เซ็ตเฉพาะค่าที่เปลี่ยนแปลง
          if (changedValues.isNotEmpty) {
            changedValues.forEach((jointName, value) {
              urdfController.setJointValue(jointName, value);
            });

            // Optional: Log จำนวนค่าที่เปลี่ยน (สำหรับ debug)
            // talker.info('Updated ${changedValues.length} joints');
          }
        } catch (e) {
          talker.error('Error handling joint_states: $e');
        }
        break;

      case '/g1_left_arms_joint_state_publisher/arms_postures_list':
        try {
          final msg = data['msg'];
          final dataStr = msg['data'];

          if (dataStr is String) {
            final decoded = jsonDecode(dataStr);
            final postureList = decoded['postures'];

            if (postureList is List) {
              final newPostures = List<String>.from(postureList);
              if (!listEquals(postures, newPostures)) {
                postures.value = newPostures;
              }
            }
          }
        } catch (e) {
          talker.error('Error handling arms_postures_list: $e');
        }
        break;

      case '/robot_mover/unitree_high_level_cmd_list':
        try {
          final msg = data['msg'];
          final dataStr = msg['data'];

          if (dataStr is String) {
            final decoded = jsonDecode(dataStr);
            final servicesList = decoded['services'];

            if (servicesList is List) {
              final newCommands = List<String>.from(servicesList);
              if (!listEquals(command, newCommands)) {
                command.value = newCommands;
              }
            }
          }
        } catch (e) {
          talker.error('Error handling unitree_high_level_cmd_list: $e');
        }
        break;

      // case '/agent_audio_gen':
      //   try {
      //     final MicController micController = Get.find<MicController>();
      //     // talker.info('ros_agent_audio_gen ${data['msg']['data']}');
      //     if (audioPlayAtWeb.value == false) {
      //       talker.info('Audio generation is disabled at web');
      //       micController.isWaitAndPlaying.value = false;
      //       return;
      //     }

      //     talker.warning('-------------------------> Receive Audio');

      //     micController.playAudio(data['msg']['data']);

      //     // if (decodeData['values']['success']) {
      //     //   final MicController micController = Get.find<MicController>();
      //     //   micController.playAudio(decodeData['values']['message']);
      //     //   // talker.info(decodeData);
      //     //   talker.info('audio res.');
      //     // } else {
      //     //   talker.error('Service Response: ${decodeData['values']}');
      //     //   ToastService.showToast(title: 'ผิดพลาด', description: '${decodeData['values']}', type: ToastificationType.error);
      //     // }
      //   } catch (e, st) {
      //     talker.handle(e, st, 'ros_agent_audio_gen');
      //   }
      //   break;

      case '/agent_reasoning':
        try {
          // Map data = {op: publish, topic: /agent_reasoning, msg: {data: {"task_type": "general_question", "reasoning_steps": [{"type": "thought", "content": "\u0e1c\u0e39\u0e49\u0e43\u0e0a\u0e49\u0e15\u0e49\u0e2d\u0e07\u0e01\u0e32\u0e23: \u0e27\u0e31\u0e19\u0e19\u0e35\u0e49\u0e27\u0e31\u0e19\u0e2d\u0e30\u0e25\u0e31\u0e22", "step_number": 1}, {"type": "thought", "content": "\u0e1b\u0e23\u0e30\u0e40\u0e20\u0e17\u0e07\u0e32\u0e19: general_question", "step_number": 2}, {"type": "thought", "content": "\u0e19\u0e35\u0e48\u0e40\u0e1b\u0e47\u0e19\u0e04\u0e33\u0e16\u0e32\u0e21\u0e17\u0e31\u0e48\u0e27\u0e44\u0e1b", "step_number": 3}, {"type": "action", "content": "\u0e15\u0e2d\u0e1a\u0e42\u0e14\u0e22\u0e43\u0e0a\u0e49\u0e04\u0e27\u0e32\u0e21\u0e23\u0e39\u0e49\u0e17\u0e31\u0e48\u0e27\u0e44\u0e1b", "tool": null, "step_number": 4}, {"type": "conclusion", "content": "\u0e15\u0e2d\u0e1a\u0e04\u0e33\u0e16\u0e32\u0e21\u0e17\u0e31\u0e48\u0e27\u0e44\u0e1b\u0e40\u0e23\u0e35\u0e22\u0e1a\u0e23\u0e49\u0e2d\u0e22", "step_number": 5}], "final_answer": "\u0e27\u0e31\u0e19\u0e19\u0e35\u0e49\u0e40\u0e1b\u0e47\u0e19\u0e27\u0e31\u0e19\u0e1e\u0e38\u0e18\u0e04\u0e48\u0e30", "step_count": 5, "timestamp": "/home/fibo/winworkspace/HumanoidAgent"}}};

          final String reasoningData = data['msg']['data'];
          final Map<String, dynamic> reasoningMap = jsonDecode(reasoningData);

          String finalAnswer = reasoningMap['final_answer'] ?? '';
          List<dynamic> reasoningSteps = reasoningMap['reasoning_steps'] ?? [];
          String stepsDescription = reasoningSteps
              .map((step) => "${step['step_number']}. ${step['content']}")
              .join('\n');

          ToastService.showToast(
            title: finalAnswer, // หรือจะเป็น "สรุปคำตอบ" ก็ได้
            description: stepsDescription, // รายละเอียด reasoning steps
            type: ToastificationType.success,
            duration: Duration(seconds: 30),
          );

          // talker.warning('agent_reasoning $reasoningMap');
        } catch (e, st) {
          talker.handle(e, st, 'agent_reasoning');
        }
        break;

      case '/robot_mover/response_loco':
        break;

      default:
        talker.warning('ros_service_response $data');
        break;
    }
  }

  /*------------------------------ Settings --------------------------------------*/
  void _loadProfiles() {
    final raw = (box.read<List>('profiles') ?? []);
    final migrated =
        raw.map((e) {
          final m = Map<String, dynamic>.from(e);
          if (m.containsKey('robType') && !m.containsKey('robotType')) {
            m['robotType'] = m.remove('robType');
          }
          return m;
        }).toList();

    profiles.assignAll(migrated.map(Profile.fromMap).toList());

    if (profiles.isEmpty) {
      profiles.assignAll(defaultProfiles());
      selectedIndex.value = 0;
      _persistProfiles();
    } else {
      final idx = (box.read('selectedIndex') ?? 0) as int;
      selectedIndex.value = idx.clamp(0, profiles.length - 1);
    }

    if (migrated.length == raw.length &&
        raw.any((e) => (e as Map).containsKey('robType'))) {
      _persistProfiles();
    }

    ever<int>(selectedIndex, (_) => _pullFromCurrent());
    _pullFromCurrent();
  }

  void _pullFromCurrent() {
    if (profiles.isEmpty) return;
    final p = current;
    robotType.value = p.robotType;
    ipWebSocket.value.text = p.ip;
    ipCamera.value.text = p.camera;
    linearSpeed.value = p.linearSpeed;
    angularSpeed.value = p.angularSpeed;
    samplingRate.value = p.samplingRate;
    _persistScalars();
  }

  void saveCurrent() {
    if (profiles.isEmpty) return;
    final p =
        current
          ..ip = ipWebSocket.value.text.trim()
          ..camera = ipCamera.value.text.trim()
          ..linearSpeed = linearSpeed.value
          ..angularSpeed = angularSpeed.value
          ..samplingRate = samplingRate.value;

    profiles[selectedIndex.value] = p;
    profiles.refresh();
    _persistProfiles();
    _persistScalars();

    ToastService.showToast(
      title: 'Success',
      description: 'Settings saved successfully',
      type: ToastificationType.success,
    );
  }

  void resetToDefault() {
    final def = defaultProfiles().firstWhere(
      (e) => e.robotType == robotType.value,
      orElse: () => defaultProfiles().first,
    );
    profiles[selectedIndex.value] = Profile.fromMap(def.toMap());
    profiles.refresh();
    _pullFromCurrent();
    _persistProfiles();
  }

  void selectRobot(int idx) {
    if (idx < 0 || idx >= profiles.length) return;
    selectedIndex.value = idx;
    box.write('selectedIndex', idx);
    reDisconnectAndConnect();
  }

  void _persistProfiles() =>
      box.write('profiles', profiles.map((e) => e.toMap()).toList());

  void _persistScalars() {
    box.write('selectedIndex', selectedIndex.value);
    box.write('robotType', robotType.value);
    box.write('ip', ipWebSocket.value.text);
    box.write('camera', ipCamera.value.text);
    box.write('linearSpeed', linearSpeed.value);
    box.write('angularSpeed', angularSpeed.value);
    box.write('samplingRate', samplingRate.value);
  }

  /*------------------------------ Others--------------------------------------*/
  void toggleLayer() {
    showLayer.value = !showLayer.value;
  }

  void toggleGlobalCostmap() {
    showGlobalCostmap.value = !showGlobalCostmap.value;
  }

  void toggleLocalCostmap() {
    showLocalCostmap.value = !showLocalCostmap.value;
  }

  void toggleLaser() {
    showLaser.value = !showLaser.value;
  }

  void togglePointCloud() {
    showPointCloud.value = !showPointCloud.value;
  }

  void toggleRelocation() {
    showRelocation.value = !showRelocation.value;
  }

  void toggleCamera() {
    showCamera.value = !showCamera.value;
  }

  void toggleJoy() {
    showJoy.value = !showJoy.value;
  }

  RxDouble mapResolution = 0.05.obs;
  double get pxPerMeter => 1.0 / mapResolution.value;

  Rx<Offset> robotMeters = Offset.zero.obs;
  RxDouble robotYaw = 0.0.obs;

  final TransformationController mapTC = TransformationController();
  final GlobalKey mapAreaKey = GlobalKey();
  final double mapMinScale = 0.4;
  final double mapMaxScale = 10.0;

  RxBool followRobot = false.obs;

  void toggleFollow() {
    followRobot.value = !followRobot.value;
    if (followRobot.value) {
      recenterOnRobot();
    }
  }

  void zoomBy(double factor) {
    final ctx = mapAreaKey.currentContext;
    final box = ctx?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final center = box.size.center(Offset.zero);

    final current = mapTC.value.getMaxScaleOnAxis();
    final target = (current * factor).clamp(mapMinScale, mapMaxScale);
    final safeFactor = target / current;

    final m =
        Matrix4.copy(mapTC.value)
          // ignore: deprecated_member_use
          ..translate(center.dx, center.dy)
          // ignore: deprecated_member_use
          ..scale(safeFactor)
          // ignore: deprecated_member_use
          ..translate(-center.dx, -center.dy);
    mapTC.value = m;

    if (followRobot.value) recenterOnRobot();
  }

  void recenterOnRobot() {
    final ctx = mapAreaKey.currentContext;
    final box = ctx?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final center = box.size.center(Offset.zero);
    final scale = mapTC.value.getMaxScaleOnAxis();

    final px = Offset(
      robotMeters.value.dx * pxPerMeter,
      robotMeters.value.dy * pxPerMeter,
    );

    mapTC.value =
        Matrix4.identity()
          // ignore: deprecated_member_use
          ..translate(center.dx, center.dy)
          // ignore: deprecated_member_use
          ..scale(scale)
          // ignore: deprecated_member_use
          ..translate(-px.dx, -px.dy);
  }
}
