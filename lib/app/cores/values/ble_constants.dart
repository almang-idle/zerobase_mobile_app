import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// BLE(Bluetooth Low Energy) 관련 상수 정의
///
/// 이 파일에는 ZEROBASE 저울 디바이스와 통신하기 위한
/// BLE 서비스 및 특성 UUID가 정의되어 있습니다.
class BleConstants {
  /// ZEROBASE 저울 디바이스 이름 접두사
  ///
  /// 디바이스 스캔 시 이 접두사를 포함하는 디바이스만 필터링합니다.
  static const String SCALE_DEVICE_PREFIX = "ZEROBASE-SCALE";

  /// 무게 측정 서비스 UUID
  ///
  /// ZEROBASE 저울의 무게 측정 기능을 제공하는 BLE 서비스의 UUID입니다.
  /// 이 UUID는 ZEROBASE 저울 펌웨어에서 정의된 고유한 서비스 식별자입니다.
  static final Guid WEIGHT_SERVICE_UUID =
      Guid("a5fbf7b2-696d-45c9-8f59-4f3592a23b49");

  /// 무게 데이터 특성 UUID
  ///
  /// 실시간 무게 데이터를 수신하기 위한 BLE Characteristic의 UUID입니다.
  /// 이 특성을 구독(notify)하면 저울에서 측정된 무게 값을 실시간으로 받을 수 있습니다.
  ///
  /// 데이터 형식: 4바이트 Little-Endian float (단위: 그램)
  static final Guid WEIGHT_CHAR_UUID =
      Guid("6e170b83-7095-4a4c-b01b-ab15e2355ddd");

  /// 무게 측정 범위 (그램)
  static const double MIN_WEIGHT_GRAM = 0.0;
  static const double MAX_WEIGHT_GRAM = 50000.0; // 50kg

  /// 무게 변화 임계값 (그램)
  ///
  /// 이 값 이상의 급격한 무게 변화가 감지되면 경고 로그를 출력합니다.
  /// 정상적인 사용 패턴에서 벗어난 비정상적인 변화를 탐지하기 위한 값입니다.
  static const double SUSPICIOUS_WEIGHT_CHANGE_THRESHOLD = 10000.0; // 10kg

  // private 생성자 - 인스턴스화 방지
  BleConstants._();
}
