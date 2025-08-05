import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legged_robot_app/units/app_themes.dart';
import 'route/routes.dart';
import 'bindings/root_binding.dart';
import 'package:toastification/toastification.dart';

import 'units/app_colors.dart';
//import 'dart:html' as html;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.config(
    // enableLog: false,
    defaultTransition: Transition.noTransition,
    defaultOpaqueRoute: true,
    defaultPopGesture: false,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Robot Control',
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Color(0xFF02ABFF),
          scaffoldBackgroundColor: Color(0xFF101010),
          appBarTheme: AppBarTheme(
            backgroundColor: Color(0xFF09090B),
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.white),
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          ),
          colorScheme: ColorScheme.dark(
            primary: Color(0xFF02ABFF),
            secondary: Color(0xFF02ABFF),
          ),
          inputDecorationTheme: inputDecorationTheme(),
          progressIndicatorTheme: ProgressIndicatorThemeData(
            color: AppColors.primary,
          ),
        ),
        initialBinding: RootBinding(),
        initialRoute: '/main',
        getPages: appRoutes,
        // builder: BotToastInit(),
        // navigatorObservers: [BotToastNavigatorObserver()],
      ),
    );
  }
}
