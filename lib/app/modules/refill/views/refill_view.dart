import 'package:flutter/material.dart';
import 'package:myapp/app/modules/refill/controllers/refill_controller.dart';
import 'package:myapp/app/modules/refill/views/guide_fill_view.dart';
import 'package:myapp/app/modules/refill/views/guide_put_view.dart';

import '../../../cores/bases/base_view.dart';
import '../../../cores/widgets/appbar.dart';

class RefillView extends BaseView<RefillController> {
  @override
  bool? extendBodyBehindAppBar = true;

  @override
  PreferredSizeWidget? appBar(BuildContext context) {
    return MyAppbar.stepProgressAppBar(totalSteps: 5, currentStep: 3);
  }

  @override
  Widget body(BuildContext context) {
    return PageView(controller: controller.pageController, children: pages);
  }

  List<Widget> pages = [
    GuideFillView(),
    GuidePutView(),
  ];

  @override
  Widget? bottomNavigationBar(BuildContext context) {
    return null;
  }
}
