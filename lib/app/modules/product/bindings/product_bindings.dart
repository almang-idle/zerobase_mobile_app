import 'package:get/get.dart';

import '../controllers/product_controller.dart';

class ProductBindings implements Bindings {
  @override
  void dependencies() {
    Get.put<ProductController>(
      ProductController(),
    );
  }
}
