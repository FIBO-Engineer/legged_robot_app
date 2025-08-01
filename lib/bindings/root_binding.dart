import 'package:get/get.dart';

import '../controllers/main_conroller.dart';

class RootBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(MainController());
  }
}
