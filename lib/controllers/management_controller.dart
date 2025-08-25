import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../services/talker_service.dart';

class ManagementController extends GetxController {
  final box = GetStorage('storage');
  RxList<TextEditingController> textControllerArgs =
      [TextEditingController()].obs;
  RxList<TextEditingController> textControllerData =
      [TextEditingController()].obs;
  Rx<TextEditingController> serviceTextField = TextEditingController().obs;
  Rx<TextEditingController> labelTextField = TextEditingController().obs;
  RxBool addCard = false.obs;
  RxBool editCard = false.obs;
  RxBool isPublish = false.obs;
  RxInt index = (-1).obs;
  RxInt args = 1.obs;
  RxInt data = 1.obs;
  RxList<dynamic> cards = <dynamic>[].obs;
  final RxList<String> topics = <String>['Publish', 'Call Service'].obs;
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
    await GetStorage.init('storage');
    try {
      if (box.read('managements') == null) {
        box.write('managements', <dynamic>[]);
      } else {
        cards.value = box.read('managements');
      }
    } catch (e, st) {
      talker.handle(e, st, 'managements controller / onInit');
    }
    super.onInit();
  }

  @override
  void onReady() {
    // Get called after widget is rendered on the screen
    super.onReady();
  }

  @override
  void onClose() {
    clearFormat();
    super.onClose();
  }

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
    box.write('managements', cards);
    talker.info('Managements controller / syncTostorage $cards');
  }

  void clearFormat() {
    labelTextField.value.clear();
    serviceTextField.value.clear();
    textControllerArgs.clear();
    textControllerData.clear();
    textControllerArgs.value = [TextEditingController()];
    textControllerData.value = [TextEditingController()];
    args.value = 1;
    data.value = 1;
  }
}
