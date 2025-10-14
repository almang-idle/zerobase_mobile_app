import 'package:flutter/material.dart';
import 'package:myapp/app/cores/bases/base_widget.dart';
import 'package:myapp/app/modules/main/controllers/main_controller.dart';

import '../../../cores/values/app_colors.dart';
import '../widgets/animated_arrow_down.dart';

class OnboardingView extends BaseWidget<MainController> {
  OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned(
          left: 0,
          right: 0,
          bottom: 120,
          child: AnimatedArrowDownImage(),
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                        text: '마음에 드는 ',
                        style: TextStyle(fontSize: 30, color: AppColors.gray)),
                    TextSpan(
                        text: '리필제품',
                        style:
                            TextStyle(fontSize: 30, color: AppColors.primary)),
                    TextSpan(
                        text: '을 고르셨다면,',
                        style: TextStyle(fontSize: 30, color: AppColors.gray)),
                  ],
                ),
              ),
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                        text: '가져오신 ',
                        style:
                            TextStyle(fontSize: 30, color: AppColors.primary)),
                    TextSpan(
                        text: '빈 병',
                        style: TextStyle(
                            fontSize: 45,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600)),
                    TextSpan(
                        text: '을 이곳에 올려주세요',
                        style:
                            TextStyle(fontSize: 30, color: AppColors.primary)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
