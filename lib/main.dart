import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'route/routes.dart';
import 'bindings/root_binding.dart';
import 'package:toastification/toastification.dart';
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
        theme: ThemeData.dark(),
        initialBinding: RootBinding(),
        initialRoute: '/main',
        getPages: appRoutes,
        // builder: BotToastInit(),
        // navigatorObservers: [BotToastNavigatorObserver()],
      ),
    );
  }
}
