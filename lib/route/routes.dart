import 'package:get/get.dart';
import 'package:legged_robot_app/pages/mission_page.dart';
import '../bindings/root_binding.dart';
import '../pages/home_page.dart';
import '../pages/mapping_page.dart';
import '../pages/service_page.dart';
import '../pages/setting_page.dart';

final List<GetPage> appRoutes = [
  GetPage(
    name: '/main',
    //page: () => DashboardPage(),
    page: () => HomePage(),
    transition: Transition.noTransition,
    binding: RootBinding(),
    //   middlewares: [AuthMiddleware()],
  ),
  GetPage(
    name: '/teleoperated',
  //  page: () => TeleoperatedPage(),
    page: () =>  MappingPage(),
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
