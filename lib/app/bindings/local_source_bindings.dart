import 'package:get/get.dart';
import 'package:myapp/app/services/device_service.dart';
import 'package:myapp/app/services/device_service_dummy.dart';

class LocalSourceBindings implements Bindings {
  @override
  void dependencies() {
    Get.put<DeviceService>(DeviceServiceDummy());
  }
}
