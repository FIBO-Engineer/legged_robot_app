import 'package:get/get.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:http/http.dart' as http;

class AppController extends GetxController {
  final RTCVideoRenderer renderer = RTCVideoRenderer();
  RTCPeerConnection? _peerConnection;

  RxBool isInitialized = false.obs;
  RxBool isLoading = true.obs;
  RxString errorMessage = ''.obs;
  RxString connectionState = 'new'.obs;
  RxString iceConnectionState = 'new'.obs;

  @override
  void onInit() {
    super.onInit();
    _initWebRTC();
  }

  Future<void> _initWebRTC() async {
    final streamUrl = 'http://10.61.6.30:8889/my_camera/whep';

    try {
      isLoading.value = true;
      errorMessage.value = '';

      await renderer.initialize();

      renderer.onResize = () {
        if (renderer.value.width > 0 && renderer.value.height > 0) {
          isInitialized.value = true;
        }
      };

      _peerConnection = await createPeerConnection({
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
          {'urls': 'stun:stun1.l.google.com:19302'},
        ],
        'sdpSemantics': 'unified-plan',
      });

      _peerConnection!.onConnectionState = (state) {
        connectionState.value = state.toString();
      };

      _peerConnection!.onIceConnectionState = (state) {
        iceConnectionState.value = state.toString();
      };

      _peerConnection!.onIceCandidate = (candidate) {};

      await _peerConnection!.addTransceiver(
        kind: RTCRtpMediaType.RTCRtpMediaTypeVideo,
        init: RTCRtpTransceiverInit(direction: TransceiverDirection.RecvOnly),
      );

      await _peerConnection!.addTransceiver(
        kind: RTCRtpMediaType.RTCRtpMediaTypeAudio,
        init: RTCRtpTransceiverInit(direction: TransceiverDirection.RecvOnly),
      );

      _peerConnection!.onTrack = (event) {
        if (event.track.kind == 'video' && event.streams.isNotEmpty) {
          if (!event.track.enabled) {
            event.track.enabled = true;
          }

          renderer.srcObject = event.streams[0];

          isInitialized.value = true;
        }
      };

      final offer = await _peerConnection!.createOffer({
        'offerToReceiveVideo': true,
        'offerToReceiveAudio': true,
      });

      await _peerConnection!.setLocalDescription(offer);
      final response = await http.post(
        Uri.parse(streamUrl),
        headers: {
          'Content-Type': 'application/sdp',
          'User-Agent': 'Flutter-WebRTC-Client',
        },
        body: offer.sdp,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          'WHIP request failed: ${response.statusCode} - ${response.body}',
        );
      }

      final answer = RTCSessionDescription(response.body, 'answer');
      await _peerConnection!.setRemoteDescription(answer);
      await Future.delayed(Duration(seconds: 2));
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> restart() async {
    await dispose();
    await Future.delayed(Duration(milliseconds: 500));
    _initWebRTC();
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    isInitialized.value = false;
    renderer.srcObject = null;
    await _peerConnection?.close();
    _peerConnection = null;
  }

  @override
  void onClose() {
    renderer.dispose();
    _peerConnection?.close();
    super.onClose();
  }
}
