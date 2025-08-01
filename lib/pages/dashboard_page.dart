import 'package:flutter/material.dart';
import 'package:legged_robot_app/units/app_colors.dart';
import '../widgets/app_navigation_bar.dart';
import '../widgets/custom_widget.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double width = size.width;
    final bool isTablet = width >= 900 && width < 1024;
    final bool isDesktop = width >= 1024;

    if (isDesktop || isTablet) {
      // Desktop/Tablet: Sidebar left, Content right
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          children: [
            buildResponsiveNavBar(context), // sidebar (เมนู)
            Expanded(child: DashboardScreen()), // content
          ],
        ),
      );
    } else {
      // Mobile: Stack (content + floating/bottom nav)
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
    final size = MediaQuery.of(context).size;
    final double width = size.width;
    final bool isTablet = width >= 900 && width < 1024;
    final bool isDesktop = width >= 1024;
    final bool isPortrait = size.height > size.width;

    if (isDesktop || isTablet) {
      // Desktop/Tablet (Sidebar + Content)
      return Stack(
        children: [
          Positioned.fill(child: _mapWidget()),
          Positioned(
            top: 26,
            right: 26,
            child: _VideoWidget(
              width: width * 0.3,
              height: width * 0.3 * 9 / 16,
            ),
          ),
          Positioned(top: 26, left: 26, child: _statusWidget(context)),
          Positioned(bottom: 26, right: 26, child: _controlWidget()),
        ],
      );
    } else if (isPortrait) {
      // Mobile Portrait: Video บน, Map + status/fab ซ้อนด้านล่าง
      return Column(
        children: [
          AspectRatio(aspectRatio: 16 / 9, child: _VideoWidget()),
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
      // Mobile Landscape: Map เต็ม, Video ขวาบน, Status ซ้ายบน, FAB ขวาล่าง
      return Stack(
        children: [
          Positioned.fill(child: _mapWidget()),
          Positioned(
            top: 24,
            right: 24,
            child: _VideoWidget(
              width: width * 0.35,
              height: width * 0.35 * 9 / 16,
            ),
          ),
          Positioned(top: 24, left: 24, child: _statusWidget(context)),
          Positioned(bottom: 24, right: 24, child: _controlWidget()),
        ],
      );
    }
  }

  Widget _mapWidget() {
    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.scaffold,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text('MAP', style: TextStyle(color: Colors.white, fontSize: 28)),
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
        SizedBox(width: 16),
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
    final width = MediaQuery.of(context).size.width;
    final double boxWidth = width.clamp(100, 180);

    return Container(
      width: boxWidth,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.grey.withValues(alpha: 0.8 * 255),
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _statusRow(
            icon: Icons.flag,
            value: '10.00, 2.48',
            unit: 'm',
            fontSize: boxWidth / 11,
          ),
          SizedBox(height: 6),
          _statusRow(
            icon: Icons.change_history,
            value: '90.05',
            unit: 'deg',
            fontSize: boxWidth / 11,
          ),
          SizedBox(height: 6),
          _statusRow(
            icon: Icons.speed,
            value: '1.05',
            unit: 'm/s',
            fontSize: boxWidth / 11,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Color(0xFF232329),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.grey, size: fontSize * 0.95),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: fontSize.clamp(12, 16),
                letterSpacing: 1,
              ),
            ),
          ),
          SizedBox(width: 8),
          Text(
            unit,
            style: TextStyle(
              color: AppColors.grey,
              fontWeight: FontWeight.w400,
              fontSize: fontSize.clamp(10, 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoWidget extends StatelessWidget {
  final double? width;
  final double? height;
  const _VideoWidget({this.width, this.height});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Center(
          child: Text("VIDEO", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
