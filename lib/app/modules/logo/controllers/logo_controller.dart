import 'dart:async';

import 'package:get/get.dart';
import 'package:myapp/app/cores/models/tag_logger.dart';
import 'package:myapp/app/modules/logo/views/scan_devices_dialog.dart';
import 'package:myapp/app/routes/app_pages.dart';
import 'package:myapp/app/services/device_service.dart';

class LogoController extends GetxController {
  DeviceService get deviceService => Get.find<DeviceService>();
  Timer? _checkConnectionTimer;
  final log = TagLogger("LogoController");

  @override
  void onInit() {
    super.onInit();
    _checkConnectionTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!deviceService.adapterState.value) {
        // Get.toNamed();
        log.e("Bluetooth is off. Redirecting to Bluetooth setup page.");
        return;
      }
      if (!deviceService.isConnected.value) {
        if(!(Get.isDialogOpen ?? false)){
          Get.dialog(const ScanDevicesDialog());
        }
        log.e("No device connected. Redirecting to device connection page.");
      } else {
        Get.offNamed(Routes.MAIN);
      }
    });
  }

  @override
  void onClose() {
    super.onClose();
    _checkConnectionTimer?.cancel();
  }
}
