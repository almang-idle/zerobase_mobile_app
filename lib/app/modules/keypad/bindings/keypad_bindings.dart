import 'package:get/get.dart';
import 'package:myapp/app/modules/keypad/controllers/keypad_controller.dart';

class KeypadBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KeypadController>(() => KeypadController());
  }
}
