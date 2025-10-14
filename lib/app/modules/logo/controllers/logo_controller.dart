import 'package:get/get.dart';
import 'package:myapp/app/routes/app_pages.dart';

class LogoController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(seconds: 2), () {
      Get.offNamed(Routes.MAIN);
    });
  }
}
