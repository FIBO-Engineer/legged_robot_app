import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/main_conroller.dart';
import '../units/app_colors.dart' show AppColors;
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
    final c = Get.find<MainController>();
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _profileWidget(c, theme),
          const SizedBox(height: 16),
          _deviceWidget(c, theme, screen),
          const SizedBox(height: 16),
          _motionControlWidget(c, theme, screen),
        ],
      ),
    );
  }

  Widget _profileWidget(MainController c, ThemeData theme) {
    return Obx(() {
      final items = c.profiles;
      final current = c.robotType.value;

      if (items.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Text('No profiles', style: theme.textTheme.bodySmall),
        );
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          children:
              items.map((profile) {
                final robType = profile['robType'] as String? ?? '';
                final isSelected = robType == current;
                return TextButton.icon(
                  onPressed:
                      () => c.selectRobot(Map<String, dynamic>.from(profile)),
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
      );
    });
  }

  Widget _deviceWidget(
    MainController controller,
    ThemeData theme,
    ScreenSize screen,
  ) {
    final ipFormatter = [
      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9:./_-]')),
    ];

    final portrait = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 40,
          child: TextField(
            controller: controller.ipWebSocket.value,
            decoration: const InputDecoration(labelText: "Address"),
            inputFormatters: ipFormatter,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: TextField(
            controller: controller.ipCamera.value,
            decoration: const InputDecoration(labelText: "Camera"),
            inputFormatters: ipFormatter,
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () => controller.applyIpRobot(),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 46),
            backgroundColor: Colors.blue,
          ),
          child: Text('Connect', style: theme.textTheme.labelMedium),
        ),
      ],
    );

    final landscape = Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 40,
            child: TextField(
              controller: controller.ipWebSocket.value,
              decoration: const InputDecoration(labelText: "Address"),
              inputFormatters: ipFormatter,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 40,
            child: TextField(
              controller: controller.ipCamera.value,
              decoration: const InputDecoration(labelText: "Camera"),
              inputFormatters: ipFormatter,
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () => controller.applyIpRobot(),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(120, 46),
            backgroundColor: Colors.blue,
          ),
          child: Text('Connect', style: theme.textTheme.labelMedium),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Device', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        screen.isPortrait ? portrait : landscape,
      ],
    );
  }

  Widget _motionControlWidget(
    MainController controller,
    ThemeData theme,
    ScreenSize screen,
  ) {
    final compact = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sliderTile('Linear Speed', controller.linearSpeed),
        const SizedBox(height: 8),
        _sliderTile('Angular Speed', controller.angularSpeed),
        const SizedBox(height: 8),
        _sliderTile('Sampling Rate', controller.samplingRate),
      ],
    );

    final wide = Row(
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
            child: _sliderTile('Angular Speed', controller.angularSpeed),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: _sliderTile('Sampling Rate', controller.samplingRate),
          ),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Motion Control', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        screen.isPortrait ? compact : wide,
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
              padding: const EdgeInsets.only(left: 8),
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
