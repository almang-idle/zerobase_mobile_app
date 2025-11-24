import 'package:flutter/animation.dart';
import 'package:get/get.dart';
import 'package:myapp/app/cores/values/app_durations.dart';
import 'package:myapp/app/modules/keypad/bindings/keypad_bindings.dart';
import 'package:myapp/app/modules/keypad/views/keypad_view.dart';
import 'package:myapp/app/modules/price/bindings/price_bindings.dart';
import 'package:myapp/app/modules/price/views/price_view.dart';
import 'package:myapp/app/modules/product/bindings/product_bindings.dart';
import 'package:myapp/app/modules/product/views/product_view.dart';
import 'package:myapp/app/modules/refill/bindings/refill_bindings.dart';
import 'package:myapp/app/modules/refill/views/refill_view.dart';

import '../modules/logo/bindings/logo_bindings.dart';
import '../modules/logo/views/logo_view.dart';
import '../modules/main/bindings/main_bindings.dart';
import '../modules/main/views/main_view.dart';

part 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.DEFAULT_ROUTE;

  static final List<GetPage> routes = [
    GetPage(
      name: Routes.LOGO,
      page: () => LogoView(),
      binding: LogoBindings(),
      transitionDuration: AppDurations.routeTransition,
      transition: Transition.cupertino,
      curve: Curves.easeIn,
    ),
    GetPage(
      name: Routes.MAIN,
      page: () => MainView(),
      binding: MainBindings(),
      transitionDuration: AppDurations.routeTransition,
      transition: Transition.cupertino,
      curve: Curves.easeIn,
    ),
    GetPage(
      name: Routes.KEYPAD,
      page: () => KeypadView(),
      binding: KeypadBindings(),
      transitionDuration: AppDurations.routeTransition,
      transition: Transition.cupertino,
      curve: Curves.easeIn,
    ),
    GetPage(
      name: Routes.REFILL,
      page: () => RefillView(),
      binding: RefillBindings(),
      transitionDuration: AppDurations.routeTransition,
      transition: Transition.cupertino,
      curve: Curves.easeIn,
    ),
    GetPage(
      name: Routes.PRODUCT,
      page: () => ProductView(),
      binding: ProductBindings(),
      transitionDuration: AppDurations.routeTransition,
      transition: Transition.cupertino,
      curve: Curves.easeIn,
    ),
    GetPage(
      name: Routes.PRICE,
      page: () => PriceView(),
      binding: PriceBindings(),
      transitionDuration: AppDurations.routeTransition,
      transition: Transition.cupertino,
      curve: Curves.easeIn,
    )
  ];
}
