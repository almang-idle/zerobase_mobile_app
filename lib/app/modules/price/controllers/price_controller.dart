import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:myapp/app/services/device_service.dart';
import 'package:myapp/app/services/inactivity_service.dart';

import '../../product/responses/product_response.dart';

class PriceController extends GetxController {
  // 이전 화면에서 전달받을 데이터
  late final Product selectedProduct;
  late final int measuredWeight;

  InactivityService get inactivityService => Get.find<InactivityService>();

  DeviceService get deviceService => Get.find<DeviceService>();

  // 컨트롤러가 초기화될 때 Get.arguments를 통해 데이터를 받음
  @override
  void onInit() {
    super.onInit();
    // arguments가 Map 형태라고 가정
    selectedProduct = Get.arguments['product'];
    measuredWeight = (deviceService.totalWeight.value ?? 0) -
        (deviceService.emptyBottleWeight.value ?? 0);
  }

  // 최종 가격 계산
  int get totalPrice => (measuredWeight * selectedProduct.unitPrice).round();

  // 전화번호 뒷자리 (MainController에서 가져오는 예시)
  String get phoneSuffix {
    return inactivityService.id;
  }

  // 숫자를 3자리마다 콤마로 포맷팅하는 기능 (intl 패키지 필요)
  String formatNumber(num number) {
    return NumberFormat('#,###').format(number);
  }

  // '다 담았어요' 버튼 클릭 시 실행될 함수
  void onConfirm() {
    Get.back(result: {
      'product': selectedProduct,
      'weight': measuredWeight,
      'price': totalPrice,
    });
  }
}
