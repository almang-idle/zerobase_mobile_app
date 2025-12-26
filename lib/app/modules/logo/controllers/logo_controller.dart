import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:myapp/app/cores/models/tag_logger.dart';
import 'package:myapp/app/modules/logo/views/bluetooth_settings_dialog.dart';
import 'package:myapp/app/modules/logo/views/scan_devices_dialog.dart';
import 'package:myapp/app/routes/app_pages.dart';
import 'package:myapp/app/services/device_service.dart';

class LogoController extends GetxController {
  DeviceService get deviceService => Get.find<DeviceService>();
  final _log = TagLogger("LogoController");

  @override
  void onInit() {
    super.onInit();
    // 위젯이 모두 빌드된 후에 체크

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        _checkConnection();
      });
    });
  }

  void _checkConnection() {
    _log.i("_checkConnection called");
    _log.i("AdapterState: ${deviceService.getAdapterState()}");
    _log.i("ConnectedDevice: ${deviceService.getConnectedDevice()}");

    if (deviceService.getAdapterState() == false) {
      Get.dialog(
        const BluetoothSettingsDialog(),
        barrierDismissible: false,
      );
      _log.e("Bluetooth is off. Showing Bluetooth settings dialog.");
      return;
    }
    if (deviceService.getConnectedDevice() == null) {
      if (!(Get.isDialogOpen ?? false)) {
        Get.dialog(const ScanDevicesDialog(), barrierDismissible: false);
      }
      _log.e("No device connected. Showing scan devices dialog.");
    } else {
      _log.e("Device is connected: ${deviceService.getConnectedDevice()!.id}");
      _log.e("Navigating to MAIN page");
      Get.offNamed(Routes.MAIN);
    }
  }
}
