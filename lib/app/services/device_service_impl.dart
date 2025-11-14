import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:myapp/app/cores/enums/device_type.dart';
import 'package:myapp/app/cores/models/device.dart';
import 'package:myapp/app/cores/models/tag_logger.dart';
import 'package:myapp/app/services/device_service.dart';

class DeviceServiceImpl extends DeviceService {
  final _log = TagLogger("DeviceServiceImpl");
  final _rxScannedResults = RxList<ScanResult>([]);
  final Guid WEIGHT_SERVICE_UUID =
      Guid("a5fbf7b2-696d-45c9-8f59-4f3592a23b49"); // 예: Weight Scale Service
  final Guid WEIGHT_CHAR_UUID = Guid("6e170b83-7095-4a4c-b01b-ab15e2355ddd");

  @override
  void onInit() {
    super.onInit();
    if (FlutterBluePlus.isSupported == false) {
      _log.e("Bluetooth not supported by this device");
      return;
    }
    FlutterBluePlus.adapterState.listen((state) {
      if (state == BluetoothAdapterState.on) {
        adapterState(true);
        FlutterBluePlus.startScan();
        var scanSubscription = scanForDevices();
        FlutterBluePlus.cancelWhenScanComplete(scanSubscription);
      } else {
        adapterState(false);
        FlutterBluePlus.stopScan();

        if (!kIsWeb && Platform.isAndroid) {
          FlutterBluePlus.turnOn();
        }
      }
      _log.i("Bluetooth Adapter State: $adapterState");
    });
  }

  @override
  Stream<double> getWeight() async* {
    BluetoothDevice? device;
    try {
      device = FlutterBluePlus.connectedDevices
          .firstWhere((d) => d.remoteId.str == connectedDevice.value!.id);
    } catch (e) {
      _log.e("getWeight: 연결된 장치를 찾을 수 없습니다. $e");
      yield 0.0; // 스트림에 에러 값을 보내고
      return; // 함수(스트림) 종료
    }

    List<BluetoothService> services;
    try {
      services = await device.discoverServices();
      _log.i("Discovered ${services.length} services.");
    } catch (e) {
      _log.e("서비스 발견 중 오류: $e");
      yield 0.0;
      return;
    }

    BluetoothCharacteristic? weightChar;

    try {
      var service = services.firstWhere((s) => s.uuid == WEIGHT_SERVICE_UUID);
      weightChar =
          service.characteristics.firstWhere((c) => c.uuid == WEIGHT_CHAR_UUID);
    } catch (e) {
      _log.e("원하는 무게 특성(UUID)을 찾지 못했습니다. $e");
      yield 0.0;
      return;
    }

    // 4. 구독(Notify) 시작
    try {
      await weightChar.setNotifyValue(true);

      await for (List<int> data in weightChar.lastValueStream) {
        if (data.isEmpty) continue; // 데이터가 비어있으면 무시

        _log.i("Raw data received: $data");

        double weight = _parseWeightData(data);
        yield weight;
      }
    } catch (e) {
      _log.e("구독 또는 데이터 수신 중 오류: $e");
      yield 0.0; // 에러 발생 시 0.0을 스트림에 보냄
    }
  }

  //TODO: 파싱
  double _parseWeightData(List<int> data) {
    if (data.length != 4) {
      _log.w("수신된 데이터가 4바이트가 아닙니다. 파싱 실패: $data");
      return 0.0;
    }

    // 2. List<int>를 ByteData로 변환
    try {
      // Uint8List.fromList(data)는 새 목록을 생성합니다.
      // .buffer.asByteData()는 해당 버퍼에 대한 뷰를 생성합니다.
      final byteData = ByteData.sublistView(Uint8List.fromList(data));

      // 3. 4바이트를 32비트 float, Little-Endian 방식으로 파싱
      return byteData.getFloat32(0, Endian.little);

    } catch (e) {
      _log.e("ByteData 파싱 중 오류 발생: $e, Data: $data");
      return 0.0;
    }

    _log.w("데이터 파싱 실패: $data");
    return 0.0; // 파싱 실패 시 기본값
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
  void connectToDevice(String deviceId) {
    for (var device in scannedDevices) {
      if (device.id == deviceId) {
        BluetoothDevice device = _rxScannedResults
            .where((r) => r.device.remoteId.str == deviceId)
            .first
            .device;
        device.connect(license: License.free).then((_){
          isConnected(true);
          connectedDevice(toDevice(device));

          _log.i("Device $deviceId connected.");
        }).catchError((e){
          isConnected(false);
          connectedDevice(null);
          _log.i("Device $deviceId disconnected.");
        });
        return;
      }
    }
    isConnected(false);
    _log.w("Device with ID $deviceId not found among scanned devices.");
  }

  StreamSubscription scanForDevices() {
    return FlutterBluePlus.onScanResults.listen((results) {
      scannedDevices.clear();
      _rxScannedResults.clear();
      for (var r in results) {
        scannedDevices.add(Device(
          id: r.device.remoteId.str,
          name: r.advertisementData.advName,
          type:
              r.device.advName == "Scale" ? DeviceType.SCALE : DeviceType.OTHER,
        ));
        _rxScannedResults.add(r);
      }
      _log.i("Scanned Devices: ${scannedDevices.length}");
    });
  }

  // StreamSubscription connectToDeviceStream(String deviceId) {
  //   ScanResult result =
  //       _rxScannedResults.where((r) => r.device.remoteId.str == deviceId).first;
  //
  //   return result.device.connectionState.listen((state) {
  //     if (state == BluetoothConnectionState.connected) {
  //       isConnected(true);
  //       connectedDevice(toDevice(result));
  //       _log.i("Device $deviceId connected.");
  //     } else {
  //       isConnected(false);
  //       connectedDevice(null);
  //       _log.i("Device $deviceId disconnected.");
  //     }
  //   });
  // }

  // Device toDevice(ScanResult result) {
  //   return Device(
  //     id: result.device.remoteId.str,
  //     name: result.advertisementData.advName,
  //     type: result.device.advName == "Scale"
  //         ? DeviceType.SCALE
  //         : DeviceType.OTHER,
  //   );
  // }

  Device toDevice(BluetoothDevice device){
    return Device(
      id: device.remoteId.str,
      name: device.advName,
      type: device.advName == "Scale"
          ? DeviceType.SCALE
          : DeviceType.OTHER,
    );
  }


}
