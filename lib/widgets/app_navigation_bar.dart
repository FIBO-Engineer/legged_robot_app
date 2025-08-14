import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../units/app_colors.dart';
import '../units/app_constants.dart';

/// Navigation Bar Responsive (Sidebar, Bottom, Floating)
class AppNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final ValueNotifier<bool>? floatingNavExpanded;

  const AppNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    this.floatingNavExpanded,
  });

  @override
  Widget build(BuildContext context) {
    final screen = ScreenSize(context);

    if (screen.isDesktop || screen.isTablet) {
      return _SidebarNavigation(selectedIndex: selectedIndex, onTap: onTap);
    } else if (screen.isPortrait) {
      return _BottomNavigation(selectedIndex: selectedIndex, onTap: onTap);
    } else {
      return _FloatingNavigation(
        selectedIndex: selectedIndex,
        onTap: onTap,
        isExpandedNotifier: floatingNavExpanded!,
      );
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
      color: AppColors.scaffold,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Icon(Icons.android, color: Colors.white, size: 24),
          SizedBox(height: 28),
          Column(
            children: [
              _NavIcon(
                icon: Icons.dashboard,
                size: 20,
                selected: selectedIndex == 0,
                onTap: () => onTap(0),
              ),
              SizedBox(height: 12),
              _NavIcon(
                icon: Icons.gamepad_rounded,
                size: 20,
                selected: selectedIndex == 1,
                onTap: () => onTap(1),
              ),
              SizedBox(height: 12),
              _NavIcon(
                icon: Icons.flag_rounded,
                size: 20,
                selected: selectedIndex == 2,
                onTap: () => onTap(2),
              ),
              SizedBox(height: 12),
              _NavIcon(
                icon: Icons.settings_rounded,
                size: 20,
                selected: selectedIndex == 3,
                onTap: () => onTap(3),
              ),
              SizedBox(height: 12),
              _NavIcon(
                icon: Icons.auto_fix_high_rounded,
                size: 20,
                selected: selectedIndex == 4,
                onTap: () => onTap(4),
              ),
            ],
          ),
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
          icon: Icon(Icons.dashboard_rounded, size: 20),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.gamepad_rounded, size: 20),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.flag_rounded, size: 20),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_rounded, size: 20),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.auto_fix_high_rounded, size: 20),
          label: '',
        ),
      ],
    );
  }
}

class _FloatingNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final ValueNotifier<bool> isExpandedNotifier;

  const _FloatingNavigation({
    required this.selectedIndex,
    required this.onTap,
    required this.isExpandedNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isExpandedNotifier,
      builder: (context, isExpanded, _) {
        return InkWell(
          borderRadius: BorderRadius.circular(20),
          hoverColor: AppColors.background,
          focusColor: AppColors.background,
          splashColor: AppColors.background,
          highlightColor: AppColors.background,
          onLongPress: () {
            isExpandedNotifier.value = !isExpanded;
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.scaffold,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isExpanded) ...[
                  _navButton(0, Icons.dashboard_rounded),
                  _spacer(),
                  _navButton(1, Icons.gamepad_rounded),
                  _spacer(),
                  _navButton(2, Icons.flag_rounded),
                  _spacer(),
                  _navButton(3, Icons.settings_rounded),
                  _spacer(),
                  _navButton(4, Icons.auto_fix_high_rounded),
                ] else ...[
                  _navButton(selectedIndex, _iconForIndex(selectedIndex)),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _navButton(int index, IconData icon) {
    final selected = selectedIndex == index;
    final color = selected ? AppColors.primary : AppColors.grey;

    return GestureDetector(
      onTap: () {
        onTap(index);
      },
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _spacer() => const SizedBox(width: 28);

  IconData _iconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.dashboard;
      case 1:
        return Icons.gamepad;
      case 2:
        return Icons.flag;
      case 3:
        return Icons.settings;
      case 4:
        return Icons.auto_fix_high_rounded;
      default:
        return Icons.help_outline;
    }
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final bool selected;
  final VoidCallback onTap;

  const _NavIcon({
    required this.icon,
    required this.selected,
    required this.onTap,
    this.size = 24.0,
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
final ValueNotifier<bool> floatingNavExpanded = ValueNotifier(true);

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
        case 4:
          Get.offAllNamed('/service');
          break;
      }
    },
    floatingNavExpanded: floatingNavExpanded,
  );

  if (screen.isDesktop || screen.isTablet) {
    return navBar;
  } else if (screen.isPortrait) {
    return Align(alignment: Alignment.bottomCenter, child: navBar);
  } else {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 10,
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
    case '/service':
      return 4;
    default:
      return 0;
  }
}
