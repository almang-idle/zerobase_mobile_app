import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/app/cores/models/tag_logger.dart';
import 'package:myapp/app/cores/values/app_durations.dart';
import 'package:myapp/app/cores/values/weight_constants.dart';
import 'package:myapp/app/services/device_service.dart';

import '../../../routes/app_pages.dart';

class MainController extends GetxController
    with GetSingleTickerProviderStateMixin {
  DeviceService get _deviceService => Get.find<DeviceService>();

  final _log = TagLogger("MainController");
  late PageController pageController;
  final RxInt _rxCurTabIndex = RxInt(0);

  int get curTabIndex => _rxCurTabIndex.value;
  final Queue<double> _weightBuffer = Queue<double>();
  final RxBool _rxStableFlag = RxBool(false);

  bool get stableFlag => _rxStableFlag.value;
  late StreamSubscription _sub;
  final RxBool _rxMeasureFlag = RxBool(false);

  bool get measureFlag => _rxMeasureFlag.value;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(viewportFraction: 1, keepPage: true);
    subscriptionWeight();
  }

  void animatedToPage(index) {
    pageController.animateToPage(
      index,
      duration: AppDurations.pageAnimation,
      curve: Curves.easeIn,
    );
    _rxCurTabIndex.value = index;
  }

  void subscriptionWeight() {
    _sub = _deviceService.getWeight().listen((value) {
      _log.d(value.toString());
      _weightBuffer.add(value);

      if (value > WeightConstants.minimumWeight) {
        _rxMeasureFlag(true);
        if ((pageController.page ?? 0) <= 0) {
          animatedToPage(1);
        }
      } else {
        _rxMeasureFlag(false);
        animatedToPage(0);
        return;
      }

      if (_weightBuffer.length > WeightConstants.bufferSize) {
        _weightBuffer.removeFirst();
      } else {
        return;
      }

      double sum = 0;
      for (var e in _weightBuffer) {
        sum += e;
      }

      double avg = sum / _weightBuffer.length;
      bool isStable = true;
      for (var e in _weightBuffer) {
        if (e > avg + WeightConstants.stabilityTolerance ||
            e < avg - WeightConstants.stabilityTolerance) {
          isStable = false;
          break;
        }
      }
      if (isStable) {
        _rxStableFlag(true);
        _deviceService.setEmptyBottleWeight(avg.round());
        Future.delayed(AppDurations.weightStabilizationDelay, () {
          if (!isClosed) {
            Get.toNamed(Routes.KEYPAD);
          }
        });
        _sub.cancel();
      } else {
        _rxStableFlag(false);
      }
    }, onError: (err) {
      _log.e(err);
    }, onDone: () {
      _log.d("Weight stream is done");
    });
  }

  void resetAndRestart() {
    _log.d("--- MainController state is being reset and restarted ---");

    // 1. 진행 중이던 스트림 구독을 안전하게 취소합니다.
    _sub?.cancel();

    // 2. 모든 상태 변수들을 초기값으로 되돌립니다.
    _rxCurTabIndex.value = 0;
    _rxStableFlag.value = false;
    _rxMeasureFlag.value = false;
    _weightBuffer.clear();

    // 3. PageView를 애니메이션 없이 즉시 첫 페이지로 이동시킵니다.
    //    hasClients를 확인하여 PageView가 실제로 화면에 있을 때만 호출합니다.
    if (pageController.hasClients) {
      pageController.jumpToPage(0);
    }

    // 4. 저울 무게를 다시 구독하여 핵심 로직을 재시작합니다.
    subscriptionWeight();
  }

  @override
  void onClose() {
    pageController.dispose();
    _sub.cancel();
    super.onClose();
  }
}
