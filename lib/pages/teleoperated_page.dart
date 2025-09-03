import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/main_conroller.dart';
import '../units/app_colors.dart';
import '../units/app_constants.dart';
import '../widgets/app_navigation_bar.dart';
import '../widgets/camera/camera_view.dart';
import '../widgets/controls/movement_joystick.dart';
import '../widgets/controls/rotation_joystick.dart';
import '../widgets/custom_button.dart';

class TeleoperatedPage extends StatelessWidget {
  const TeleoperatedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screen = ScreenSize(context);

    if (screen.isDesktop || screen.isTablet) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          children: [
            buildResponsiveNavBar(context),
            Expanded(child: TeleoperatedScreen()),
          ],
        ),
      );
    } else if (screen.isPortrait) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            Expanded(child: TeleoperatedScreen()),
            buildResponsiveNavBar(context),
          ],
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [TeleoperatedScreen(), buildResponsiveNavBar(context)],
        ),
      );
    }
  }
}

//---------------------- Teleoperated Content Responsive ---------------------//
class TeleoperatedScreen extends StatelessWidget {
  const TeleoperatedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screen = ScreenSize(context);
    final MainController controller = Get.find();

    return Obx(() {
      final showJoy = controller.showJoy.value;

      if (screen.isDesktop || screen.isTablet) {
        return Stack(
          children: [
            const Positioned.fill(child: CameraView()),
            Positioned(top: 10, right: 10, child: _controlWidget()),
            if (showJoy) ...[
              Positioned(
                left: 50,
                bottom: 50,
                child: MovementJoystick(controller: controller),
              ),
              Positioned(
                right: 50,
                bottom: 50,
                child: RotationJoystick(controller: controller),
              ),
            ],
          ],
        );
      } else if (screen.isPortrait) {
        return Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  const Positioned.fill(child: CameraView()),
                  Positioned(top: 10, right: 10, child: _controlWidget()),

                  if (showJoy) ...[
                    Positioned(
                      left: 20,
                      bottom: 20,
                      child: MovementJoystick(
                        controller: controller,
                        sizeJoy: 140,
                        sizeBall: 25,
                      ),
                    ),
                    Positioned(
                      right: 20,
                      bottom: 20,
                      child: RotationJoystick(
                        controller: controller,
                        sizeJoy: 140,
                        sizeBall: 25,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      } else {
        return Stack(
          children: [
            const Positioned.fill(child: CameraView()),
            Positioned(top: 10, right: 10, child: _controlWidget()),
            if (showJoy) ...[
              Positioned(
                left: 20,
                bottom: 10,
                child: MovementJoystick(
                  controller: controller,
                  sizeJoy: 150,
                  sizeBall: 30,
                ),
              ),
              Positioned(
                right: 20,
                bottom: 10,
                child: RotationJoystick(
                  controller: controller,
                  sizeJoy: 150,
                  sizeBall: 30,
                ),
              ),
            ],
          ],
        );
      }
    });
  }

  Widget _controlWidget() {
    MainController controller = Get.find();
    return Obx(
      () => CircleButton(
        borderRadius: 12,
        icon: Icons.gamepad_rounded,
        backgroundColor: AppColors.card,
        iconColor: controller.showJoy.value ? AppColors.primary : Colors.white,
        onPressed:(){
          controller.showJoy.value = !controller.showJoy.value;
        },
      ),
    );
  }
}
