import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/urdf_controller.dart';
import '../units/app_colors.dart';
import '../units/app_constants.dart';
import '../widgets/app_navigation_bar.dart';
import '../widgets/robot/joint_control_panel.dart';

class MappingPage extends StatelessWidget {
  const MappingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screen = ScreenSize(context);

    if (screen.isDesktop || screen.isTablet) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          children: [
            buildResponsiveNavBar(context),
            Expanded(child: MappingScreen()),
          ],
        ),
      );
    } else if (screen.isPortrait) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            Expanded(child: MappingScreen()),
            buildResponsiveNavBar(context),
          ],
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [MappingScreen(), buildResponsiveNavBar(context)],
        ),
      );
    }
  }
}

class MappingScreen extends StatelessWidget {
  const MappingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UrdfController controller = Get.find();
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Obx(() {
              if (!controller.isInitialized) {
                return Stack(
                  children: [
                    const Center(child: CircularProgressIndicator()),
                    controller.threeJs.build(),
                  ],
                );
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    controller.updateSize(
                      constraints.maxWidth,
                      constraints.maxHeight,
                    );
                  });

                  return ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      child: controller.threeJs.build(),
                    ),
                  );
                },
              );
            }),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: AppColors.scaffold,
              ),
              padding: const EdgeInsets.all(8.0),
              child: JointControlPanel(),
            ),
          ),
        ],
      ),
    );
  }
}
