import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../controllers/main_controller.dart';

class MainBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<MainController>(MainController());
    Get.put<Logger>(Logger(), tag: "main");
  }
}
