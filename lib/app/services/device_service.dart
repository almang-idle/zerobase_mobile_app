import 'package:get/get.dart';

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
}