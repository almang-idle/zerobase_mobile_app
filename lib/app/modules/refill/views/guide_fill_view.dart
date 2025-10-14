import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/app/cores/bases/base_widget.dart';
import 'package:myapp/app/modules/refill/controllers/refill_controller.dart';

import '../../../cores/values/app_colors.dart';
import '../widgets/animated_arrow_up.dart';

class GuideFillView extends BaseWidget<RefillController>{
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned(
            left: 0, right: 0, bottom: 100, child: AnimatedArrowUpImage()),
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
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '빈 병을 들고',
                style: TextStyle(fontSize: 30, color: AppColors.black),
              ),
              const SizedBox(
                height: 20,
              ),
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                        text: '리필존',
                        style: TextStyle(
                            fontSize: 30,
                            color: AppColors.black,
                            fontWeight: FontWeight.w600)),
                    TextSpan(
                        text: '으로 이동해',
                        style: TextStyle(fontSize: 30, color: AppColors.black)),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                '제품을 원하는 만큼 담아주세요',
                style: TextStyle(fontSize: 30, color: AppColors.black),
              ),
            ],
          ),
        )
      ],
    );
  }
}