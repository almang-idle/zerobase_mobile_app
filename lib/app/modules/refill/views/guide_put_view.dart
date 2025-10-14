import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/app/cores/bases/base_widget.dart';
import 'package:myapp/app/modules/refill/controllers/refill_controller.dart';

import '../../../cores/values/app_colors.dart';
import '../../main/widgets/animated_arrow_down.dart';

class GuidePutView extends BaseWidget<RefillController> {
  GuidePutView({super.key});

  String _formatDuration(int totalSeconds) {
    // 전체 초를 Duration 객체로 변환
    final duration = Duration(seconds: totalSeconds);
    // 분(minute) 부분을 추출 (예: 185초 -> 3분)
    final minutes = duration.inMinutes;
    // 분을 제외한 나머지 초(second) 부분을 계산 (예: 185초 -> 5초)
    final seconds = totalSeconds % 60;

    // padLeft(2, '0')를 사용해 항상 두 자리로 표시 (예: 5 -> "05")
    final minutesString = minutes.toString().padLeft(2, '0');
    final secondsString = seconds.toString().padLeft(2, '0');

    return '$minutesString:$secondsString';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned(
            left: 0, right: 0, bottom: 100, child: AnimatedArrowDownImage()),
        Obx(() {
          return Positioned(
            bottom: 30,
            left: 52,
            child: Text(
              "${controller.inactivityService.id} 님 사용 중",
              style: const TextStyle(fontSize: 30, color: AppColors.black),
            ),
          );
        }),
        Obx(() {
          return Positioned(
            bottom: 30,
            right: 43,
            child: Text(
              "남은 시간 \n ${_formatDuration(controller.inactivityService.remainingSeconds)}",
              style: const TextStyle(fontSize: 30, color: AppColors.black),
              textAlign: TextAlign.end,
            ),
          );
        }),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                        text: controller.inactivityService.id,
                        style: const TextStyle(
                            fontSize: 70,
                            color: AppColors.black,
                            fontWeight: FontWeight.w500)),
                    const TextSpan(
                        text: ' 님,',
                        style: TextStyle(fontSize: 30, color: AppColors.black)),
                  ],
                ),
              ),
              const Text(
                '리필을 하셨다면 병을 여기에 올려주세요',
                style: TextStyle(fontSize: 30, color: AppColors.black),
              ),
              const SizedBox(height: 80),
            ],
          ),
        )
      ],
    );
  }
}
