import 'dart:ui_web' as ui;
//import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import 'package:legged_robot_app/controllers/main_conroller.dart';
// ignore: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html';
import 'package:http/http.dart' as http;

class AppController extends GetxController {
  //Rx<IFrameElement> iFrameElementCam = IFrameElement().obs;
  final RTCVideoRenderer renderer = RTCVideoRenderer();

  @override
  void onInit() {
    final MainController c = Get.find<MainController>();

    // if (kIsWeb) {
      ui.platformViewRegistry.registerViewFactory('camera', (int viewId) {
        final iFrame =
            IFrameElement()
              ..src = c.ipCamera.value.text
              ..style.border = 'none'
              ..style.width = '100%'
              ..style.height = '100%'
              ..style.overflow = 'hidden'
              ..allowFullscreen = true
              ..allow = 'autoplay'
              ..style.pointerEvents = 'none'
              ..setAttribute('muted', 'true');
        return iFrame;
      });
    // } else {
      initWebRTC(c.ipCamera.value.text);
   // }

    super.onInit();
  }

  Future<void> initWebRTC(String url) async {
    await renderer.initialize();

    final pc = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
    });

    pc.onTrack = (RTCTrackEvent event) {
      if (event.track.kind == 'video') {
        renderer.srcObject = event.streams[0];
      }
    };

    final offer = await pc.createOffer();
    await pc.setLocalDescription(offer);
    final res = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/sdp'},
      body: offer.sdp,
    );

    await pc.setRemoteDescription(RTCSessionDescription(res.body, 'answer'));
  }

  @override
  void onClose() {
    renderer.dispose();
    super.onClose();
  }
}
