import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class BaseWidget<Controller extends GetxController>
    extends GetWidget<Controller> {
  final GlobalKey globalKey = GlobalKey();

  BaseWidget({super.key});

  @override
  Widget build(BuildContext context);
}
