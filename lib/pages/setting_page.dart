import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:legged_robot_app/units/app_colors.dart' show AppColors;
import '../controllers/main_conroller.dart';
import '../units/app_constants.dart' show ScreenSize;
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
          children: [
            buildResponsiveNavBar(context),
            Expanded(child: const SettingScreen()),
          ],
        ),
      );
    } else if (screen.isPortrait) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            Expanded(child: const SettingScreen()),
            buildResponsiveNavBar(context),
          ],
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [const SettingScreen(), buildResponsiveNavBar(context)],
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
    MainController controller = Get.find();
    final theme = Theme.of(context);

    if (screen.isDesktop || screen.isTablet) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _profileWidget(controller, theme),
            const SizedBox(height: 16),
            _deviceWidget(controller, theme, screen),
            const SizedBox(height: 16),
            _motionControlWidget(controller, theme, screen),
          ],
        ),
      );
    } else if (screen.isPortrait) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _profileWidget(controller, theme),
            const SizedBox(height: 16),
            _deviceWidget(controller, theme, screen),
            const SizedBox(height: 16),
            _motionControlWidget(controller, theme, screen),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _profileWidget(controller, theme),
            const SizedBox(height: 16),
            _deviceWidget(controller, theme, screen),
            const SizedBox(height: 16),
            _motionControlWidget(controller, theme, screen),
          ],
        ),
      );
    }
  }

  Widget _profileWidget(MainController controller, ThemeData theme) {
    final List<Map<String, dynamic>> profiles = List<Map<String, dynamic>>.from(
      controller.storage.read('Setting') ?? [],
    );
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children:
              profiles.map((profile) {
                final robType = profile['robType'];
                final isSelected = robType == controller.robotType.value;
                return TextButton.icon(
                  onPressed: () {
                    controller.selectRobot(Map<String, dynamic>.from(profile));
                  },
                  icon: Icon(
                    Icons.person,
                    color: isSelected ? AppColors.primary : AppColors.kNavColor,
                    size: 16,
                  ),
                  label: Text(
                    robType,
                    style: TextStyle(
                      color:
                          isSelected ? AppColors.primary : AppColors.kNavColor,
                      fontSize: 12,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor:
                        isSelected ? AppColors.scaffold : Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _deviceWidget(
    MainController controller,
    ThemeData theme,
    ScreenSize screen,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Device', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        screen.isPortrait
            ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 40,
                  child: TextField(
                    controller: controller.ipWebSocket.value,
                    decoration: InputDecoration(labelText: "Address"),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[http:/\.0-9:]'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: TextField(
                    controller: controller.ipCamera.value,
                    decoration: InputDecoration(labelText: "Camera"),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[http:/\.0-9:]'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 46),
                    backgroundColor: Colors.blue,
                  ),
                  child: Text('Connect', style: theme.textTheme.labelMedium),
                ),
              ],
            )
            : Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: TextField(
                      controller: controller.ipWebSocket.value,
                      decoration: InputDecoration(labelText: "Address"),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[http:/\.0-9:]'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: TextField(
                      controller: controller.ipCamera.value,
                      decoration: InputDecoration(labelText: "Camera"),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(120, 46),
                    backgroundColor: Colors.blue,
                  ),
                  child: Text('Connect', style: theme.textTheme.labelMedium),
                ),
              ],
            ),
      ],
    );
  }

  Widget _motionControlWidget(
    MainController controller,
    ThemeData theme,
    ScreenSize screen,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Motion Control', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        screen.isPortrait
            ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sliderTile('Linear Speed', controller.linearSpeed),
                const SizedBox(height: 8),
                _sliderTile('Angular Speed', controller.angularSpeed),
                const SizedBox(height: 8),
                _sliderTile('Sampling Rate', controller.samplingRate),
              ],
            )
            : Row(
              children: [
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: _sliderTile('Linear Speed', controller.linearSpeed),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: _sliderTile(
                      'Angular Speed',
                      controller.angularSpeed,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: _sliderTile(
                      'Sampling Rate',
                      controller.samplingRate,
                    ),
                  ),
                ),
              ],
            ),
      ],
    );
  }

  Widget _sliderTile(String label, RxDouble value) {
    final theme = Theme.of(Get.context!);
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text(label, style: theme.textTheme.titleSmall),
            ),

            Row(
              children: [
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(Get.context!).copyWith(
                      trackShape: const RoundedRectSliderTrackShape(),
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 8,
                      ),
                      overlayShape: SliderComponentShape.noOverlay,
                    ),
                    child: Slider(
                      value: value.value,
                      onChanged: (v) => value.value = v,
                      min: 0,
                      max: 1,
                      activeColor: Colors.blue,
                      inactiveColor: AppColors.grey,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  value.value.toStringAsFixed(1),
                  textAlign: TextAlign.right,
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(width: 4),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
