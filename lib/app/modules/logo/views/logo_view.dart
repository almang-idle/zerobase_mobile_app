import 'package:flutter/cupertino.dart';
import 'package:myapp/app/cores/bases/base_view.dart';
import 'package:myapp/app/modules/logo/controllers/logo_controller.dart';

class LogoView extends BaseView<LogoController> {
  @override
  PreferredSizeWidget? appBar(BuildContext context) {
    return null;
  }

  @override
  Widget body(BuildContext context) {
    return const Center(
        child: Text(
      "ZEROBASE",
      style: TextStyle(fontSize: 100, fontWeight: FontWeight.bold),
    ));
  }

  @override
  Widget? bottomNavigationBar(BuildContext context) {
    return null;
  }
}
