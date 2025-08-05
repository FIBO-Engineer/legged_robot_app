import 'package:flutter/material.dart';
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

    if (screen.isDesktop || screen.isTablet) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _profileWidget(),
            const SizedBox(height: 16),
            _deviceWidget(),
            const SizedBox(height: 16),
            _motionControlWidget(),
          ],
        ),
      );
    } else if (screen.isPortrait) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _profileWidget(),
            const SizedBox(height: 16),
            _deviceWidgetColumn(),
            const SizedBox(height: 16),
            _motionControlColumn(),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _profileWidget(),
            const SizedBox(height: 16),
            _deviceWidget(),
            const SizedBox(height: 16),
            _motionControlWidget(),
          ],
        ),
      );
    }
  }

  Widget _profileWidget() {
    MainController controller = Get.find();
    final List<Map<String, dynamic>> profiles = List<Map<String, dynamic>>.from(
      controller.storage.read('Setting') ?? [],
    );
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children:
              profiles.map((profile) {
                final robType = profile['robType'];
                final isSelected = robType == controller.robotType.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: TextButton.icon(
                    onPressed:
                        () => controller.selectRobot(
                          Map<String, dynamic>.from(profile),
                        ),
                    icon: Icon(
                      Icons.person,
                      color: isSelected ? Colors.lightBlue : Colors.grey,
                      size: 16,
                    ),
                    label: Text(
                      robType,
                      style: TextStyle(
                        color: isSelected ? Colors.lightBlue : Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor:
                          isSelected ? Colors.black : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      minimumSize: const Size(0, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _deviceWidget() {
    MainController controller = Get.find();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Device', style: TextStyle(color: Colors.white, fontSize: 16)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.ipWebSocket.value,
                decoration: InputDecoration(labelText: "Address"), style: TextStyle(color: Colors.white, fontSize: 14)
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: controller.ipCamera.value,
                decoration: InputDecoration(labelText: "Camera"), style: TextStyle(color: Colors.white, fontSize: 14)
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('Connect'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _deviceWidgetColumn() {
    MainController controller = Get.find();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Device', style: TextStyle(color: Colors.white, fontSize: 16)),
        const SizedBox(height: 8),
        TextField(
          controller: controller.ipWebSocket.value,
          decoration: InputDecoration(labelText: "Address"), style: TextStyle(color: Colors.white, fontSize: 14)
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller.ipCamera.value,
          decoration: InputDecoration(labelText: "Camera"), style: TextStyle(color: Colors.white, fontSize: 14)
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(40),
            backgroundColor: Colors.blue,
          ),
          child: const Text('Connect'),
        ),
      ],
    );
  }

  Widget _motionControlWidget() {
    final c = Get.find<MainController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Motion Control',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: _sliderTile('Linear speed', c.linearSpeed),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: _sliderTile('Angular speed', c.angularSpeed),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: _sliderTile('Sampling rate', c.samplingRate),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _motionControlColumn() {
    final c = Get.find<MainController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Motion Control',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        const SizedBox(height: 8),
        _sliderTile('Linear speed', c.linearSpeed),
        const SizedBox(height: 8),
        _sliderTile('Angular speed', c.angularSpeed),
        const SizedBox(height: 8),
        _sliderTile('Sampling rate', c.samplingRate),
      ],
    );
  }

  Widget _sliderTile(String label, RxDouble value) {
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
            Text(label, style: TextStyle(color: AppColors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                      inactiveColor: Colors.grey.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 28,
                  child: Text(
                    value.value.toStringAsFixed(1),
                    textAlign: TextAlign.right,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
