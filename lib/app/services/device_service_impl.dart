import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:myapp/app/cores/models/device.dart';
import 'package:myapp/app/cores/models/tag_logger.dart';
import 'package:myapp/app/services/device_service.dart';

class DeviceServiceImpl extends DeviceService {
  final _log = TagLogger("DeviceServiceImpl");
  final _rxScannedResults = RxList<ScanResult>([]);
  final Guid WEIGHT_SERVICE_UUID =
      Guid("0000181D-0000-1000-8000-00805F9B34FB"); // 예: Weight Scale Service
  final Guid WEIGHT_CHAR_UUID = Guid("00002A98-0000-1000-8000-00805F9B34FB");

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
    // 예시 1: 데이터가 "3.14" 같은 문자열인 경우 (사용자의 원래 코드)
    // (가능성 매우 낮음)
    // String decodedValue = String.fromCharCodes(data);
    // return double.tryParse(decodedValue) ?? 0.0;

    // 예시 2: 데이터가 2바이트(Little-Endian) 정수이고 100을 나눠야 kg인 경우
    // 예: [23, 10] -> (10 * 256 + 23) = 2583 -> 25.83kg
    if (data.length >= 2) {
      // ByteData를 사용한 안전한 파싱
      final byteData = ByteData.sublistView(Uint8List.fromList(data));
      // 2바이트 부호 없는 정수(Little Endian)
      int rawValue = byteData.getUint16(0, Endian.little);
      return rawValue / 100.0;
    }

    // 예시 3: 4바이트 Float(Little-Endian)인 경우
    // if (data.length >= 4) {
    //   final byteData = ByteData.sublistView(Uint8List.fromList(data));
    //   return byteData.getFloat32(0, Endian.little);
    // }

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
        device.connect(license: License.free);
        var connectionSubscription = connectToDeviceStream(deviceId);
        device.cancelWhenDisconnected(connectionSubscription);
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
          type: r.device.advName,
        ));
        _rxScannedResults.add(r);
      }
      _log.i("Scanned Devices: ${scannedDevices.length}");
    });
  }

  StreamSubscription connectToDeviceStream(String deviceId) {
    ScanResult result =
        _rxScannedResults.where((r) => r.device.remoteId.str == deviceId).first;

    return result.device.connectionState.listen((state) {
      if (state == BluetoothConnectionState.connected) {
        isConnected(true);
        connectedDevice(toDevice(result));
        _log.i("Device $deviceId connected.");
      } else {
        isConnected(false);
        connectedDevice(null);
        _log.i("Device $deviceId disconnected.");
      }
    });
  }

  Device toDevice(ScanResult result) {
    return Device(
      id: result.device.remoteId.str,
      name: result.advertisementData.advName,
      type: result.device.advName,
    );
  }
}
