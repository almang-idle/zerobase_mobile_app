import 'dart:async';
import 'dart:ui';

import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:myapp/app/routes/app_pages.dart';
import 'package:myapp/app/services/device_service.dart';

import '../modules/main/controllers/main_controller.dart';

class InactivityService extends GetxService {
  Timer? _timer;
  final RxInt _rxRemainingSeconds = RxInt(0);

  int get remainingSeconds => _rxRemainingSeconds.value;
  final _timerDuration = const Duration(minutes: 3, seconds: 30);
  Logger log = Logger(printer: PrettyPrinter());

  final RxString _rxId = RxString('');

  String get id => _rxId.value;

  void startTimer() {
    _timer?.cancel(); // Cancel any existing timer
    _rxRemainingSeconds(_timerDuration.inSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_rxRemainingSeconds.value > 0) {
        // 1초씩 감소
        _rxRemainingSeconds.value--;
      } else {
        // 시간이 0이 되면 타이머를 멈추고 홈으로 이동
        timer.cancel();
        log.i("Inactivity timeout. Navigating to default route.");
        _rxId('');
        DeviceService deviceService = Get.find<DeviceService>();
        deviceService.resetWeights();
        if (!(Get.currentRoute == Routes.DEFAULT_ROUTE)) {
          Get.offAllNamed(Routes.DEFAULT_ROUTE);
        }
      }
    });
  }

  void reset() {
    _timer?.cancel();
    _rxId('');
    DeviceService deviceService = Get.find<DeviceService>();
    deviceService.resetWeights();
    if (!(Get.currentRoute == Routes.DEFAULT_ROUTE)) {
      Get.offAllNamed(Routes.DEFAULT_ROUTE);
    }
  }

  void cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void setId(String newId) {
    _rxId(newId);
  }
}
