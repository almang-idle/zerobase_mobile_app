import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../values/app_colors.dart';

class MyAppbar {
  static PreferredSizeWidget main({
    required String title,
  }) {
    return AppBar(
      title: Text(title),
    );
  }

  static AppBar stepProgressAppBar({
    required int totalSteps,
    required int currentStep,
  }) {
    const double _activeSize = 39.0;
    const double _inactiveSize = 10.0;
    const Color _activeColor = AppColors.middleGray; // 밝은 회색
    const Color _inactiveColor = AppColors.middleGray;
    const Color _activeTextColor = Colors.black;

    return AppBar(
      // AppBar 제목 중앙 정렬
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () {
          Get.back();
        },
        icon: const Icon(
          Icons.arrow_back,
          color: Color(0xFFCFCFCF),
          size: 39,
        ),
      ),
      title: Row(
        // Row 내부 아이템들도 중앙 정렬
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalSteps, (index) {
          int step = index + 1;
          bool isActive = step == currentStep;
          return Padding(
            // 각 원 사이의 간격
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: Container(
              width: isActive ? _activeSize : _inactiveSize,
              height: isActive ? _activeSize : _inactiveSize,
              decoration: BoxDecoration(
                color: isActive ? _activeColor : _inactiveColor,
                shape: BoxShape.circle,
              ),
              // 활성화된 원에만 숫자를 표시
              child: isActive
                  ? Center(
                      child: Text(
                        '$step',
                        style: const TextStyle(
                          color: _activeTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : null,
            ),
          );
        }),
      ),
      actions: [
        IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(Icons.close))
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1.0),
        child: Divider(height: 1.0, color: AppColors.divider),
      ),
    );
  }
}
