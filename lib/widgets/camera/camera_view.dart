import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import '../../controllers/app_controller.dart';

class CameraView extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;

  const CameraView({super.key, this.width, this.height, this.borderRadius = 0});

  @override
  Widget build(BuildContext context) {
    final AppController c = Get.find<AppController>();

    return Obx(() {
      return Container(
        width: width ?? double.infinity,
        height: height ?? 300,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Stack(
          children: [
            if (c.isLoading.value) Center(child: CircularProgressIndicator()),

            if (!c.isLoading.value && c.errorMessage.isNotEmpty)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 48),
                    SizedBox(height: 8),
                    Text(
                      "เชื่อมต่อกล้องไม่ได้",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    SizedBox(height: 4),
                    Text(
                      c.errorMessage.value,
                      style: TextStyle(color: Colors.red, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: c.restart,
                      child: Text('ลองใหม่'),
                    ),
                  ],
                ),
              ),

            if (!c.isLoading.value && c.errorMessage.isEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(borderRadius),
                child:
                    c.isInitialized.value
                        ? RTCVideoView(
                          c.renderer,
                          objectFit:
                              RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                          mirror: false,
                          filterQuality: FilterQuality.medium,
                        )
                        : Container(
                          color: Colors.black,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(color: Colors.white),
                                SizedBox(height: 16),
                                Text(
                                  'กำลังโหลดวิดีโอ...',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
              ),
          ],
        ),
      );
    });
  }
}
