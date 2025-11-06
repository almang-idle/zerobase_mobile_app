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

  final Rx<bool> adapterState = Rx<bool>(false);

  final Rx<bool> isConnected = Rx<bool>(false);

  void connectToDevice(String deviceId);

  final Rx<Device?> connectedDevice = Rx<Device?>(null);

  final RxList<Device> scannedDevices = RxList<Device>([]);
}