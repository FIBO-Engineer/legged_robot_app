import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legged_robot_app/units/app_colors.dart';
import '../controllers/main_conroller.dart';
import '../units/app_constants.dart';
import '../widgets/app_navigation_bar.dart';
import '../widgets/controls/movement_joystick.dart';
import '../widgets/controls/rotation_joystick.dart';
import '../widgets/custom_widget.dart';
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
      final showJoy = controller.showJoy.value;
      final showControlOverlay = controller.showControlOverlay.value;
      final showRobotModel = controller.showRobotModel.value;

      if (screen.isDesktop || screen.isTablet) {
        return Stack(
          children: [
            //  const Positioned.fill(child: CameraView()),
            if (showRobotModel) const RobotModelView(),
            if (showControlOverlay) const ControlOverlay(),
            if (showJoy) ...[
              MovementJoystick(controller: controller),
              RotationJoystick(controller: controller),
            ],

            _controlWidget(controller),
          ],
        );
      } else if (screen.isPortrait) {
        return Stack(
          children: [
            //  const Positioned.fill(child: CameraView()),
            if (showRobotModel) const RobotModelView(),
            if (showControlOverlay) const ControlOverlay(),
            if (showJoy) ...[
              MovementJoystick(
                left: 20,
                bottom: 20,
                controller: controller,
                sizeJoy: 140,
                sizeBall: 25,
              ),
              RotationJoystick(
                right: 20,
                bottom: 20,
                controller: controller,
                sizeJoy: 140,
                sizeBall: 28,
              ),
            ],
            _controlWidget(controller),
          ],
        );
      } else {
        return Stack(
          alignment: AlignmentDirectional.topCenter,
          children: [
            //   const Positioned.fill(child: CameraView()),
            if (showRobotModel) const RobotModelView(),
            if (showControlOverlay) const ControlOverlay(),
            if (showJoy) ...[
              MovementJoystick(
                left: 20,
                bottom: 20,
                controller: controller,
                sizeJoy: 140,
                sizeBall: 25,
              ),
              RotationJoystick(
                right: 20,
                bottom: 20,
                controller: controller,
                sizeJoy: 140,
                sizeBall: 28,
              ),
            ],
            _controlWidget(controller),
          ],
        );
      }
    });
  }

  Widget _controlWidget(MainController controller) {
    return Positioned(
      top: 26,
      left: 10,
      child: Column(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Obx(
            () => CircleButton(
              tooltip: '',
              borderRadius: 12,
              icon: Icons.terminal,
              // ignore: deprecated_member_use
              backgroundColor: AppColors.scaffold.withOpacity(0.7),
              iconColor:
                  controller.showControlOverlay.value
                      ? Colors.white
                      : AppColors.grey,
              onPressed: () {
                controller.showControlOverlay.value =
                    !controller.showControlOverlay.value;
              },
            ),
          ),
          // Obx(
          //   () => CircleButton(
          //     tooltip: '',
          //     borderRadius: 12,
          //     icon: Icons.manage_accounts_outlined,
          //     // ignore: deprecated_member_use
          //     backgroundColor: AppColors.scaffold.withOpacity(0.7),
          //     iconColor:
          //         controller.showRobotModel.value
          //             ? Colors.white
          //             : AppColors.grey,
          //     onPressed: () {
          //       controller.showRobotModel.value =
          //           !controller.showRobotModel.value;
          //     },
          //   ),
          // ),
          Obx(
            () => CircleButton(
              tooltip: '',
              borderRadius: 12,
              icon: AppIcons.gamePad,
              // ignore: deprecated_member_use
              backgroundColor: AppColors.scaffold.withOpacity(0.7),
              iconColor:
                  controller.showJoy.value ? Colors.white : AppColors.grey,
              onPressed: () {
                controller.showJoy.value = !controller.showJoy.value;
              },
            ),
          ),
        ],
      ),
    );
  }
}
