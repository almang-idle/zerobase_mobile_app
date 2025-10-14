import 'package:logger/logger.dart';
import 'package:myapp/app/services/device_service.dart';

class DeviceServiceDummy extends DeviceService {
  final Logger _log = Logger();

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
}
