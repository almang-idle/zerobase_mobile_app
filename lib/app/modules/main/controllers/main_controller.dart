import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainController extends GetxController with GetSingleTickerProviderStateMixin {
  late PageController pageController;
  final RxInt _rxCurTabIndex = RxInt(0);
  int get curTabIndex => _rxCurTabIndex.value;

  final List<Tab> myTabs = <Tab>[
    const Tab(text: '반납하기'),
  ];

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(viewportFraction: 0.8, keepPage: true);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
