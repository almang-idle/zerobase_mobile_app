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
      Future.delayed(AppDurations.pageAnimation, (){
        subscriptionWeight();
      });
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

  bool bufferIsFull(){
    return _weightBuffer.length >= WeightConstants.bufferSize;
  }

  void addToBuffer(double value){
    _weightBuffer.add(value);
    if (_weightBuffer.length > WeightConstants.bufferSize) {
      _weightBuffer.removeFirst();
    } else {
      return;
    }
  }

  void subscriptionWeight() {
    _sub = _deviceService.getWeight().listen((value) {
      _log.d(value.toString());
      addToBuffer(value);

      if (value > (_deviceService.emptyBottleWeight.value ?? 0).toDouble() + WeightConstants.minimumWeight) {
        _rxMeasureFlag(true);
        if ((pageController.page ?? 0) <= 1) {
          animatedToPage(2);
        }
      } else {
        _rxMeasureFlag(false);
        animatedToPage(1);
        return;
      }

      if(!bufferIsFull()) return;

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
        _deviceService.setTotalWeight(avg.round());
        Future.delayed(AppDurations.weightStabilizationDelay, () {
          if (!isClosed) {
            Get.toNamed(Routes.PRODUCT);
          }
        });
        _sub.cancel();
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
