import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../controllers/price_controller.dart';

class PriceBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PriceController>(() => PriceController());
  }
}
