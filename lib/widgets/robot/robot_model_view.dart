import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/urdf_controller.dart';

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
            padding: const EdgeInsets.fromLTRB(10, 26, 10, 10),
            child: Align(
              alignment: Alignment.topRight,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: constraints.maxWidth * 0.15,
                  height: constraints.maxHeight * 0.38,
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
