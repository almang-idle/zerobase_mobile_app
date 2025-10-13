import 'package:flutter/material.dart';
import 'package:myapp/app/cores/bases/base_view.dart';
import 'package:myapp/app/cores/widgets/appbar.dart';
import 'package:myapp/app/modules/main/controllers/main_controller.dart';

class MainView extends BaseView<MainController> {
  MainView({super.key});

  @override
  PreferredSizeWidget? appBar(BuildContext context) {
    return MyAppbar.main(title: "title");
  }

  @override
  Widget body(BuildContext context) {
    return Container();
  }

  @override
  Widget? bottomNavigationBar(BuildContext context) {
    return null;
  }
}
