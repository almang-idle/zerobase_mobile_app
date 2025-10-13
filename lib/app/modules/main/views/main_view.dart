import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/app/cores/bases/base_view.dart';
import 'package:myapp/app/cores/widgets/appbar.dart';
import 'package:myapp/app/modules/main/controllers/main_controller.dart';
import 'package:myapp/app/modules/main/views/measure_weight_view.dart';
import 'package:myapp/app/modules/main/views/onboarding_view.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../cores/values/app_colors.dart';
import '../widgets/animated_arrow.dart';

class MainView extends BaseView<MainController> {
  MainView({super.key});

  @override
  PreferredSizeWidget? appBar(BuildContext context) {
    return AppBar(
      title: SmoothPageIndicator(
        controller: controller.pageController,
        count: pages.length,
        effect: const ScaleEffect(
          dotHeight: 10,
          dotWidth: 10,
          activeDotColor: AppColors.middleGray,
          dotColor: AppColors.middleGray,
          scale: 3.9,
          spacing: 30
        ),
        onDotClicked: (index){
          controller.pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeIn,
          );
        },
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1.0),
        child: Divider(height: 1.0, color: AppColors.gray),
      ),
    );
  }

  @override
  Widget body(BuildContext context) {
    return PageView(
      controller: controller.pageController,
      children: pages,
    );
  }

  @override
  Widget? bottomNavigationBar(BuildContext context) {
    return null;
  }

  List<Widget> pages = [
    OnboardingView(),
    MeasureWeightView(),
  ];
}
