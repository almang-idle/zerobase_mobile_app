import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../controllers/refill_controller.dart';

class RefillBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RefillController>(() => RefillController());
    Get.put<Logger>(Logger(), tag: "refill");
  }
}
