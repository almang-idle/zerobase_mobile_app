import 'package:get/get.dart';

import '../modules/main/bindings/main_bindings.dart';
import '../modules/main/views/main_view.dart';

part 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.DEFAULT_ROUTE;

  static final List<GetPage> routes = [
    GetPage(
      name: Routes.DEFAULT_ROUTE,
      page: () => MainView(),
      binding: MainBindings(),
    )
  ];
}
