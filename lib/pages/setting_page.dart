import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:legged_robot_app/widgets/custom_widget.dart';
import '../controllers/main_conroller.dart';
import '../units/app_colors.dart';
import '../units/app_constants.dart';
import '../widgets/app_navigation_bar.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screen = ScreenSize(context);

    if (screen.isDesktop || screen.isTablet) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildResponsiveNavBar(context),
            Expanded(child: SettingScreen()),
          ],
        ),
      );
    } else if (screen.isPortrait) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            Expanded(child: SettingScreen()),
            buildResponsiveNavBar(context),
          ],
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            Positioned.fill(child: SettingScreen()),
            buildResponsiveNavBar(context),
          ],
        ),
      );
    }
  }
}

//---------------------- Setting Content Responsive ---------------------//
class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screen = ScreenSize(context);
    final theme = Theme.of(context);
    final MainController controller = Get.find();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statusWidget(controller),
              _profileWidget(controller, theme),
            ],
          ),
          const SizedBox(height: 20),
          _Section(
            title: 'Basic Setting',
            child: _BasicSetting(controller: controller, screen: screen),
          ),
          const SizedBox(height: 20),
          _Section(
            title: 'Motion Control',
            child: _MotionControl(controller: controller, screen: screen),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: 8,
              children: [
                CustomButton(
                  text: 'Default',
                  icon: Icons.restore_rounded,
                  onPressed: controller.resetToDefault,
                ),
                CustomButton(
                  text: 'Save',
                  icon: Icons.save_rounded,
                  foregroundColor: AppColors.green,
                  onPressed: controller.saveCurrent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusWidget(MainController controller) {
    return Row(
      children: [
        Obx(
          () => Icon(
            controller.connectionRos.value == 'Connected'
                ? Icons.link_rounded
                : Icons.link_off_rounded,
            color:
                controller.connectionRos.value == 'Connected'
                    ? AppColors.green
                    : AppColors.red,
            size: 24,
          ),
        ),
        SizedBox(width: 8),
        Obx(
          () => Text(
            controller.connectionRos.value,
            style: TextStyle(
              color:
                  controller.connectionRos.value == 'Connected'
                      ? AppColors.green
                      : AppColors.red,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _profileWidget(MainController controller, ThemeData theme) {
    return Obx(() {
      if (controller.profiles.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.scaffold,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Text('No profiles', style: theme.textTheme.bodySmall),
        );
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.scaffold,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          children: List.generate(controller.profiles.length, (i) {
            final p = controller.profiles[i];
            final isSelected = i == controller.selectedIndex.value;
            return TextButton.icon(
              onPressed: () => controller.selectRobot(i),
              icon: Icon(
                (p.robotType == 'G1' || p.robotType == 'H1')
                    ? Icons.person
                    : Icons.pets_rounded,
                color: isSelected ? Colors.white : AppColors.grey,
              ),
              label: Text(
                p.robotType,
                style: TextStyle(
                  fontSize: 14,
                  color: isSelected ? Colors.white : AppColors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor:
                    isSelected ? AppColors.primary : Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                minimumSize: const Size(0, 46),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            );
          }),
        ),
      );
    });
  }
}

//---------------------- Widgets ---------------------//
class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _BasicSetting extends StatelessWidget {
  final MainController controller;
  final ScreenSize screen;
  const _BasicSetting({required this.controller, required this.screen});

  @override
  Widget build(BuildContext context) {
    final inputFmt = [
      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9:./_-]')),
    ];

    Widget tf({
      required TextEditingController controller,
      required String label,
    }) {
      return TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        inputFormatters: inputFmt,
      );
    }

    return Obx(() {
      if (screen.isPortrait) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            tf(
              controller: controller.ipWebSocket.value,
              label: 'Websocket Address',
            ),
            const SizedBox(height: 12),
            tf(controller: controller.ipCamera.value, label: 'Camera Address'),
            const SizedBox(height: 12),
            Obx(
              () => CustomButton(
                text: controller.disconnect.value ? 'Connect' : 'Disconnect',
                icon:
                    !controller.disconnect.value
                        ? Icons.link_off_rounded
                        : Icons.link_rounded,
                foregroundColor:
                    !controller.disconnect.value
                        ? AppColors.red
                        : AppColors.primary,
                onPressed: () {
                  if (controller.disconnect.value) {
                    controller.connectRobot();
                  } else {
                    controller.disconnectRobot();
                  }
                },
              ),
            ),
          ],
        );
      }
      return Row(
        children: [
          Expanded(
            flex: 3,
            child: tf(
              controller: controller.ipWebSocket.value,
              label: 'Websocket Address',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 4,
            child: tf(
              controller: controller.ipCamera.value,
              label: 'Camera Address',
            ),
          ),
          const SizedBox(width: 12),

          Obx(
            () => CustomButton(
              text: controller.disconnect.value ? 'Connect' : 'Disconnect',
              icon:
                  !controller.disconnect.value
                      ? Icons.link_off_rounded
                      : Icons.link_rounded,
              foregroundColor:
                  !controller.disconnect.value
                      ? AppColors.red
                      : AppColors.primary,
              onPressed: () {
                if (controller.disconnect.value) {
                  controller.connectRobot();
                } else {
                  controller.disconnectRobot();
                }
              },
            ),
          ),
        ],
      );
    });
  }
}

class _MotionControl extends StatelessWidget {
  final MainController controller;
  final ScreenSize screen;
  const _MotionControl({required this.controller, required this.screen});

  @override
  Widget build(BuildContext context) {
    Widget tile(String label, RxDouble v) {
      return Obx(
        () => Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.scaffold,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackShape: const RoundedRectSliderTrackShape(),
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 8,
                        ),
                        overlayShape: SliderComponentShape.noOverlay,
                      ),
                      child: Slider(
                        value: v.value,
                        onChanged: (val) => v.value = val,
                        min: 0,
                        max: 1,
                        activeColor: Colors.blue,
                        inactiveColor: AppColors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    v.value.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ],
          ),
        ),
      );
    }

    if (screen.isPortrait) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          tile('Linear Speed', controller.linearSpeed),
          const SizedBox(height: 12),
          tile('Angular Speed', controller.angularSpeed),
          const SizedBox(height: 12),
          tile('Sampling Rate', controller.samplingRate),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: tile('Linear Speed', controller.linearSpeed)),
        const SizedBox(width: 12),
        Expanded(child: tile('Angular Speed', controller.angularSpeed)),
        const SizedBox(width: 12),
        Expanded(child: tile('Sampling Rate', controller.samplingRate)),
      ],
    );
  }
}
