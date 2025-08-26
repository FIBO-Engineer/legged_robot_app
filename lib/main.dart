import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legged_robot_app/units/app_themes.dart';
import 'route/routes.dart';
import 'bindings/root_binding.dart';
import 'package:toastification/toastification.dart';
import 'units/app_colors.dart';
// ignore: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.config(
    // enableLog: false,
    defaultTransition: Transition.noTransition,
    defaultOpaqueRoute: true,
    defaultPopGesture: false,
  );

 html.document.onContextMenu.listen((event) => event.preventDefault());
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
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.background,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.white),
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          ),
          colorScheme: ColorScheme.dark(
            primary: AppColors.primary,
            secondary: AppColors.primary,
          ),
          textTheme: textTheme(),
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
