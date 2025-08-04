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
            top: 20,
            right: 20,
            child: CameraView(
              width: screen.width * 0.3,
              height: screen.width * 0.3 * 9 / 16,
              borderRadius: 12,
            ),
          ),
          Positioned(top: 20, left: 20, child: _statusWidget(context)),
          Positioned(bottom: 20, right: 20, child: _controlWidget()),
        ],
      );
    } else if (screen.isPortrait) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16, right: 16, left: 16),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: CameraView(borderRadius: 12),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(child: _mapWidget()),
                Positioned(top: 20, left: 20, child: _statusWidget(context)),
                Positioned(bottom: 20, right: 20, child: _controlWidget()),
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
            top: 20,
            right: 20,
            child: CameraView(
              width: screen.width * 0.35,
              height: screen.width * 0.35 * 9 / 16,
              borderRadius: 12,
            ),
          ),
          Positioned(top: 20, left: 20, child: _statusWidget(context)),
          Positioned(bottom: 20, right: 20, child: _controlWidget()),
        ],
      );
    }
  }

  Widget _mapWidget() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.scaffold,
        borderRadius: BorderRadius.circular(12),
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
        CircleButton(
          icon: Icons.workspaces_rounded,
          backgroundColor: AppColors.card,
          iconColor: Colors.white,
          onPressed: () {},
        ),
        const SizedBox(width: 16),
        CircleButton(
          icon: Icons.error,
          backgroundColor: AppColors.card,
          iconColor: AppColors.red,
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

    return IntrinsicWidth(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _statusRow(
            icon: Icons.flag,
            value: '10.00, 2.48',
            unit: 'm',
            fontSize: fontSize,
          ),
          const SizedBox(height: 6),
          _statusRow(
            icon: Icons.navigation_rounded,
            value: '90.05',
            unit: 'deg',
            fontSize: fontSize,
          ),
          const SizedBox(height: 6),
          _statusRow(
            icon: Icons.speed,
            value: '1.05',
            unit: 'm/s',
            fontSize: fontSize,
          ),
        ],
      ),
    );
  }

  Widget _statusRow({
    required IconData icon,
    required String value,
    required String unit,
    double fontSize = 14,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF232329),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,

        children: [
          Icon(icon, color: AppColors.grey, size: fontSize * 1.2),
          const SizedBox(width: 8),
          Text(
            value,
            textAlign: TextAlign.left,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: fontSize.clamp(8, 14),
              letterSpacing: fontSize < 10 ? 0.2 : 1,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 8),
          Text(
            unit,
            textAlign: TextAlign.left,
            style: TextStyle(
              color: AppColors.grey,
              fontWeight: FontWeight.w500,
              fontSize: fontSize.clamp(8, 12),
            ),
          ),
        ],
      ),
    );
  }
}
