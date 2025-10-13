import 'package:flutter/material.dart';
import 'package:myapp/app/cores/bases/base_widget.dart';
import 'package:myapp/app/cores/values/app_colors.dart';
import 'package:myapp/app/modules/main/controllers/main_controller.dart';

class MeasureWeightView extends BaseWidget<MainController> {
  MeasureWeightView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 126,
            width: 126,
            child: SizedBox(
              height: 102,
              width: 102,
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 12,
              ),
            ),
          ),
          SizedBox(
            height: 35,
          ),
          Text(
            "빈 병의 무게를 측정 중입니다",
            style: TextStyle(
              fontSize: 30,
              color: AppColors.primary,
            ),
          ),
          SizedBox(
            height: 35,
          ),
          Text(
            "병을 움직이지 마세요",
            style: TextStyle(
              fontSize: 45,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
