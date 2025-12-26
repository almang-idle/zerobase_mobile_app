import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:myapp/app/cores/enums/device_type.dart';
import 'package:myapp/app/cores/models/device.dart';
import 'package:myapp/app/cores/models/tag_logger.dart';
import 'package:myapp/app/cores/values/ble_constants.dart';
import 'package:myapp/app/routes/app_pages.dart';
import 'package:myapp/app/services/device_service.dart';

class DeviceServiceImpl extends DeviceService {
  final _log = TagLogger("DeviceServiceImpl");
  final _rxScannedResults = RxList<ScanResult>([]);
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;

  final Rx<bool?> _adapterState = Rx<bool?>(null);
  final Rx<Device?> _connectedDevice = Rx<Device?>(null);

  @override
  bool? getAdapterState() => _adapterState.value;

  @override
  Device? getConnectedDevice() => _connectedDevice.value;

  @override
  void onInit() {
    super.onInit();
    FlutterBluePlus.isSupported.then((isSupported) {
      if (!isSupported) {
        _log.e("Bluetooth LE is not supported on this device.");
        _adapterState.value = false;
        return;
      }
    });
    FlutterBluePlus.adapterState.listen((state) {
      if (state == BluetoothAdapterState.on) {
        _adapterState.value = true;
        startScanWithDuration();
      } else {
        _adapterState.value = false;
        if (!kIsWeb && Platform.isAndroid) {
          FlutterBluePlus.turnOn();
        }
      }
      _log.i("Bluetooth Adapter State: ${_adapterState.value}");
    });
  }

  @override
  Stream<double> getWeight() async* {
    BluetoothDevice? device;
    try {
      device = FlutterBluePlus.connectedDevices
          .firstWhere((d) => d.remoteId.str == _connectedDevice.value!.id);
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
      var service = services
          .firstWhere((s) => s.uuid == BleConstants.WEIGHT_SERVICE_UUID);
      weightChar = service.characteristics
          .firstWhere((c) => c.uuid == BleConstants.WEIGHT_CHAR_UUID);
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

        double weight = _parseWeightData(data);
        _log.i("data : $weight -- $data");
        yield weight;
      }
    } catch (e) {
      _log.e("구독 또는 데이터 수신 중 오류: $e");
      yield 0.0; // 에러 발생 시 0.0을 스트림에 보냄
    }
  }

  double? _lastWeight; // 마지막 무게 값 저장 (비정상 변화 탐지용)

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
      final weight = byteData.getFloat32(0, Endian.little);

      // 4. 값 검증
      // NaN 또는 Infinity 검사
      if (weight.isNaN || weight.isInfinite) {
        _log.e("유효하지 않은 무게 값: NaN 또는 Infinity");
        return 0.0;
      }

      // 음수 검사
      if (weight < BleConstants.MIN_WEIGHT_GRAM) {
        _log.e("유효하지 않은 무게 값: 음수 ($weight g)");
        return 0.0;
      }

      // 합리적인 범위 검증
      if (weight > BleConstants.MAX_WEIGHT_GRAM) {
        _log.e(
            "무게가 최대값을 초과함: $weight g (최대: ${BleConstants.MAX_WEIGHT_GRAM}g)");
        return 0.0;
      }

      _lastWeight = weight;
      return weight;
    } catch (e) {
      _log.e("ByteData 파싱 중 오류 발생: $e, Data: $data");
      return 0.0;
    }
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
  Future connectToDevice(String deviceId) async {
    ScanResult? result = findScanResultById(deviceId);

    if (result == null) {
      _log.e("connectToDevice: 장치를 찾을 수 없습니다. ID: $deviceId");
      throw Exception("장치를 찾을 수 없습니다.");
    }

    final device = result.device;

    try {
      // 1. 이미 연결된 장치가 있다면 먼저 연결 해제
      final connectedDevices = FlutterBluePlus.connectedDevices;
      for (var connectedDev in connectedDevices) {
        _log.i(
            "Disconnecting previously connected device: ${connectedDev.remoteId}");
        await connectedDev.disconnect();
      }

      // 2. 약간의 딜레이 추가 (BLE 스택 안정화)
      await Future.delayed(const Duration(milliseconds: 500));

      // 3. 새 장치에 연결 시도 (timeout 15초)
      _log.i("Attempting to connect to device: $deviceId");
      await device.connect(
        license: License.free,
        timeout: const Duration(seconds: 15),
      );

      // 4. 연결 성공
      _connectedDevice.value = scanResultToDevice(result);
      _log.i(
          "Successfully connected to device: ${_connectedDevice.value!.name} (${_connectedDevice.value!.id})");

      // 5. 연결 상태 모니터링 시작
      _startMonitoringConnectionState(device);
    } catch (e) {
      // 연결 실패
      _connectedDevice.value = null;
      _log.e("Failed to connect to device $deviceId: $e");
      rethrow;
    }
  }

  /// 디바이스 연결 상태를 모니터링하고 연결이 끊어지면 다이얼로그를 표시
  void _startMonitoringConnectionState(BluetoothDevice device) {
    // 기존 구독이 있다면 취소
    _connectionStateSubscription?.cancel();

    _connectionStateSubscription = device.connectionState.listen((state) {
      _log.i("Connection state changed: $state");

      if (state == BluetoothConnectionState.disconnected) {
        _log.w("Device disconnected. Showing dialog...");

        // 연결된 디바이스 정보 초기화
        _connectedDevice.value = null;

        // 연결 끊김 다이얼로그 표시
        _showDisconnectionDialog();
      }
    });
  }

  /// 연결 끊김 다이얼로그를 표시하고 확인 버튼을 누르면 첫 페이지로 이동
  void _showDisconnectionDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('디바이스 연결 끊김'),
        content: const Text('디바이스와의 연결이 끊어졌습니다.'),
        actions: [
          TextButton(
            onPressed: () {
              // 다이얼로그 닫기
              Get.back();
              // 첫 페이지로 라우팅 (모든 이전 페이지 제거)
              Get.offAllNamed(Routes.LOGO);
            },
            child: const Text('확인'),
          ),
        ],
      ),
      barrierDismissible: false, // 바깥 영역 터치로 닫히지 않도록 설정
    );
  }

  @override
  void onClose() {
    // 연결 상태 구독 취소
    _connectionStateSubscription?.cancel();
    super.onClose();
  }

  StreamSubscription _scanForDevices() {
    return FlutterBluePlus.onScanResults.listen((results) {
      scannedDevices.clear();
      _rxScannedResults.clear();
      for (var r in results) {
        if (r.device.advName.contains(BleConstants.SCALE_DEVICE_PREFIX) ==
            false) {
          continue;
        }
        _rxScannedResults.add(r);
      }
      scannedDevices(
        _rxScannedResults.map((r) => scanResultToDevice(r)).toList(),
      );
      _log.i("Scanned Devices: ${scannedDevices.length}");
    });
  }

  Device scanResultToDevice(dynamic result) {
    return Device(
      id: result.device.remoteId.str,
      name: result.advertisementData.advName,
      type: result.device.advName.contains(BleConstants.SCALE_DEVICE_PREFIX)
          ? DeviceType.SCALE
          : DeviceType.OTHER,
    );
  }

  @override
  void startScanWithDuration({Duration duration = const Duration(seconds: 5)}) {
    _log.i("Starting scan for ${duration.inSeconds} seconds");
    isScanning(true);
    FlutterBluePlus.startScan();
    StreamSubscription scanSub = _scanForDevices();

    Future.delayed(duration).then((_) {
      scanSub.cancel();
      FlutterBluePlus.stopScan();
      isScanning(false);
      _log.i("Scan stopped after ${duration.inSeconds} seconds");
    });
  }

  ScanResult? findScanResultById(String deviceId) {
    try {
      var result = _rxScannedResults
          .firstWhere((r) => r.device.remoteId.str == deviceId);
      return result;
    } catch (e) {
      return null;
    }
  }
}
