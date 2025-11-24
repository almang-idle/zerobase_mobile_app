import 'dart:async';
import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:myapp/app/cores/models/tag_logger.dart';
import 'package:myapp/app/cores/values/app_durations.dart';
import 'package:myapp/app/cores/values/weight_constants.dart';
import 'package:myapp/app/services/inactivity_service.dart';

import '../../../routes/app_pages.dart';
import '../../../services/device_service.dart';

class RefillController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late PageController pageController;

  final RxInt _rxCurTabIndex = RxInt(0);

  int get curTabIndex => _rxCurTabIndex.value;

  InactivityService get inactivityService => Get.find<InactivityService>();

  DeviceService get _deviceService => Get.find<DeviceService>();

  final Queue<double> _weightBuffer = Queue<double>();
  final RxBool _rxStableFlag = RxBool(false);

  bool get stableFlag => _rxStableFlag.value;
  late StreamSubscription _sub;
  final RxBool _rxMeasureFlag = RxBool(false);

  bool get measureFlag => _rxMeasureFlag.value;

  final _log = TagLogger("RefillController");

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(viewportFraction: 1, keepPage: true);
    Future.delayed(AppDurations.refillInstructionDelay, () {
      animatedToPage(1);
      subscriptionWeight();
    });
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
      _log.d(value);
      _weightBuffer.add(value);

      if (value <= WeightConstants.minimumWeight) {
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
        _sub.cancel();
        _deviceService.setTotalWeight(avg.round());
        if (!isClosed) {
          Get.toNamed(Routes.PRODUCT);
        }
      } else {
        _rxStableFlag(false);
      }
    });
  }

  @override
  void onClose() {
    pageController.dispose();
    _sub.cancel();
    super.onClose();
  }
}
