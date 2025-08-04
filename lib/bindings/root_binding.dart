import 'package:get/get.dart';

import '../controllers/app_controller.dart';
import '../controllers/main_conroller.dart';

class RootBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(MainController(), permanent: true);
    Get.put(AppController(), permanent: true);
  }
}
