import 'dart:async';

import 'package:get/get.dart';
import 'package:myapp/app/cores/models/tag_logger.dart';
import 'package:myapp/app/cores/values/app_durations.dart';
import 'package:myapp/app/modules/logo/views/bluetooth_settings_dialog.dart';
import 'package:myapp/app/modules/logo/views/scan_devices_dialog.dart';
import 'package:myapp/app/routes/app_pages.dart';
import 'package:myapp/app/services/device_service.dart';

class LogoController extends GetxController {
  DeviceService get deviceService => Get.find<DeviceService>();
  Timer? _checkConnectionTimer;
  final _log = TagLogger("LogoController");

  @override
  void onInit() {
    super.onInit();
    _checkConnectionTimer = Timer.periodic(AppDurations.connectionCheckInterval, (timer) {
      if (!deviceService.adapterState.value) {
        if(!(Get.isDialogOpen ?? false)){
          Get.dialog(
            const BluetoothSettingsDialog(),
            barrierDismissible: false,
          );
        }
        _log.e("Bluetooth is off. Showing Bluetooth settings dialog.");
        return;
      }
      if (!deviceService.isConnected.value) {
        if(!(Get.isDialogOpen ?? false)){
          Get.dialog(const ScanDevicesDialog());
        }
        _log.e("No device connected. Redirecting to device connection page.");
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
