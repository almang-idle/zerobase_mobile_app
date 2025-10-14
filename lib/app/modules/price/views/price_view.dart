import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/app/cores/bases/base_view.dart';
import 'package:myapp/app/cores/widgets/appbar.dart'; // MyAppbar 경로
import 'package:myapp/app/modules/price/controllers/price_controller.dart';

import '../../../cores/values/app_colors.dart';

class PriceView extends BaseView<PriceController> {
  PriceView({super.key});

  @override
  bool? extendBodyBehindAppBar = true;

  @override
  PreferredSizeWidget? appBar(BuildContext context) {
    // 이미지를 참고하여 AppBar 구현
    return MyAppbar.stepProgressAppBar(totalSteps: 5, currentStep: 4);
  }

  @override
  Widget body(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          right: 34,
          bottom: 30,
          child: SizedBox(
            width: 296,
            height: 90,
            child: ElevatedButton.icon(
              onPressed: () => controller.onConfirm(),
              icon: const Icon(
                Icons.check,
                color: Colors.white,
                size: 30,
              ),
              label: const Text('다 담았어요', style: TextStyle(fontSize: 30)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gray,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
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
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                controller.selectedProduct.name,
                style: const TextStyle(fontSize: 30, color: AppColors.primary),
              ),
              const SizedBox(height: 75),
              // 무게 및 g당 가격
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    controller.formatNumber(controller.measuredWeight.round()),
                    style: const TextStyle(
                        fontSize: 60, fontWeight: FontWeight.bold),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10.0, left: 8),
                    child: Text('g', style: TextStyle(fontSize: 30)),
                  ),
                  const SizedBox(width: 20),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Text(
                      'x ${controller.formatNumber(controller.selectedProduct.unitPrice)}원/1g',
                      style: const TextStyle(fontSize: 20, color: Colors.grey),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                width: 525,
                child: Divider(height: 30, thickness: 1),
              ),
              // 최종 가격
              Text(
                '${controller.formatNumber(controller.totalPrice)} 원',
                style:
                    const TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget? bottomNavigationBar(BuildContext context) {
    return null;
  }
}
