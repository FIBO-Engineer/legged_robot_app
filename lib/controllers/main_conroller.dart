import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:legged_robot_app/services/toast_service.dart';
import 'package:toastification/toastification.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../services/talker_service.dart';

class MainController extends GetxController {
  WebSocketChannel? channel;
  Timer? _heartbeatTimer;
  RxBool disconnect = true.obs;
  RxString connectionRos = 'Disconnected'.obs;

  /*------------------------------ Setting --------------------------------------*/
  final box = GetStorage('app');
  final profiles = <Map<String, dynamic>>[].obs;
  final Rx<TextEditingController> ipWebSocket =
      TextEditingController(text: '').obs; //'wss://192.168.123.99:8002'
  final Rx<TextEditingController> ipCamera =
      TextEditingController(text: '').obs; //https://192.168.123.99:8889/d455f/
  final RxString robotType = ''.obs;
  final selectedIndex = 0.obs;
  final RxDouble samplingRate = 0.0.obs;
  final RxDouble angularSpeed = 0.0.obs;
  final RxDouble linearSpeed = 0.0.obs;

  static const kProfiles = 'profiles';
  static const kSelected = 'selectedIndex';
  static const kRobotType = 'robotType';
  static const kIp = 'ip';
  static const kCamera = 'camera';
  static const kLinear = 'linearSpeed';
  static const kAngular = 'angularSpeed';
  static const kSample = 'samplingRate';

  List<Map<String, dynamic>> _defaultProfiles() => [
    {
      'robType': 'G1',
      'ip': 'ws://0.0.0.1:1',
      'camera': 'http://000.0000:920',
      'linearSpeed': 0.5,
      'angularSpeed': 1.0,
      'samplingRate': 0.1,
    },
    {
      'robType': 'H1',
      'ip': 'ws://0.0.0.1:2',
      'camera': 'http://000.0000:930',
      'linearSpeed': 0.2,
      'angularSpeed': 1.0,
      'samplingRate': 0.1,
    },
    {
      'robType': 'B1',
      'ip': 'ws://0.0.0.1:3',
      'camera': 'http://000.0000:930',
      'linearSpeed': 0.3,
      'angularSpeed': 1.0,
      'samplingRate': 0.1,
    },
    {
      'robType': 'B1W',
      'ip': 'ws://0.0.0.1:4',
      'camera': 'http://000.0000:930',
      'linearSpeed': 0.4,
      'angularSpeed': 1.0,
      'samplingRate': 0.1,
    },
  ];

  /*------------------------------ Services --------------------------------------*/
  GetStorage boxService = GetStorage('Storage');
  RxList<TextEditingController> textControllerArgs =
      [TextEditingController()].obs;
  RxList<TextEditingController> textControllerData =
      [TextEditingController()].obs;
  Rx<TextEditingController> serviceTextField = TextEditingController().obs;
  Rx<TextEditingController> labelTextField = TextEditingController().obs;
  RxInt args = 1.obs;
  RxInt data = 1.obs;
  final RxInt editIndex = (-1).obs;
  RxBool addCard = false.obs;
  RxBool editCard = false.obs;
  RxBool isPublish = false.obs;
  RxMap cardData = {}.obs;
  final RxList<String> topics = <String>['Publish', 'CallService'].obs;
  RxList<dynamic> cards = <dynamic>[].obs;
  RxList<dynamic> resetCards =
      <dynamic>[
        {
          "args": {"data": false},
          "label": "Stop Playing",
          "service": "/media_player/stop",
          "isPublish": false,
        },
        {
          "args": {"data": true},
          "label": "invite right",
          "service": "/dynamixel_operator/z_invite_r",
          "isPublish": false,
        },
        {
          "args": {"filename": "im yours.mp3", "override": "true"},
          "label": "im_yours",
          "service": "/play",
          "isPublish": "false",
        },
        {
          "args": {"text": "hello", "override": "true"},
          "label": "speak hello",
          "service": "/speak",
          "isPublish": "false",
        },
      ].obs;

  @override
  void onInit() async {
    super.onInit();
    await GetStorage.init('app');
    try {
      if (boxService.read('cards') == null) {
        boxService.write('cards', <dynamic>[]);
      } else {
        cards.value = boxService.read('cards');
      }

      initProfile();
    } catch (e, st) {
      talker.handle(e, st, 'main controller / onInit ');
    }
  }

  void initProfile() {
    final raw = box.read<List>(kProfiles) ?? [];
    profiles.assignAll(raw.map((e) => Map<String, dynamic>.from(e)));

    selectedIndex.value = (box.read(kSelected) ?? 0) as int;
    if (profiles.isNotEmpty) {
      selectedIndex.value = selectedIndex.value.clamp(0, profiles.length - 1);
    } else {
      profiles.assignAll(_defaultProfiles());
      selectedIndex.value = 0;
      _persistProfiles();
    }

    robotType.value = (box.read(kRobotType) ?? '') as String;
    ipWebSocket.value.text = (box.read(kIp) ?? '') as String;
    ipCamera.value.text = (box.read(kCamera) ?? '') as String;
    linearSpeed.value = ((box.read(kLinear) ?? 0.0) as num).toDouble();
    angularSpeed.value = ((box.read(kAngular) ?? 0.0) as num).toDouble();
    samplingRate.value = ((box.read(kSample) ?? 0.0) as num).toDouble();

    ever<int>(selectedIndex, (_) => _applySelectionToFields());

    _applySelectionToFields();
  }

  void _applySelectionToFields() {
    if (profiles.isEmpty) return;
    final p = profiles[selectedIndex.value.clamp(0, profiles.length - 1)];
    robotType.value = (p['robType'] ?? '') as String;
    ipWebSocket.value.text = (p['ip'] ?? '') as String;
    ipCamera.value.text = (p['camera'] ?? '') as String;
    linearSpeed.value = ((p['linearSpeed'] ?? 0.0) as num).toDouble();
    angularSpeed.value = ((p['angularSpeed'] ?? 0.0) as num).toDouble();
    samplingRate.value = ((p['samplingRate'] ?? 0.0) as num).toDouble();

    _persistScalars();
  }

  void selectRobotByIndex(int idx) {
    if (idx < 0 || idx >= profiles.length) return;
    selectedIndex.value = idx;
    box.write(kSelected, idx);
    disconnect.value = false;
    connectionRos.value = 'Connected';
  }

  void selectRobot(Map<String, dynamic> robot) {
    final robType = (robot['robType'] ?? '') as String;
    final idx = profiles.indexWhere((p) => p['robType'] == robType);
    if (idx != -1) {
      selectRobotByIndex(idx);
    }
  }

  void applyIpRobot() {
    if (profiles.isEmpty) return;
    final idx = selectedIndex.value.clamp(0, profiles.length - 1);
    final p = Map<String, dynamic>.from(profiles[idx]);

    //    p['robType'] = robotType.value;
    p['ip'] = ipWebSocket.value.text.trim();
    p['camera'] = ipCamera.value.text.trim();
    p['linearSpeed'] = linearSpeed.value;
    p['angularSpeed'] = angularSpeed.value;
    p['samplingRate'] = samplingRate.value;

    profiles[idx] = p;
    profiles.refresh();
    _persistProfiles();
    _persistScalars();
    // reDisconnectAndConnect();
    ToastService.showToast(
      title: 'Success',
      description: 'Settings saved successfully',
      type: ToastificationType.success,
    );
  }

  // void resetToDefault() {
  //   if (profiles.isEmpty) return;

  //   final currentType = robotType.value;
  //   final def = _defaultProfiles().firstWhere(
  //     (e) => e['robType'] == currentType,
  //     orElse: () => _defaultProfiles().first,
  //   );

  //   robotType.value = (def['robType'] ?? '') as String;
  //   ipWebSocket.value.text = (def['ip'] ?? '') as String;
  //   ipCamera.value.text = (def['camera'] ?? '') as String;
  //   linearSpeed.value = ((def['linearSpeed'] ?? 0.0) as num).toDouble();
  //   angularSpeed.value = ((def['angularSpeed'] ?? 0.0) as num).toDouble();
  //   samplingRate.value = ((def['samplingRate'] ?? 0.0) as num).toDouble();

  //   applyIpRobot();
  // }

  void _persistProfiles() {
    box.write(
      kProfiles,
      profiles.map((e) => Map<String, dynamic>.from(e)).toList(),
    );
  }

  void _persistScalars() {
    box.write(kSelected, selectedIndex.value);
    box.write(kRobotType, robotType.value);
    box.write(kIp, ipWebSocket.value.text);
    box.write(kCamera, ipCamera.value.text);
    box.write(kLinear, linearSpeed.value);
    box.write(kAngular, angularSpeed.value);
    box.write(kSample, samplingRate.value);
  }

  /*------------------------------ Services--------------------------------------*/
  /// Convert all string values "true"/"false" in a map to actual booleans.
  Map<String, dynamic> convertStringBools(Map<String, dynamic> input) {
    return input.map((key, value) {
      if (value is String) {
        if (value.toLowerCase() == 'true') {
          return MapEntry(key, true);
        } else if (value.toLowerCase() == 'false') {
          return MapEntry(key, false);
        }
      }
      return MapEntry(key, value);
    });
  }

  /// Save cards to persistent storage.
  void syncToStorage() {
    boxService.write('cards', cards);
    talker.info('syncToStorage $cards');
  }

  /// Clear text controllers used when adding/editing a card.
  void clearTextController() {
    labelTextField.value.clear();
    serviceTextField.value.clear();
    textControllerArgs.clear();
    textControllerData.clear();
    textControllerArgs.value = [TextEditingController()];
    textControllerData.value = [TextEditingController()];
    args.value = 1;
    data.value = 1;
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

  void resetReconnect() async {
    if (disconnect.value) return;

    if (channel != null) {
      channel!.sink.close();
      channel = null;
    }
    await Future.delayed(const Duration(seconds: 3));
    connectWS();
  }

  Future connectWS() async {
    try {
      if (channel != null) {
        talker.warning('connect_ws_already_connected ');
        return;
      }

      connectionRos.value = 'Connecting';
      talker.info('connect_ws ${ipWebSocket.value}');

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
                  // handlePublish(decodeData);
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
                talker.warning('ros_out_topic $data');
                break;
            }
          } else {
            talker.warning('Unknown message type received $data');
          }
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
        channel!.sink.add(jsonEncode(data));
      }
    });
  }

  void sendData(String data) {
    try {
      if (channel != null) {
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

  void statusRobot() async {
    // Map advertiseMoveJoint = {
    //   "op": "advertise",
    //   "topic": "/move_joint_manual",
    //   "type": "std_msgs/msg/String",
    // };
    // sendData(jsonEncode(advertiseMoveJoint));

    // await Future.delayed(const Duration(milliseconds: 100));

    Map publishJoyStick = {
      "op": "advertise",
      "topic": "/cmd_vel",
      "type": "geometry_msgs/Twist",
    };
    sendData(jsonEncode(publishJoyStick));

    await Future.delayed(const Duration(milliseconds: 100));

    // Map advertiseSpeech = {
    //   "op": "advertise",
    //   "topic": "/speech_input",
    //   "type": "std_msgs/msg/String",
    // };
    // sendData(jsonEncode(advertiseSpeech));

    // await Future.delayed(const Duration(milliseconds: 100));

    // //------------- subscribe topics -------------
    // Map textAi = {
    //   "op": "subscribe",
    //   "topic": "/agent_reasoning",
    //   "type": "std_msgs/msg/String",
    // };
    // sendData(jsonEncode(textAi));

    // await Future.delayed(const Duration(milliseconds: 100));

    // Map cmdList = {
    //   "op": "subscribe",
    //   "topic": "/robot_mover/unitree_high_level_cmd_list",
    //   "type": "std_msgs/msg/String",
    //   "throttle_rate": 5000,
    // };
    // sendData(jsonEncode(cmdList));

    // await Future.delayed(const Duration(milliseconds: 100));

    // Map cmdMover = {
    //   "op": "subscribe",
    //   "topic": "/robot_mover/response_loco",
    //   "type": "std_msgs/msg/String",
    //   "throttle_rate": 1000,
    // }; //status robot
    // sendData(jsonEncode(cmdMover));

    // await Future.delayed(const Duration(milliseconds: 100));

    // Map cmdCapture = {
    //   "op": "subscribe",
    //   "topic": "/g1_left_arms_joint_state_publisher/arms_postures_list",
    //   "type": "std_msgs/msg/String",
    //   "throttle_rate": 1000,
    // };
    // sendData(jsonEncode(cmdCapture));

    // await Future.delayed(const Duration(milliseconds: 100));

    // Map cmdReadJoint = {
    //   "op": "subscribe",
    //   "topic": "/joint_states",
    //   "type": "sensor_msgs/msg/JointState",
    //   "throttle_rate": 100,
    // };
    // sendData(jsonEncode(cmdReadJoint));

    // Map subScribeAudio = {
    //   "op": "subscribe",
    //   "topic": "/agent_audio_gen",
    //   "type": "std_msgs/msg/String",
    //   "throttle_rate": 1000,
    // }; //status robot
    // sendData(jsonEncode(subScribeAudio));

    // await Future.delayed(const Duration(milliseconds: 100));

    // Map humanoidArmControl = {
    //   "op": "call_service",
    //   "service": "/humanoid_arm_control/run_manipulator",
    //   "type": "std_srvs/srv/SetBool",
    //   "args": {"data": false},
    // };
    // sendData(jsonEncode(humanoidArmControl));
  }

  // void handlePublish(Map data) {
  //   final UrdfController urdfController = Get.find<UrdfController>();

  //   switch (data['topic']) {
  //     case '/joint_states':
  //       try {
  //         if (urdfController.disableReceiveJointState.value) {
  //           // talker.info('Joint states updates are disabled');
  //           return;
  //         }

  //         final msg = data['msg'];
  //         final List<dynamic> positions = msg['position'] ?? [];

  //         // เก็บเฉพาะค่าที่เปลี่ยนแปลง
  //         Map<String, double> changedValues = {};

  //         jointIndexMap.forEach((jointName, index) {
  //           if (index < positions.length) {
  //             final double newValue = positions[index].toDouble();
  //             final double currentValue = urdfController.getJointValue(
  //               jointName,
  //             );

  //             // ตรวจสอบการเปลี่ยนแปลงด้วย tolerance
  //             if ((newValue - currentValue).abs() > 0.001) {
  //               changedValues[jointName] = newValue;
  //             }
  //           }
  //         });

  //         // เซ็ตเฉพาะค่าที่เปลี่ยนแปลง
  //         if (changedValues.isNotEmpty) {
  //           changedValues.forEach((jointName, value) {
  //             urdfController.setJointValue(jointName, value);
  //           });

  //           // Optional: Log จำนวนค่าที่เปลี่ยน (สำหรับ debug)
  //           // talker.info('Updated ${changedValues.length} joints');
  //         }
  //       } catch (e) {
  //         talker.error('Error handling joint_states: $e');
  //       }
  //       break;

  //     case '/g1_left_arms_joint_state_publisher/arms_postures_list':
  //       try {
  //         final msg = data['msg'];
  //         final dataStr = msg['data'];

  //         if (dataStr is String) {
  //           final decoded = jsonDecode(dataStr);
  //           final postureList = decoded['postures'];

  //           if (postureList is List) {
  //             final newPostures = List<String>.from(postureList);
  //             if (!listEquals(postures, newPostures)) {
  //               postures.value = newPostures;
  //             }
  //           }
  //         }
  //       } catch (e) {
  //         talker.error('Error handling arms_postures_list: $e');
  //       }
  //       break;

  //     case '/robot_mover/unitree_high_level_cmd_list':
  //       try {
  //         final msg = data['msg'];
  //         final dataStr = msg['data'];

  //         if (dataStr is String) {
  //           final decoded = jsonDecode(dataStr);
  //           final servicesList = decoded['services'];

  //           if (servicesList is List) {
  //             final newCommands = List<String>.from(servicesList);
  //             if (!listEquals(command, newCommands)) {
  //               command.value = newCommands;
  //             }
  //           }
  //         }
  //       } catch (e) {
  //         talker.error('Error handling unitree_high_level_cmd_list: $e');
  //       }
  //       break;

  //     case '/agent_audio_gen':
  //       try {
  //         final MicController micController = Get.find<MicController>();
  //         // talker.info('ros_agent_audio_gen ${data['msg']['data']}');
  //         if (audioPlayAtWeb.value == false) {
  //           talker.info('Audio generation is disabled at web');
  //           micController.isWaitAndPlaying.value = false;
  //           return;
  //         }

  //         talker.warning('-------------------------> Receive Audio');

  //         micController.playAudio(data['msg']['data']);

  //         // if (decodeData['values']['success']) {
  //         //   final MicController micController = Get.find<MicController>();
  //         //   micController.playAudio(decodeData['values']['message']);
  //         //   // talker.info(decodeData);
  //         //   talker.info('audio res.');
  //         // } else {
  //         //   talker.error('Service Response: ${decodeData['values']}');
  //         //   ToastService.showToast(title: 'ผิดพลาด', description: '${decodeData['values']}', type: ToastificationType.error);
  //         // }
  //       } catch (e, st) {
  //         talker.handle(e, st, 'ros_agent_audio_gen');
  //       }
  //       break;

  //     case '/agent_reasoning':
  //       try {
  //         // Map data = {op: publish, topic: /agent_reasoning, msg: {data: {"task_type": "general_question", "reasoning_steps": [{"type": "thought", "content": "\u0e1c\u0e39\u0e49\u0e43\u0e0a\u0e49\u0e15\u0e49\u0e2d\u0e07\u0e01\u0e32\u0e23: \u0e27\u0e31\u0e19\u0e19\u0e35\u0e49\u0e27\u0e31\u0e19\u0e2d\u0e30\u0e25\u0e31\u0e22", "step_number": 1}, {"type": "thought", "content": "\u0e1b\u0e23\u0e30\u0e40\u0e20\u0e17\u0e07\u0e32\u0e19: general_question", "step_number": 2}, {"type": "thought", "content": "\u0e19\u0e35\u0e48\u0e40\u0e1b\u0e47\u0e19\u0e04\u0e33\u0e16\u0e32\u0e21\u0e17\u0e31\u0e48\u0e27\u0e44\u0e1b", "step_number": 3}, {"type": "action", "content": "\u0e15\u0e2d\u0e1a\u0e42\u0e14\u0e22\u0e43\u0e0a\u0e49\u0e04\u0e27\u0e32\u0e21\u0e23\u0e39\u0e49\u0e17\u0e31\u0e48\u0e27\u0e44\u0e1b", "tool": null, "step_number": 4}, {"type": "conclusion", "content": "\u0e15\u0e2d\u0e1a\u0e04\u0e33\u0e16\u0e32\u0e21\u0e17\u0e31\u0e48\u0e27\u0e44\u0e1b\u0e40\u0e23\u0e35\u0e22\u0e1a\u0e23\u0e49\u0e2d\u0e22", "step_number": 5}], "final_answer": "\u0e27\u0e31\u0e19\u0e19\u0e35\u0e49\u0e40\u0e1b\u0e47\u0e19\u0e27\u0e31\u0e19\u0e1e\u0e38\u0e18\u0e04\u0e48\u0e30", "step_count": 5, "timestamp": "/home/fibo/winworkspace/HumanoidAgent"}}};

  //         final String reasoningData = data['msg']['data'];
  //         final Map<String, dynamic> reasoningMap = jsonDecode(reasoningData);

  //         String finalAnswer = reasoningMap['final_answer'] ?? '';
  //         List<dynamic> reasoningSteps = reasoningMap['reasoning_steps'] ?? [];
  //         String stepsDescription = reasoningSteps
  //             .map((step) => "${step['step_number']}. ${step['content']}")
  //             .join('\n');

  //         ToastService.showToast(
  //           title: finalAnswer, // หรือจะเป็น "สรุปคำตอบ" ก็ได้
  //           description: stepsDescription, // รายละเอียด reasoning steps
  //           type: ToastificationType.success,
  //           duration: Duration(seconds: 30),
  //         );

  //         // talker.warning('agent_reasoning $reasoningMap');
  //       } catch (e, st) {
  //         talker.handle(e, st, 'agent_reasoning');
  //       }
  //       break;

  //     case '/robot_mover/response_loco':
  //       break;

  //     default:
  //       talker.warning('ros_service_response $data');
  //       break;
  //   }
  // }
}
