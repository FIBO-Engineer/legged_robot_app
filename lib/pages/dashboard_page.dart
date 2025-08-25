import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legged_robot_app/units/app_colors.dart';
import '../controllers/main_conroller.dart';
import '../units/app_constants.dart';
import '../widgets/app_navigation_bar.dart';
import '../widgets/camera/camera_view.dart';
import '../widgets/custom_widget.dart';
import '../widgets/display/display_grid.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screen = ScreenSize(context);

    if (screen.isDesktop || screen.isTablet) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          children: [
            buildResponsiveNavBar(context),
            Expanded(child: DashboardScreen()),
          ],
        ),
      );
    } else if (screen.isPortrait) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            Expanded(child: DashboardScreen()),
            buildResponsiveNavBar(context),
          ],
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [DashboardScreen(), buildResponsiveNavBar(context)],
        ),
      );
    }
  }
}

//---------------------- Dashboard Content Responsive ---------------------//
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screen = ScreenSize(context);
    final MainController controller = Get.find();

    return Obx(() {
      final showCamera = controller.showCamera.value;

      if (screen.isDesktop || screen.isTablet) {
        return Stack(
          children: [
            Positioned.fill(child: _mapWidget()),
            if (showCamera)
              Positioned(
                top: 10,
                right: 10,
                child: CameraView(
                  width: screen.width * 0.3,
                  height: screen.width * 0.3 * 9 / 16,
                  borderRadius: 8,
                ),
              ),

            Positioned(top: 10, left: 10, child: _statusWidget(context)),
            Positioned(top: 46, left: 6, child: _controlWidget(controller)),
            Positioned(bottom: 10, left: 10, child: _emgWidget()),
            Positioned(bottom: 10, right: 10, child: _zoomWidget()),
          ],
        );
      } else if (screen.isPortrait) {
        return Column(
          children: [
            if (showCamera)
              AspectRatio(aspectRatio: 16 / 9, child: CameraView()),

            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(child: _mapWidget()),
                  Positioned(top: 10, left: 10, child: _statusWidget(context)),
                  Positioned(
                    top: 46,
                    left: 6,
                    child: _controlWidget(controller),
                  ),
                  Positioned(bottom: 10, left: 10, child: _emgWidget()),
                  Positioned(bottom: 10, right: 10, child: _zoomWidget()),
                ],
              ),
            ),
          ],
        );
      } else {
        return Stack(
          children: [
            Positioned.fill(child: _mapWidget()),
            if (showCamera)
              Positioned(
                top: 10,
                right: 10,
                child: CameraView(
                  width: screen.width * 0.35,
                  height: screen.width * 0.35 * 9 / 16,
                  borderRadius: 8,
                ),
              ),
            Positioned(top: 10, left: 10, child: _statusWidget(context)),
            Positioned(top: 46, left: 6, child: _controlWidget(controller)),
            Positioned(bottom: 10, left: 10, child: _emgWidget()),
            Positioned(bottom: 10, right: 10, child: _zoomWidget()),
          ],
        );
      }
    });
  }

  Widget _mapWidget() {
    final c = Get.find<MainController>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final stepPixels = (1.0 / c.mapResolution.value);

        return InteractiveViewer(
          key: c.mapAreaKey,
          transformationController: c.mapTC,
          minScale: c.mapMinScale,
          maxScale: c.mapMaxScale,
          constrained: true,
          child: SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: Stack(
              children: [
                Positioned.fill(
                  child: DisplayGrid(
                    step: stepPixels,
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                  ),
                ),

                // // ไอคอนหุ่น (คำนวณพิกเซลจากเมตร)
                // Obx(() {
                //   final pxX = c.robotMeters.value.dx * c.pxPerMeter;
                //   final pxY = c.robotMeters.value.dy * c.pxPerMeter;
                //   const robotSize = 24.0;

                //   return Positioned(
                //     left: pxX - robotSize / 2,
                //     top:  pxY - robotSize / 2,
                //     child: Transform.rotate(
                //       angle: c.robotYaw.value,
                //       child: DisplayRobot(
                //         size: robotSize,
                //         color: Colors.blue,
                //         direction: 0,
                //       ),
                //     ),
                //   );
                // }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _zoomWidget() {
    final c = Get.find<MainController>();
    return Column(
      children: [
        IconButton(
          icon: const Icon(Icons.add_rounded, size: 24, color: AppColors.grey),
          onPressed: () => c.zoomBy(1.2),
        ),
        IconButton(
          icon: const Icon(
            Icons.remove_rounded,
            size: 24,
            color: AppColors.grey,
          ),
          onPressed: () => c.zoomBy(1 / 1.2),
        ),
        Obx(
          () => IconButton(
            icon: Icon(
              Icons.location_searching_rounded,
              size: 20,
              color: c.followRobot.value ? AppColors.primary : AppColors.grey,
            ),
            onPressed: () {
              // c.zoomBy(0);
              // c.toggleFollow();
            },
          ),
        ),
      ],
    );
  }

  Widget _emgWidget() {
    return CustomButton(
      text: 'Emergency',
      icon: Icons.block_rounded,
      foregroundColor: AppColors.red,
      onPressed: () {},
    );
  }

  Widget _controlWidget(MainController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Layer Control Card
        Card(
          elevation: 2,
          color: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(
                  () => IconButton(
                    hoverColor: AppColors.card,
                    icon: Icon(Icons.layers_rounded, size: 20),
                    color:
                        controller.showLayer.value
                            ? AppColors.primary
                            : AppColors.grey,
                    onPressed: controller.toggleLayer,
                    tooltip: '', //Layer control
                  ),
                ),

                Obx(
                  () =>
                      controller.showLayer.value
                          ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Global Costmap
                              Obx(
                                () => IconButton(
                                  hoverColor: AppColors.card,
                                  icon: Icon(Icons.map, size: 20),
                                  color:
                                      controller.showGlobalCostmap.value
                                          ? AppColors.primary
                                          : AppColors.grey,
                                  onPressed: controller.toggleGlobalCostmap,
                                  tooltip: '', //Global map
                                ),
                              ),

                              // Local Costmap
                              Obx(
                                () => IconButton(
                                  hoverColor: AppColors.card,
                                  icon: Icon(Icons.map_outlined, size: 20),
                                  color:
                                      controller.showLocalCostmap.value
                                          ? AppColors.primary
                                          : AppColors.grey,
                                  onPressed: controller.toggleLocalCostmap,
                                  tooltip: '', //Local map
                                ),
                              ),

                              // Laser
                              Obx(
                                () => IconButton(
                                  hoverColor: AppColors.card,
                                  icon: Icon(Icons.radar_rounded, size: 20),
                                  color:
                                      controller.showLaser.value
                                          ? AppColors.primary
                                          : AppColors.grey,
                                  onPressed: controller.toggleLaser,
                                  tooltip: '', //Laser
                                ),
                              ),

                              // Point Cloud
                              Obx(
                                () => IconButton(
                                  hoverColor: AppColors.card,
                                  icon: Icon(Icons.cloud, size: 20),
                                  color:
                                      controller.showPointCloud.value
                                          ? AppColors.primary
                                          : AppColors.grey,
                                  onPressed: controller.togglePointCloud,
                                  tooltip: '', //Point cloud
                                ),
                              ),
                            ],
                          )
                          : SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
        //Relocation
        Card(
          elevation: 2,
          color: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(
                  () => IconButton(
                    hoverColor: AppColors.card,
                    icon: Icon(Icons.explore_rounded, size: 20),
                    color:
                        controller.showRelocation.value
                            ? AppColors.primary
                            : AppColors.grey,
                    onPressed: controller.toggleRelocation,
                    tooltip: '',
                  ),
                ),
                Obx(
                  () =>
                      controller.showRelocation.value
                          ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                hoverColor: AppColors.card,
                                icon: Icon(Icons.clear_rounded, size: 20),
                                color: AppColors.red,
                                onPressed: () {},
                                tooltip: '',
                              ),
                              IconButton(
                                hoverColor: AppColors.card,
                                icon: Icon(Icons.check_rounded, size: 20),
                                color: AppColors.green,
                                onPressed: () {},
                                tooltip: '',
                              ),
                            ],
                          )
                          : SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),

        Obx(
          () => CircleButton(
            tooltip: '', //Camera control
            borderRadius: 12,
            icon: Icons.camera_alt,
            backgroundColor: AppColors.card,
            iconColor:
                controller.showCamera.value
                    ? AppColors.primary
                    : AppColors.grey,
            onPressed: controller.toggleCamera,
          ),
        ),
      ],
    );
  }

  Widget _statusWidget(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _infoGroupBox(
          children: [
            _infoItem(icon: Icons.link_off, text: 'Disconnect'),
            _verticalDivider(),
            _infoItem(icon: Icons.battery_std, text: '50', unit: '%'),
          ],
        ),
        const SizedBox(width: 10),
        _infoGroupBox(
          children: [
            _infoItem(text: '10.00, 2.48', unit: 'm'),
            _verticalDivider(),
            _infoItem(text: '90.25', unit: 'deg'),
            _verticalDivider(),
            _infoItem(text: '1.05', unit: 'm/s'),
          ],
        ),
      ],
    );
  }

  Widget _infoGroupBox({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: children),
    );
  }

  Widget _infoItem({required String text, IconData? icon, String? unit}) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 4),
        ],
        Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (unit != null && unit.isNotEmpty) ...[
          const SizedBox(width: 4),
          Text(
            unit,
            style: TextStyle(
              color: AppColors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: 1,
      height: 18,
      color: AppColors.grey,
    );
  }
}
