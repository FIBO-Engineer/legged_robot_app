import 'package:get/get.dart';
import 'package:legged_robot_app/pages/mission_page.dart';
import '../bindings/root_binding.dart';
import '../pages/dashboard_page.dart';
import '../pages/service_page.dart';
import '../pages/teleoperated_page.dart';
import '../pages/setting_page.dart';

final List<GetPage> appRoutes = [
  GetPage(
    name: '/main',
    page: () => DashboardPage(),
    transition: Transition.noTransition,
    binding: RootBinding(),
    //   middlewares: [AuthMiddleware()],
  ),
  GetPage(
    name: '/teleoperated',
    page: () => TeleoperatedPage(),
    transition: Transition.noTransition,
    binding: RootBinding(),
    //   middlewares: [AuthMiddleware()],
  ),
  GetPage(
    name: '/mission',
    page: () => MissionPage(),
    transition: Transition.noTransition,
    binding: RootBinding(),
    //   middlewares: [AuthMiddleware()],
  ),
  GetPage(
    name: '/setting',
    page: () => SettingPage(),
    transition: Transition.noTransition,
    binding: RootBinding(),
    //   middlewares: [AuthMiddleware()],
  ),
  GetPage(
    name: '/service',
    page: () => ServicePage(),
    transition: Transition.noTransition,
    binding: RootBinding(),
    //   middlewares: [AuthMiddleware()],
  ),
  // GetPage(
  //   name: '/login',
  //   page: () => LoginScreen(),
  //   transition: Transition.noTransition,
  //   binding: RootBinding(),
  // ),
];
