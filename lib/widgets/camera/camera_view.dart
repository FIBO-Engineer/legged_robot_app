import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import '../../controllers/app_controller.dart';
import '../../units/app_colors.dart';

class CameraView extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;

  const CameraView({super.key, this.width, this.height, this.borderRadius = 0});

  @override
  Widget build(BuildContext context) {
    final AppController c = Get.find<AppController>();
    return IgnorePointer(
      child: Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.scaffold,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          // child: RTCVideoView(
          //             c.renderer,
          //             objectFit:
          //                 RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
          //           ),
          child: Transform.scale(
            scale: 1.13,
            alignment: Alignment.center,
            child: const SizedBox.expand(
              child: HtmlElementView(
                viewType: 'camera',
                key: ValueKey('cameraView'),
              ),
            ),
          ),
          // child: Center(
          //   child:
          //       kIsWeb
          //           ? Transform.scale(
          //             scale: 1.13,
          //             alignment: Alignment.center,
          //             child: const SizedBox.expand(
          //               child: HtmlElementView(
          //                 viewType: 'camera',
          //                 key: ValueKey('cameraView'),
          //               ),
          //             ),
          //           )
          //           : RTCVideoView(
          //             c.renderer,
          //             objectFit:
          //                 RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
          //           ),
          // ),
        ),
      ),
    );
  }
}
