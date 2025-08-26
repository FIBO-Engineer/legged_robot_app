import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/urdf_controller.dart';
import '../../units/app_colors.dart';

class RobotModelView extends StatelessWidget {
  const RobotModelView({super.key});

  @override
  Widget build(BuildContext context) {
    final UrdfController urdfController = Get.find();

    return Obx(() {
      if (!urdfController.isInitialized) {
        return Stack(
          alignment: Alignment.topRight,
          children: [
            const Align(
              alignment: Alignment.topRight,
              child: CircularProgressIndicator(),
            ),
            Align(
              alignment: Alignment.topRight,
              child: SizedBox(
                width: 200,
                height: 250,
                child: urdfController.threeJs.build(),
              ),
            ),
          ],
        );
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            urdfController.updateSize(
              constraints.maxWidth * 0.15,
              constraints.maxHeight * 0.38,
            );
          });

          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Align(
              alignment: Alignment.topRight,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: constraints.maxWidth * 0.15,
                  height: constraints.maxHeight * 0.38,
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: AppColors.blueGrey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: urdfController.threeJs.build(),
                ),
              ),
            ),
          );
        },
      );
    });
  }
}
