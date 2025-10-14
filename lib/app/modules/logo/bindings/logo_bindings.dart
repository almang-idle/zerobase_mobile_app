import 'package:get/get.dart';
import 'package:myapp/app/modules/logo/controllers/logo_controller.dart';

class LogoBindings implements Bindings {
  @override
  void dependencies() {
    Get.put<LogoController>(LogoController());
  }
}
