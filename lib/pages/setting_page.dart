import 'package:flutter/material.dart';
import '../units/app_constants.dart' show ScreenSize;
import '../widgets/app_navigation_bar.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
   final screen = ScreenSize(context);

    if (screen.isDesktop || screen.isTablet) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Row(
          children: [
            buildResponsiveNavBar(context), 
            Expanded(
              child: Center(
                child: Text(
                  "SETTING",
                  style: TextStyle(fontSize: 28, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Center(
              child: Text(
                "SETTING",
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
