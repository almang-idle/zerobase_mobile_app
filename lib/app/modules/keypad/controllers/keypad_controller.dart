import 'package:get/get.dart';
import 'package:myapp/app/services/inactivity_service.dart';

import '../../../routes/app_pages.dart';

class KeypadController extends GetxController {
  final RxString pin = RxString('');
  InactivityService get inactivityService => Get.find<InactivityService>();

  // 숫자가 눌렸을 때 호출되는 함수
  void onNumberPressed(String number) {
    if (pin.value.length < 4) {
      pin.value += number;
    }
  }

  // 지우기 버튼이 눌렸을 때 호출되는 함수
  void onBackspacePressed() {
    if (pin.value.isNotEmpty) {
      pin.value = pin.value.substring(0, pin.value.length - 1);
    }
  }

  // 확인 버튼이 눌렸을 때 호출되는 함수
  void onSubmit() {
    if (pin.value.length == 4) {
      // 4자리가 모두 입력되었을 때 실행할 로직 (예: 다음 화면으로 이동)
      inactivityService.setId(pin.value);
      Get.toNamed(Routes.REFILL);
    }
  }
}
