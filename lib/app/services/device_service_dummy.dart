import 'package:get/get.dart';
import 'package:myapp/app/cores/enums/device_type.dart';
import 'package:myapp/app/cores/models/device.dart';
import 'package:myapp/app/cores/models/tag_logger.dart';
import 'package:myapp/app/services/device_service.dart';

class DeviceServiceDummy extends DeviceService {
  final _log = TagLogger("DeviceServiceDummy");

  final Rx<bool?> _adapterState = Rx<bool?>(null);
  final Rx<Device?> _connectedDevice = Rx<Device?>(null);

  @override
  bool? getAdapterState() => _adapterState.value;

  @override
  Device? getConnectedDevice() => _connectedDevice.value;

  @override
  void onInit() {
    super.onInit();
    _log.i("DeviceServiceDummy initialized.");
    Future.delayed(const Duration(seconds: 3), () {
      _adapterState.value = true;
      scannedDevices(
        [
          Device(id: "Device_001", name: "Scale_01", type: DeviceType.SCALE),
          Device(id: "Device_002", name: "Scale_02", type: DeviceType.SCALE),
          Device(id: "Device_003", name: "Scale_03", type: DeviceType.SCALE),
          Device(id: "Device_997", name: "", type: DeviceType.OTHER),
          Device(id: "Device_998", name: "", type: DeviceType.OTHER),
          Device(id: "Device_999", name: "", type: DeviceType.OTHER),
        ],
      );
      _log.i("Simulated device connected.");
    });
  }

  @override
  Stream<double> getWeight() {
    return Stream.periodic(
      const Duration(milliseconds: 100),
      (count) {
        // emptyBottleWeight의 타입이 double? 라고 가정합니다.
        final currentEmptyWeight = emptyBottleWeight.value ?? 0.0;

        if (currentEmptyWeight <= 0.0) {
          if (count < 30) {
            return 0.0; // .0을 추가하여 double로 변경
          } else if (count < 60) {
            // 100.0으로 만들어 연산 결과가 double이 되도록 함
            return count * 100.0;
          } else {
            return 10000.0; // .0을 추가하여 double로 변경
          }
        } else {
          if (count < 60) {
            return currentEmptyWeight + (count - 30) * 100.0;
          } else {
            return currentEmptyWeight + 3000.0;
          }
        }
      },
    ).asBroadcastStream();
  }

  @override
  void setEmptyBottleWeight(int newWeight) {
    emptyBottleWeight(newWeight);
    _log.i("Empty Bottle Weight: $emptyBottleWeight");
  }

  @override
  void setTotalWeight(int newWeight) {
    totalWeight(newWeight);
    _log.i("Total Bottle Weight: $totalWeight");
  }


  @override
  void startScanWithDuration({Duration duration = const Duration(seconds: 5)}) {
    // TODO: implement startScanWithDuration
  }

  @override
  Future connectToDevice(String deviceId) {
    // TODO: implement connectToDevice
    throw UnimplementedError();
  }
}
