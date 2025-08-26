import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legged_robot_app/units/app_colors.dart';
import '../controllers/main_conroller.dart';
import '../units/app_constants.dart';
import '../widgets/app_navigation_bar.dart';
import '../widgets/camera/camera_view.dart';
import '../widgets/controls/movement_joystick.dart';
import '../widgets/controls/rotation_joystick.dart';
import '../widgets/overlays/control_overlay.dart';
import '../widgets/robot/robot_model_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screen = ScreenSize(context);

    if (screen.isDesktop || screen.isTablet) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          children: [
            buildResponsiveNavBar(context),
            Expanded(child: HomeScreen()),
          ],
        ),
      );
    } else if (screen.isPortrait) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            Expanded(child: HomeScreen()),
            buildResponsiveNavBar(context),
          ],
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(children: [HomeScreen(), buildResponsiveNavBar(context)]),
      );
    }
  }
}

//---------------------- Dashboard Content Responsive ---------------------//
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screen = ScreenSize(context);
    final MainController controller = Get.find();

    return Obx(() {
      final showCamera = controller.showCamera.value;

      if (screen.isDesktop || screen.isTablet) {
        return Stack(
          children: [
            const Positioned.fill(child: CameraView()),
            const RobotModelView(),
            const ControlOverlay(),
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
        );
      } else if (screen.isPortrait) {
        return Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  const Positioned.fill(child: CameraView()),
                  const RobotModelView(),
                  const ControlOverlay(),
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
              ),
            ),
          ],
        );
      } else {
        return Stack(
          children: [
            const Positioned.fill(child: CameraView()),
            const RobotModelView(),
            const ControlOverlay(),
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
        );
      }
    });
  }
}
