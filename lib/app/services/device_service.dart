import 'package:get/get.dart';
import 'package:myapp/app/cores/models/device.dart';

abstract class DeviceService extends GetxService{
  final Rx<int?> emptyBottleWeight = Rx<int?>(null);

  void setEmptyBottleWeight(int newWeight);

  final Rx<int?> totalWeight = Rx<int?>(null);

  void setTotalWeight(int newWeight);

  Stream<double> getWeight();

  void resetWeights() {
    emptyBottleWeight(null);
    totalWeight(null);
  }

  bool? getAdapterState();

  final Rx<bool> isScanning = Rx<bool>(false);

  Future connectToDevice(String deviceId);

  Device? getConnectedDevice();

  final RxList<Device> scannedDevices = RxList<Device>([]);

  void startScanWithDuration({Duration duration = const Duration(seconds: 5)});
}