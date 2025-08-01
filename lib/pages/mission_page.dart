import 'package:flutter/material.dart';
import '../widgets/app_navigation_bar.dart';

class MissionPage extends StatelessWidget {
  const MissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double width = size.width;
    final bool isTablet = width >= 900 && width < 1024;
    final bool isDesktop = width >= 1024;

    if (isDesktop || isTablet) {
      // Desktop/Tablet: Sidebar + Content
      return Scaffold(
        backgroundColor: Colors.black,
        body: Row(
          children: [
            buildResponsiveNavBar(context), // Sidebar
            Expanded(
              child: Center(
                child: Text(
                  "MISSION",
                  style: TextStyle(fontSize: 28, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Mobile: Stack (Content + Bottom/Floating Nav)
      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Center(
              child: Text(
                "MISSION",
                style: TextStyle(fontSize: 28, color: Colors.white),
              ),
            ),
            buildResponsiveNavBar(context),
          ],
        ),
      );
    }
  }
}
