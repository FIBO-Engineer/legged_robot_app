import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import 'package:legged_robot_app/units/app_colors.dart';
import '../../controllers/app_controller.dart';
import '../custom_widget.dart';

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
          color: AppColors.scaffold,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Stack(
          children: [
            if (c.isLoading.value) Center(child: CircularProgressIndicator(color: Colors.white),),

            if (!c.isLoading.value && c.errorMessage.isNotEmpty)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Can't connect to the camera",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    SizedBox(height: 16),
                    CircleButton(
                      icon: Icons.refresh_rounded,
                      backgroundColor: AppColors.background,
                      iconColor: Colors.white,
                      onPressed: c.restart,
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
                          color: AppColors.background,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(color: Colors.white),
                                SizedBox(height: 16),
                                Text(
                                  'Loading...',
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
