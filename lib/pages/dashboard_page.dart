import 'package:flutter/material.dart';
import 'package:legged_robot_app/units/app_colors.dart';
import '../units/app_constants.dart';
import '../widgets/app_navigation_bar.dart';
import '../widgets/camera/camera_view.dart';
import '../widgets/custom_widget.dart';

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

    if (screen.isDesktop || screen.isTablet) {
      return Stack(
        children: [
          Positioned.fill(child: _mapWidget()),
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
          Positioned(bottom: 10, right: 10, child: _controlWidget()),
        ],
      );
    } else if (screen.isPortrait) {
      return Column(
        children: [
          AspectRatio(aspectRatio: 16 / 9, child: CameraView()),

          Expanded(
            child: Stack(
              children: [
                Positioned.fill(child: _mapWidget()),
                Positioned(top: 10, left: 10, child: _statusWidget(context)),
                Positioned(bottom: 10, right: 10, child: _controlWidget()),
              ],
            ),
          ),
        ],
      );
    } else {
      return Stack(
        children: [
          Positioned.fill(child: _mapWidget()),
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
          Positioned(bottom: 10, right: 10, child: _controlWidget()),
        ],
      );
    }
  }

  Widget _mapWidget() {
    return Container(
      // padding: const EdgeInsets.all(12),
      // margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        // borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: const Text(
        'MAP',
        style: TextStyle(color: Colors.white, fontSize: 28),
      ),
    );
  }

  Widget _controlWidget() {
    return Row(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(0, 56),
            backgroundColor: AppColors.card,
            foregroundColor: AppColors.red,
          ),
          onPressed: () {},
          child: Text(
            "EMG",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        const SizedBox(width: 12),
        CircleButton(
          icon: Icons.workspaces_rounded,
          backgroundColor: AppColors.card,
          iconColor: Colors.white,
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _statusWidget(BuildContext context) {
    final screen = ScreenSize(context);
    double boxWidth =
        screen.isDesktop
            ? 180
            : screen.isPortrait
            ? 120
            : 110;
    final double fontSize = (boxWidth / 10).clamp(9, 14);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _infoGroupBox(
          children: [
            _infoItem(
              icon: Icons.link_off,
              text: 'Disconnect',
              fontSize: fontSize,
            ),
            _verticalDivider(),
            _infoItem(
              icon: Icons.battery_std,
              text: '50 %',
              fontSize: fontSize,
            ),
          ],
        ),
        const SizedBox(width: 10),
        _infoGroupBox(
          children: [
            _infoItem(text: '10.00, 2.48', unit: 'm', fontSize: fontSize),
            _verticalDivider(),
            _infoItem(text: '90.25', unit: 'deg', fontSize: fontSize),
            _verticalDivider(),
            _infoItem(text: '1.05', unit: 'm/s', fontSize: fontSize),
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

  Widget _infoItem({
    IconData? icon,
    required String text,
    String? unit,
    required double fontSize,
  }) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: Colors.white, size: fontSize * 1.2),
          const SizedBox(width: 4),
        ],
        Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
        if (unit != null && unit.isNotEmpty) ...[
          const SizedBox(width: 4),
          Text(
            unit,
            style: TextStyle(
              color: AppColors.grey,
              fontSize: fontSize * 0.85,
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
