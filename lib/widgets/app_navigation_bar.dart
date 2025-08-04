import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../units/app_colors.dart';
import '../units/app_constants.dart';

/// Navigation Bar Responsive (Sidebar, Bottom, Floating)
class AppNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  const AppNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screen = ScreenSize(context);

    if (screen.isDesktop || screen.isTablet) {
      return _SidebarNavigation(selectedIndex: selectedIndex, onTap: onTap);
    } else if (screen.isPortrait) {
      return _BottomNavigation(selectedIndex: selectedIndex, onTap: onTap);
    } else {
      return _FloatingNavigation(selectedIndex: selectedIndex, onTap: onTap);
    }
  }
}

class _SidebarNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  const _SidebarNavigation({required this.selectedIndex, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.android, color: Colors.white, size: 24),

          Column(
            children: [
              _NavIcon(
                icon: Icons.dashboard,
                selected: selectedIndex == 0,
                onTap: () => onTap(0),
              ),
              SizedBox(height: 16),
              _NavIcon(
                icon: Icons.gamepad,
                selected: selectedIndex == 1,
                onTap: () => onTap(1),
              ),
              SizedBox(height: 16),
              _NavIcon(
                icon: Icons.flag,
                selected: selectedIndex == 2,
                onTap: () => onTap(2),
              ),
              SizedBox(height: 16),
              _NavIcon(
                icon: Icons.settings,
                selected: selectedIndex == 3,
                onTap: () => onTap(3),
              ),
            ],
          ),

          Icon(Icons.circle, color: AppColors.red, size: 10),
        ],
      ),
    );
  }
}

class _BottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  const _BottomNavigation({required this.selectedIndex, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.scaffold,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.grey,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      currentIndex: selectedIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard, size: 20),
          label: '',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.gamepad, size: 20), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.flag, size: 20), label: ''),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings, size: 20),
          label: '',
        ),
      ],
    );
  }
}

class _FloatingNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  const _FloatingNavigation({required this.selectedIndex, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.scaffold,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _NavIcon(
              icon: Icons.dashboard,
              size: 20,
              selected: selectedIndex == 0,
              onTap: () => onTap(0),
            ),
            const SizedBox(width: 28),
            _NavIcon(
              icon: Icons.gamepad,
              size: 20,
              selected: selectedIndex == 1,
              onTap: () => onTap(1),
            ),
            const SizedBox(width: 28),
            _NavIcon(
              icon: Icons.flag,
              size: 20,
              selected: selectedIndex == 2,
              onTap: () => onTap(2),
            ),
            const SizedBox(width: 28),
            _NavIcon(
              icon: Icons.settings,
              size: 20,
              selected: selectedIndex == 3,
              onTap: () => onTap(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final bool selected;
  final VoidCallback onTap;

  const _NavIcon({
    required this.icon,
    this.size = 24,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.grey;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Icon(icon, color: color, size: size),
      ),
    );
  }
}

///-------------------------- Responsive Wrapper -------------------------- ///
Widget buildResponsiveNavBar(BuildContext context) {
  final navIndex = getNavIndexByRoute(Get.currentRoute);
  final screen = ScreenSize(context);

  final navBar = AppNavigationBar(
    selectedIndex: navIndex,
    onTap: (idx) {
      switch (idx) {
        case 0:
          Get.offAllNamed('/main');
          break;
        case 1:
          Get.offAllNamed('/teleoperated');
          break;
        case 2:
          Get.offAllNamed('/mission');
          break;
        case 3:
          Get.offAllNamed('/setting');
          break;
      }
    },
  );

  if (screen.isDesktop || screen.isTablet) {
    return navBar;
  } else if (screen.isPortrait) {
    return Align(alignment: Alignment.bottomCenter, child: navBar);
  } else {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 20,
      child: Center(child: navBar),
    );
  }
}

int getNavIndexByRoute(String route) {
  switch (route) {
    case '/main':
      return 0;
    case '/teleoperated':
      return 1;
    case '/mission':
      return 2;
    case '/setting':
      return 3;
    default:
      return 0;
  }
}
