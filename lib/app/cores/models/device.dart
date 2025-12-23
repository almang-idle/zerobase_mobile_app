import 'package:myapp/app/cores/enums/device_type.dart';

import '../values/ble_constants.dart';

class Device{
  final String id;
  final String name;
  final DeviceType type;

  Device({
    required this.id,
    required this.name,
    required this.type,
  });

}