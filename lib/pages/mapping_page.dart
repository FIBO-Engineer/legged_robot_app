import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/urdf_controller.dart';
import '../units/app_colors.dart';
import '../units/app_constants.dart';
import '../widgets/app_navigation_bar.dart';
import '../widgets/custom_button.dart';
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
    final UrdfController controller = Get.find<UrdfController>();

    return Padding(
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          // LEFT: 3D Viewer
          Expanded(
            flex: 2,
            child: Container(
              decoration: const BoxDecoration(color: AppColors.background),
              child: _build3DViewer(controller),
            ),
          ),
          // RIGHT: Control Panel
          Expanded(
            flex: 3,
            child: Container(
              decoration: const BoxDecoration(color: AppColors.background),
              child: _buildControlPanel(context, controller),
            ),
          ),
        ],
      ),
    );
  }

  Widget _build3DViewer(UrdfController controller) {
    return Obx(() {
      if (!controller.isInitialized) {
        return Stack(
          children: [
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Loading 3D Model...',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            controller.threeJs.build(),
          ],
        );
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            controller.updateSize(constraints.maxWidth, constraints.maxHeight);
          });

          return Stack(
            children: [
              SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: controller.threeJs.build(),
              ),
              Positioned(
                bottom: 8,
                left: 8,
                child: CircleButton(
                  tooltip: '',
                  borderRadius: 12,
                  icon: Icons.center_focus_strong,
                  // ignore: deprecated_member_use
                  backgroundColor: AppColors.scaffold.withOpacity(0.7),
                  iconColor: AppColors.grey,
                  onPressed: controller.resetCameraView,
                ),
              ),
            ],
          );
        },
      );
    });
  }

  Widget _buildControlPanel(BuildContext context, UrdfController controller) {
    return Column(
      children: [
        // Header
        // Container(
        //   padding: const EdgeInsets.fromLTRB(8, 26, 8, 8),
        //   decoration: const BoxDecoration(color: AppColors.scaffold),
        //   child: Row(
        //     children: [
        //       const Icon(Icons.tune, color: Colors.white70),
        //       const SizedBox(width: 8),
        //       Text(
        //         'Joint Control',
        //         style: Theme.of(context).textTheme.titleMedium?.copyWith(
        //           color: Colors.white,
        //           fontWeight: FontWeight.bold,
        //         ),
        //       ),
        //       const Spacer(),
        //       CircleButton(
        //         tooltip: '',
        //         borderRadius: 12,
        //         icon: Icons.center_focus_strong,
        //         iconColor: AppColors.grey,
        //         onPressed: controller.resetCameraView,
        //       ),
        //     ],
        //   ),
        // ),
        // Body
        const Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(8, 26, 8, 8),
            child: JointControlPanel(),
          ),
        ),
      ],
    );
  }
}
