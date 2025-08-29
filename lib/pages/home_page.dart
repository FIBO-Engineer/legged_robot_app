import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legged_robot_app/units/app_colors.dart';
import '../controllers/main_conroller.dart';
import '../units/app_constants.dart';
import '../widgets/app_navigation_bar.dart';
import '../widgets/camera/camera_view.dart';
import '../widgets/controls/movement_joystick.dart';
import '../widgets/controls/rotation_joystick.dart';
import '../widgets/custom_widget.dart';
import '../widgets/overlays/control_overlay.dart';
//import '../widgets/robot/robot_model_view.dart';

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
           // const Positioned.fill(child: CameraView()),
            if (showRobotModel) 
            //const RobotModelView(),
            Positioned(
                top: 10,
                right: 10,
                child: CameraView(
                  width: screen.width * 0.3,
                  height: screen.width * 0.3 * 9 / 16,
                  borderRadius: 8,
                ),
              ),
            if (showControlOverlay) const ControlOverlay(),
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

            Positioned(
              top: !showControlOverlay ? 10 : 220,
              left: 10,
              child: Center(child: _controlWidget(controller)),
            ),
          ],
        );
      } else if (screen.isPortrait) {
        return Stack(
          children: [
          //  const Positioned.fill(child: CameraView()),
            if (showRobotModel) const
            // RobotModelView(),
              AspectRatio(aspectRatio: 16 / 9, child: CameraView()),
            if (showControlOverlay) const ControlOverlay(),
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
            Positioned(
              top: !showControlOverlay ? 10 : 220,
              left: 10,
              child: Center(child: _controlWidget(controller)),
            ),
          ],
        );
      } else {
        return Stack(
          alignment: AlignmentDirectional.topCenter,
          children: [
         //   const Positioned.fill(child: CameraView()),
            if (showRobotModel) 
            //const RobotModelView(),
              Positioned(
                top: 10,
                right: 10,
                child: CameraView(
                  width: screen.width * 0.35,
                  height: screen.width * 0.35 * 9 / 16,
                  borderRadius: 8,
                ),
              ),
            if (showControlOverlay) const ControlOverlay(),
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
            Positioned(
              top: !showControlOverlay ? 10 : 220,
              left: 10,
              child: Center(child: _controlWidget(controller)),
            ),
          ],
        );
      }
    });
  }

  Widget _controlWidget(MainController controller) {
    return Row(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Obx(
          () => CircleButton(
            tooltip: '',
            borderRadius: 12,
            icon: Icons.terminal,
            // ignore: deprecated_member_use
            backgroundColor: AppColors.card.withOpacity(0.3),
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
        Obx(
          () => CircleButton(
            tooltip: '',
            borderRadius: 12,
            icon: Icons.person,
            // ignore: deprecated_member_use
            backgroundColor: AppColors.card.withOpacity(0.3),
            iconColor:
                controller.showRobotModel.value ? Colors.white : AppColors.grey,
            onPressed: () {
              controller.showRobotModel.value =
                  !controller.showRobotModel.value;
            },
          ),
        ),
        Obx(
          () => CircleButton(
            tooltip: '',
            borderRadius: 12,
            icon: AppIcons.gamePad, 
            // ignore: deprecated_member_use
            backgroundColor: AppColors.card.withOpacity(0.3),
            iconColor: controller.showJoy.value ? Colors.white : AppColors.grey,
            onPressed: () {
              controller.showJoy.value = !controller.showJoy.value;
            },
          ),
        ),
      ],
    );
  }
}
