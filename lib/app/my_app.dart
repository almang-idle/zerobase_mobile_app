import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/app/services/inactivity_service.dart';

import 'bindings/initial_bindings.dart';
import 'routes/app_pages.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
// Suggested code may be subject to a license. Learn more: ~LicenseLog:1545867620.
      theme: ThemeData(useMaterial3: false),
      initialBinding: InitialBindings(),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      routingCallback: (routing) {
        if (Get.isRegistered<InactivityService>()) {
          final resetTimerService = Get.find<InactivityService>();
          resetTimerService.startTimer();
        }
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
