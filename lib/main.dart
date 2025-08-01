import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'route/routes.dart';
import 'bindings/root_binding.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Robot Control',
      theme: ThemeData.dark(),
      initialBinding: RootBinding(),
      initialRoute: '/main',
      getPages: appRoutes,
    );
  }
}
