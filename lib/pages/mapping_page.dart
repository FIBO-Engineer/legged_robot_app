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

// class MappingScreen extends StatelessWidget {
//   const MappingScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final UrdfController controller = Get.find();
//     return Padding(
//       padding: const EdgeInsets.all(12),
//       child: Row(
//         spacing: 8,
//         children: [
//           Expanded(
//             flex: 1,
//             child: Obx(() {
//               // Show loading indicator while ThreeJS is initializing
//               if (!controller.isInitialized) {
//                 return Stack(
//                   children: [
//                     const Center(child: CircularProgressIndicator()),
//                     controller.threeJs.build(),
//                   ],
//                 );
//               }

//               return LayoutBuilder(
//                 builder: (context, constraints) {
//                   // Only update size after initialization is complete
//                   WidgetsBinding.instance.addPostFrameCallback((_) {
//                     controller.updateSize(
//                       constraints.maxWidth,
//                       constraints.maxHeight,
//                     );
//                   });

//                   return ClipRRect(
//                     borderRadius: BorderRadius.circular(16),
//                     child: SizedBox(
//                       width: constraints.maxWidth,
//                       height: constraints.maxHeight,
//                       child: controller.threeJs.build(),
//                     ),
//                   );
//                 },
//               );
//             }),
//           ),
//           Expanded(
//             flex: 2,
//             child: Container(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(16),
//                 color: AppColors.scaffold,
//               ),
//               padding: const EdgeInsets.all(8.0),
//               child: JointControlPanel(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class MappingScreen extends StatefulWidget {
  const MappingScreen({super.key});

  @override
  State<MappingScreen> createState() => _MappingScreenState();
}

class _MappingScreenState extends State<MappingScreen> {
  late UrdfController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<UrdfController>();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        // Notify controller about orientation change
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.handleOrientationChange(orientation);
        });

        return Padding(
          padding: EdgeInsets.all(orientation == Orientation.portrait ? 8 : 12),
          child: _buildLayout(context, orientation),
        );
      },
    );
  }

  Widget _buildLayout(BuildContext context, Orientation orientation) {
    final screen = ScreenSize(context);

    if (orientation == Orientation.portrait) {
      return _buildPortraitLayout(screen);
    } else {
      return _buildLandscapeLayout(screen);
    }
  }

  Widget _buildPortraitLayout(ScreenSize screen) {
    return Column(
      children: [
        // 3D Viewer - โมเดลอยู่ด้านบน
        Expanded(
          flex: screen.isMobile ? 3 : 2, // Mobile ให้พื้นที่โมเดลมากกว่า
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.scaffold,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _build3DViewer(orientation: Orientation.portrait),
            ),
          ),
        ),

        SizedBox(height: 8),

        // Control Panel - ด้านล่าง
        Expanded(
          flex: screen.isMobile ? 4 : 3, // Mobile ให้พื้นที่ control มากกว่า
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.scaffold,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _buildControlPanel(isPortrait: true),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout(ScreenSize screen) {
    return Row(
      children: [
        // 3D Viewer - ด้านซ้าย
        Expanded(
          flex: screen.isDesktop ? 2 : 2, // Desktop ให้พื้นที่โมเดลน้อยกว่า
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.scaffold,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _build3DViewer(orientation: Orientation.landscape),
            ),
          ),
        ),

        SizedBox(width: 12),

        // Control Panel - ด้านขวา
        Expanded(
          flex: screen.isDesktop ? 3 : 2,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.scaffold,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _buildControlPanel(isPortrait: false),
            ),
          ),
        ),
      ],
    );
  }

  Widget _build3DViewer({required Orientation orientation}) {
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
          // Update size with orientation info
          WidgetsBinding.instance.addPostFrameCallback((_) {
            controller.updateSize(
              constraints.maxWidth,
              constraints.maxHeight,
              orientation: orientation,
            );
          });

          return Stack(
            children: [
              // 3D Scene
              SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: controller.threeJs.build(),
              ),

              // Camera reset button (แสดงเฉพาะ mobile)
              if (MediaQuery.of(context).size.width < 768)
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    onPressed: controller.resetCameraView,
                    icon: Icon(
                      Icons.center_focus_strong,
                      color: Colors.white70,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black26,
                      shape: CircleBorder(),
                    ),
                  ),
                ),
            ],
          );
        },
      );
    });
  }

  Widget _buildControlPanel({required bool isPortrait}) {
    return Column(
      children: [
        // Header with controls
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.scaffold,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.tune, color: Colors.white70),
              SizedBox(width: 8),
              Text(
                'Joint Control',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              // Reset camera button (แสดงเฉพาะ desktop)
              if (MediaQuery.of(context).size.width >= 768)
                IconButton(
                  onPressed: controller.resetCameraView,
                  icon: Icon(Icons.center_focus_strong),
                  tooltip: 'Reset Camera View',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white10,
                    foregroundColor: Colors.white70,
                  ),
                ),
            ],
          ),
        ),

        // Joint controls
        Expanded(
          child: Container(
            padding: EdgeInsets.all(8),
            child: JointControlPanel(),
          ),
        ),
      ],
    );
  }
}
