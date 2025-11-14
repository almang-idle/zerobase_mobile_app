import 'package:get/get.dart';
import 'package:myapp/app/modules/main/controllers/main_controller.dart';
import 'package:myapp/app/services/backend_service_impl.dart';
import 'package:myapp/app/services/device_service_dummy.dart';
import 'package:myapp/app/services/device_service_impl.dart';
import 'package:myapp/app/services/inactivity_service.dart';

import '../services/backend_service.dart';
import '../services/device_service.dart';

class InitialBindings implements Bindings {
  @override
  void dependencies() {
    Get.put<InactivityService>(InactivityService());
    Get.put<BackendService>(BackendServiceImpl());
    Get.put<DeviceService>(DeviceServiceImpl());
    // Get.put<MainController>(MainController());
    // RepositoryBindings().dependencies();
  }
}
