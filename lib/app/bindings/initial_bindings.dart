import 'package:get/get.dart';
import 'package:myapp/app/modules/main/controllers/main_controller.dart';
import 'package:myapp/app/services/backend_service_impl.dart';
import 'package:myapp/app/services/inactivity_service.dart';

import '../services/backend_service.dart';
import 'local_source_bindings.dart';

class InitialBindings implements Bindings {
  @override
  void dependencies() {
    Get.put<InactivityService>(InactivityService());
    Get.put<BackendService>(BackendServiceImpl());
    LocalSourceBindings().dependencies();
    // Get.put<MainController>(MainController());
    // RepositoryBindings().dependencies();
  }
}
