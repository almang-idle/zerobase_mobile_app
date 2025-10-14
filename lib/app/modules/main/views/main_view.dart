import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:myapp/app/cores/bases/base_view.dart';
import 'package:myapp/app/cores/widgets/appbar.dart';
import 'package:myapp/app/modules/main/controllers/main_controller.dart';
import 'package:myapp/app/modules/main/views/measure_weight_view.dart';
import 'package:myapp/app/modules/main/views/onboarding_view.dart';

class MainView extends BaseView<MainController> {
  MainView({super.key});

  Logger logger = Logger(printer: PrettyPrinter());

  @override
  PreferredSizeWidget? appBar(BuildContext context) {
    return MyAppbar.stepProgressAppBar(totalSteps: 5, currentStep: 1);
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
