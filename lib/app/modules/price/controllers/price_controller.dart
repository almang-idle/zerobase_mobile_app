import 'dart:async';
import 'dart:collection';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:myapp/app/services/device_service.dart';
import 'package:myapp/app/services/inactivity_service.dart';

import '../../product/responses/product_response.dart';

class PriceController extends GetxController {
  // 이전 화면에서 전달받을 데이터
  final Logger _log = Logger();
  late final Product selectedProduct;
  final RxInt _rxProductWeight = RxInt(0);

  int get productWeight => _rxProductWeight.value;
  final Queue<double> _weightBuffer = Queue<double>();

  InactivityService get inactivityService => Get.find<InactivityService>();

  DeviceService get deviceService => Get.find<DeviceService>();

  late StreamSubscription _sub;

  final double _weightErrorConst = 1;
  final double _weightMin = 100;
  final RxBool _rxStableFlag = RxBool(false);

  bool get stableFlag => _rxStableFlag.value;

  // 컨트롤러가 초기화될 때 Get.arguments를 통해 데이터를 받음
  @override
  void onInit() {
    super.onInit();
    // arguments가 Map 형태라고 가정
    selectedProduct = Get.arguments['product'];
    subscriptionWeight();
  }

  // 최종 가격 계산
  int get totalPrice => (productWeight * selectedProduct.unitPrice).round();

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
    if (stableFlag) {
      Get.back(result: {
        'product': selectedProduct,
        'weight': productWeight,
        'price': totalPrice,
      });
    }
  }

  void subscriptionWeight() {
    _sub = deviceService.getWeight().listen((value) {
      _log.d(value);
      _weightBuffer.add(value);
      _rxProductWeight(
          value.round() - (deviceService.emptyBottleWeight.value ?? 0) >= 0
              ? value.round() - (deviceService.emptyBottleWeight.value ?? 0)
              : 0);

      if (_weightBuffer.length > 20) {
        _weightBuffer.removeFirst();
      } else {
        return;
      }

      if (value < _weightMin) {
        _rxStableFlag(false);
        return;
      }

      double sum = 0;
      for (var e in _weightBuffer) {
        sum += e;
      }

      double avg = sum / _weightBuffer.length;
      bool testFlag = true;
      for (var e in _weightBuffer) {
        if (e > avg + _weightErrorConst || e < avg - _weightErrorConst) {
          testFlag = false;
        }
      }
      if (testFlag) {
        _rxStableFlag(true);
      } else {
        _rxStableFlag(false);
      }
    }, onError: (err) {
      _log.e(err);
    }, onDone: () {
      _log.d("Weight stream is done");
    });
  }
}
