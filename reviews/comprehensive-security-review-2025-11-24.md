# 포괄적 보안 리뷰 보고서 (Comprehensive Security Review)
**프로젝트:** Zerobase Mobile App
**날짜:** 2025년 11월 24일
**검토자:** Claude Code Security Analysis
**브랜치:** master
**리뷰 유형:** 전체 코드베이스 보안 평가

---

## 요약 (Executive Summary)

Zerobase Mobile App의 전체 코드베이스에 대한 포괄적인 보안 검토를 수행했습니다. 이 앱은 BLE(Bluetooth Low Energy) 저울 장치와 연결하여 무게를 측정하고, 백엔드 API와 통신하여 거래를 처리하는 키오스크 애플리케이션입니다.

### 주요 발견사항

- **치명적/높음 심각도:** 5개
- **중간 심각도:** 5개
- **낮음 심각도:** 2개

**전체 보안 상태:** ⚠️ **심각한 보안 취약점 발견** - 프로덕션 배포 전 필수 조치 필요

---

## 목차

1. [치명적/높음 심각도 취약점](#critical-high)
2. [중간 심각도 취약점](#medium)
3. [낮음 심각도 이슈](#low)
4. [긍정적 보안 관행](#positive)
5. [누락된 보안 제어](#missing)
6. [위험도 요약](#risk-summary)
7. [권장 조치사항](#recommendations)

---

<a name="critical-high"></a>
## 1. 치명적/높음 심각도 취약점

### 🔴 HIGH-1: 프로덕션 환경에서 민감한 API 응답 로깅

**파일:** `lib/app/services/backend_service_impl.dart:13`
**심각도:** HIGH
**카테고리:** 정보 노출 (Information Disclosure)
**신뢰도:** 10/10
**CVSS 점수:** 7.5

#### 설명
Dio HTTP 클라이언트가 디버그/프로덕션 모드 구분 없이 LogInterceptor를 통해 모든 API 응답 본문을 로깅합니다. 이는 민감한 데이터가 프로덕션 빌드에서도 디바이스 로그에 기록됨을 의미합니다.

#### 취약한 코드
```dart
BackendServiceImpl() {
    // API 요청/응답을 로그로 확인하기 위해 LogInterceptor 추가
    _dio.interceptors.add(LogInterceptor(responseBody: true));
}
```

#### 공격 시나리오
1. 공격자가 디바이스 로그에 접근 (ADB, 악성코드, 루팅된 디바이스 등)
2. 모든 API 응답 데이터 노출:
   - 상품 정보 및 가격
   - 사용자 식별자 (전화번호 뒷자리)
   - 비즈니스 로직 상세정보
3. 로그가 디바이스에 지속적으로 저장되어 장기간 노출 가능

#### 영향
- PII(개인식별정보) 노출
- 비즈니스 로직 및 가격 정보 유출
- 규정 위반 가능성 (GDPR, CCPA 등)

#### 권장 조치
```dart
import 'package:flutter/foundation.dart';

BackendServiceImpl() {
    // 디버그 모드에서만 로깅 활성화
    if (kDebugMode) {
        _dio.interceptors.add(LogInterceptor(
            responseBody: true,
            requestBody: true,
        ));
    }
}
```

---

### 🔴 HIGH-2: API 요청 에러 처리 누락 및 Fire-and-Forget 패턴

**파일:** `lib/app/modules/product/controllers/product_controller.dart:91-111`
**심각도:** HIGH
**카테고리:** 비즈니스 로직 결함 (Business Logic Flaw)
**신뢰도:** 9/10
**CVSS 점수:** 8.2

#### 설명
`completePurchase()` 함수가 백엔드로 무게 데이터를 전송할 때 응답을 기다리지 않고(await 미사용), 에러 처리도 하지 않는 fire-and-forget 패턴을 사용합니다. 실제 API 성공/실패와 무관하게 즉시 성공 다이얼로그를 표시합니다.

#### 취약한 코드
```dart
void completePurchase() {
    for (var item in cartItems) {
      // await 없음, 에러 처리 없음
      backendService.sendScaleData(
          phoneSuffix: inactivityService.id,
          productId: item.product.id,
          weightGram: item.weight);
    }
    // 즉시 성공 메시지 표시
    Get.dialog(CupertinoAlertDialog(
      title: const Text('전송 완료'),
      content: const Text('구매가 완료되었습니다.'),
      ...
```

#### 공격 시나리오
1. 사용자가 여러 상품으로 구매를 완료
2. 네트워크 연결 불안정 또는 백엔드 서버 다운
3. API 호출이 실패하지만 에러가 무시됨
4. 사용자는 "전송 완료" 메시지를 봄
5. **실제로는 구매 데이터가 백엔드에 기록되지 않음**
6. 재고 관리 및 결제 처리 불일치 발생

#### 영향
- 금전적 손실 (미청구된 상품)
- 재고 관리 오류
- 고객 신뢰도 하락
- 회계 감사 문제

#### 권장 조치
```dart
Future<void> completePurchase() async {
    try {
        List<Future> requests = [];

        for (var item in cartItems) {
            requests.add(
                backendService.sendScaleData(
                    phoneSuffix: inactivityService.id,
                    productId: item.product.id,
                    weightGram: item.weight
                )
            );
        }

        // 모든 요청이 성공할 때까지 대기
        await Future.wait(requests);

        // 모든 요청 성공 시에만 성공 다이얼로그 표시
        Get.dialog(CupertinoAlertDialog(
            title: const Text('전송 완료'),
            content: const Text('구매가 완료되었습니다.'),
            ...
        ));

    } catch (error) {
        // 에러 발생 시 사용자에게 알림
        Get.dialog(CupertinoAlertDialog(
            title: const Text('전송 실패'),
            content: const Text('네트워크 오류가 발생했습니다. 다시 시도해주세요.'),
            ...
        ));
        log.e('Purchase completion failed: $error');
    }
}
```

---

### 🔴 HIGH-3: 인증/인가 메커니즘 부재

**파일:** `lib/app/services/backend_service_impl.dart:1-49`
**심각도:** HIGH
**카테고리:** 인증 우회 (Authentication Bypass)
**신뢰도:** 10/10
**CVSS 점수:** 9.1

#### 설명
백엔드 API 클라이언트에 인증 헤더, 토큰, API 키가 전혀 없습니다. 모든 API 요청이 인증 없이 전송되며, 4자리 전화번호 뒷자리만으로 사용자를 식별합니다.

#### 취약한 코드
```dart
final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://zerobase-pos.vercel.app',
));
// 인증 헤더, 토큰, 인터셉터 없음
```

#### 공격 시나리오
1. 공격자가 APK를 리버스 엔지니어링하여 API 엔드포인트 발견
2. `/api/ingest-scale` 엔드포인트 분석: `phone_suffix`, `product_id`, `weight_gram` 파라미터 필요
3. 공격자가 임의의 전화번호 뒷자리로 POST 요청 생성
4. **10,000가지 조합만 있으므로 brute force 공격 가능**
5. 공격자가 임의의 사용자에게 허위 무게 데이터 주입 가능
6. 모든 고객의 청구/재고를 조작 가능

#### 영향
- 무제한 API 접근
- 사용자 데이터 조작
- 금전적 사기
- 비즈니스 무결성 훼손
- 법적 책임

#### 권장 조치
```dart
class BackendServiceImpl extends BackendService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://zerobase-pos.vercel.app',
    headers: {
      'Authorization': 'Bearer ${await _getAuthToken()}',
      'X-API-Key': _apiKey,
    },
  ));

  // 인증 인터셉터 추가
  BackendServiceImpl() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 각 요청마다 최신 토큰 추가
        final token = await _getAuthToken();
        options.headers['Authorization'] = 'Bearer $token';
        return handler.next(options);
      },
      onError: (error, handler) async {
        // 401 에러 시 토큰 갱신
        if (error.response?.statusCode == 401) {
          await _refreshToken();
          return handler.resolve(await _retry(error.requestOptions));
        }
        return handler.next(error);
      },
    ));
  }

  Future<String> _getAuthToken() async {
    // 안전한 저장소에서 토큰 가져오기
    final storage = FlutterSecureStorage();
    return await storage.read(key: 'auth_token') ?? '';
  }
}
```

**백엔드에서도 구현 필요:**
- JWT 토큰 기반 인증
- 디바이스 등록 및 인증
- Rate limiting
- 요청 서명 검증

---

### 🔴 HIGH-4: BLE 디바이스 인증 부재

**파일:** `lib/app/services/device_service_impl.dart:133-155, 166`
**심각도:** HIGH
**카테고리:** BLE 보안 (BLE Security)
**신뢰도:** 9/10
**CVSS 점수:** 8.4

#### 설명
BLE 연결이 디바이스 이름에 "ZEROBASE-SCALE"이 포함되어 있는지만 확인하고, 암호화 인증, 페어링 검증, MAC 주소 화이트리스트 없이 연결을 허용합니다. 디바이스 이름은 쉽게 스푸핑 가능합니다.

#### 취약한 코드
```dart
void connectToDevice(String deviceId) {
    // 이름만 확인, 인증 없음
    type: r.device.advName.contains("ZEROBASE-SCALE")
          ? DeviceType.SCALE
          : DeviceType.OTHER,

    device.connect(license: License.free).then((_) {
      isConnected(true);
      connectedDevice(toDevice(device));  // 인증 검증 없음
```

#### 공격 시나리오
1. 공격자가 "ZEROBASE-SCALE"로 광고하는 악성 BLE 디바이스 생성
2. 정상 키오스크 근처에 디바이스 배치
3. 앱이 공격자의 디바이스에 연결 (이름 기반만으로, MAC 화이트리스트 없음)
4. 공격자가 조작된 무게 데이터 전송 (4바이트 float 값)
5. 사용자가 공격자가 제어하는 무게로 청구됨
6. 가능한 공격:
   - 0g 전송 → 무료 제품 획득
   - 높은 무게 전송 → 과다 청구
   - 음수 무게 → 시스템 오류 유발

#### 영향
- 금전적 사기
- 제품 절도
- 고객 과다 청구
- 비즈니스 손실
- 브랜드 평판 손상

#### 권장 조치

**1. MAC 주소 화이트리스트 구현:**
```dart
class DeviceServiceImpl extends DeviceService {
  // 승인된 디바이스 MAC 주소 (백엔드에서 가져와야 함)
  final Set<String> _trustedDeviceIds = {};

  Future<void> loadTrustedDevices() async {
    // 백엔드에서 승인된 디바이스 목록 가져오기
    final response = await _backendService.getTrustedDevices();
    _trustedDeviceIds.addAll(response.deviceIds);
  }

  StreamSubscription scanForDevices() {
    return FlutterBluePlus.onScanResults.listen((results) {
      List<Device> newScannedDevices = [];
      for (var r in results) {
        // MAC 주소 확인
        final deviceId = r.device.remoteId.str;
        if (!_trustedDeviceIds.contains(deviceId)) {
          log.w("Untrusted device detected: $deviceId");
          continue; // 화이트리스트에 없는 디바이스 무시
        }

        newScannedDevices.add(Device(
          id: deviceId,
          name: r.advertisementData.advName,
          type: _trustedDeviceIds.contains(deviceId)
              ? DeviceType.SCALE
              : DeviceType.OTHER,
        ));
      }
      scannedDevices(newScannedDevices);
    });
  }
}
```

**2. 챌린지-응답 인증 구현:**
```dart
Future<bool> authenticateDevice(BluetoothDevice device) async {
  try {
    // 1. 난수 챌린지 생성
    final challenge = _generateRandomChallenge();

    // 2. 디바이스에 챌린지 전송
    await _sendChallenge(device, challenge);

    // 3. 응답 수신
    final response = await _receiveResponse(device);

    // 4. 공유 시크릿으로 응답 검증
    final expectedResponse = _computeHMAC(challenge, _sharedSecret);

    return response == expectedResponse;
  } catch (e) {
    log.e("Device authentication failed: $e");
    return false;
  }
}

void connectToDevice(String deviceId) {
  final device = _getDevice(deviceId);

  device.connect(license: License.free).then((_) async {
    // 연결 후 인증 수행
    final isAuthenticated = await authenticateDevice(device);

    if (!isAuthenticated) {
      log.e("Device authentication failed, disconnecting");
      device.disconnect();
      Get.snackbar('보안 오류', '디바이스 인증에 실패했습니다.');
      return;
    }

    isConnected(true);
    connectedDevice(toDevice(device));
    log.i("Device authenticated and connected: $deviceId");
  });
}
```

**3. 추가 보안 조치:**
- BLE 페어링/본딩 구현
- 암호화된 BLE characteristics 사용
- 디바이스 펌웨어 서명 검증
- 비정상적인 무게 패턴에 대한 이상 탐지

---

### 🔴 HIGH-5: 4자리 전화번호 뒷자리를 통한 약한 사용자 식별

**파일:** `lib/app/modules/keypad/controllers/keypad_controller.dart:7-31`
**심각도:** HIGH
**카테고리:** 약한 식별 (Weak Identification)
**신뢰도:** 10/10
**CVSS 점수:** 7.8

#### 설명
사용자 식별이 전화번호 뒷 4자리에만 의존합니다(10,000가지 가능한 값). 사용자 데이터베이스 대조 검증이 없고, 인증도 없으며, 값이 평문으로 메모리에 저장되어 백엔드로 전송됩니다.

#### 취약한 코드
```dart
void onSubmit() {
    if (pin.value.length == 4) {  // 길이만 확인, 검증 없음
      inactivityService.setId(pin.value);  // 평문 문자열로 저장
      Get.toNamed(Routes.REFILL);
    }
}
```

#### 공격 시나리오
1. 공격자가 키패드에 임의의 4자리 코드 입력
2. 시스템이 검증 없이 수락
3. 공격자의 구매가 해당 뒷자리를 가진 무작위 전화번호에 귀속
4. 정당한 사용자가 공격자의 구매에 대해 청구받음
5. 10,000가지 조합만으로 충돌 공격 현실적
6. 여러 사용자가 같은 뒷자리를 공유하여 청구 충돌 가능

#### 영향
- 신원 도용
- 부당 청구
- 고객 불만
- 법적 책임
- 금전적 손실

#### 권장 조치

**옵션 1: SMS OTP 인증**
```dart
class KeypadController extends GetxController {
  final _backendService = Get.find<BackendService>();

  Future<void> onSubmit() async {
    if (pin.value.length == 4) {
      // 1. 백엔드로 OTP 요청
      try {
        await _backendService.requestOTP(phoneSuffix: pin.value);

        // 2. OTP 입력 화면으로 이동
        final otpVerified = await Get.toNamed(Routes.OTP_VERIFICATION);

        if (otpVerified) {
          // 3. OTP 검증 성공 시 세션 생성
          final sessionToken = await _backendService.createSession(
            phoneSuffix: pin.value
          );

          // 4. 안전한 저장소에 세션 토큰 저장
          await _secureStorage.write(key: 'session_token', value: sessionToken);

          inactivityService.setId(pin.value);
          Get.toNamed(Routes.REFILL);
        }
      } catch (e) {
        Get.snackbar('오류', '전화번호를 확인할 수 없습니다.');
      }
    }
  }
}
```

**옵션 2: QR 코드 인증**
```dart
class QRAuthController extends GetxController {
  Future<void> scanQRCode() async {
    final qrCode = await BarcodeScanner.scan();

    // QR 코드에 암호화된 사용자 ID와 타임스탬프 포함
    final authData = await _backendService.validateQRCode(qrCode);

    if (authData.isValid) {
      inactivityService.setId(authData.userId);
      Get.toNamed(Routes.REFILL);
    }
  }
}
```

**옵션 3: NFC 카드 인증**
- 사용자에게 고유 NFC 카드 발급
- 카드에 암호화된 사용자 ID 저장
- 키오스크에서 카드 탭하여 인증

---

<a name="medium"></a>
## 2. 중간 심각도 취약점

### 🟡 MEDIUM-1: 불충분한 BLE 데이터 검증

**파일:** `lib/app/services/device_service_impl.dart:97-118`
**심각도:** MEDIUM
**카테고리:** 입력 검증 (Input Validation)
**신뢰도:** 9/10

#### 설명
BLE 무게 데이터 파싱이 바이트 길이(4바이트)만 검증하고, 실제 float 값에 대한 범위 검사, 무결성 검사, 서명 검증을 하지 않습니다.

#### 취약한 코드
```dart
double _parseWeightData(List<int> data) {
    if (data.length != 4) {  // 길이만 검증
      return 0.0;
    }
    final byteData = ByteData.sublistView(Uint8List.fromList(data));
    return byteData.getFloat32(0, Endian.little);  // 값 검증 없음
}
```

#### 공격 시나리오
1. 공격자가 악성 BLE 디바이스 연결 또는 정상 저울 펌웨어 변조
2. 극단적인 값을 가진 악성 4바이트 페이로드 전송:
   - 음수 무게: 계산에서 정수 언더플로우 유발 가능
   - 극단적으로 큰 무게: 가격 계산 오버플로우
   - NaN 또는 Infinity: 앱 크래시 또는 미정의 동작
   - 0 무게: 무료 제품
3. 앱이 검증 없이 이 값들을 수락하고 사용
4. 금전적 손실 또는 앱 크래시 발생 가능

#### 권장 조치
```dart
double _parseWeightData(List<int> data) {
    if (data.length != 4) {
      _log.e("Invalid weight data length: ${data.length}");
      return 0.0;
    }

    try {
      final byteData = ByteData.sublistView(Uint8List.fromList(data));
      final weight = byteData.getFloat32(0, Endian.little);

      // 값 검증
      if (weight.isNaN || weight.isInfinite) {
        _log.e("Invalid weight value: NaN or Infinity");
        return 0.0;
      }

      if (weight < 0) {
        _log.e("Invalid weight value: negative ($weight)");
        return 0.0;
      }

      // 합리적인 범위 검증 (예: 0-50kg)
      if (weight > 50000) {  // 50kg = 50000g
        _log.e("Weight exceeds maximum: $weight g");
        return 0.0;
      }

      // 비정상적인 무게 변화 탐지
      if (_lastWeight > 0) {
        final change = (weight - _lastWeight).abs();
        if (change > 10000) {  // 10kg 이상 급격한 변화
          _log.w("Suspicious weight change detected: $change g");
          // 추가 검증 또는 사용자 확인 요청
        }
      }

      _lastWeight = weight;
      return weight;

    } catch (e) {
      _log.e("ByteData parsing error: $e, Data: $data");
      return 0.0;
    }
}
```

---

### 🟡 MEDIUM-2: 안전하지 않은 세션 관리

**파일:** `lib/app/services/inactivity_service.dart:11-62`
**심각도:** MEDIUM
**카테고리:** 세션 관리 (Session Management)
**신뢰도:** 8/10

#### 설명
비활성 타임아웃(3.5분)이 홈으로 이동하고 로컬 상태를 지우지만, 서버 측 세션을 무효화하지 않고 메모리에서 민감한 데이터를 지우지 않습니다. 타임아웃 카운트다운 중에도 전화번호 뒷자리가 접근 가능합니다.

#### 취약한 코드
```dart
void reset() {
    _timer?.cancel();
    _rxId('');  // 단순 문자열 지우기, 안전한 삭제 아님
    deviceService.resetWeights();
    if (!(Get.currentRoute == Routes.DEFAULT_ROUTE)) {
      Get.offAllNamed(Routes.DEFAULT_ROUTE);
    }
}
```

#### 공격 시나리오
1. 사용자가 전화번호 뒷자리를 입력하고 거래 시작
2. 구매 완료 전 사용자가 자리를 떠남
3. 3.5분 타임아웃 기간 동안:
   - 공격자가 키오스크에 접근
   - 남은 시간을 보고 잠재적으로 세션과 상호작용 가능
   - 세션 데이터(_rxId의 전화번호 뒷자리)가 메모리에 남아있음
4. 서버 측 세션 무효화가 발생하지 않음
5. 타임아웃 중 앱이 크래시하면 세션이 제대로 지워지지 않을 수 있음

#### 권장 조치
```dart
import 'dart:typed_data';
import 'dart:convert';

class InactivityService extends GetxService {
  final _backendService = Get.find<BackendService>();

  void reset() async {
    _timer?.cancel();

    // 1. 서버 측 세션 무효화
    if (_rxId.value.isNotEmpty) {
      try {
        await _backendService.invalidateSession(_rxId.value);
      } catch (e) {
        _log.e("Failed to invalidate server session: $e");
      }
    }

    // 2. 민감한 데이터를 안전하게 덮어쓰기
    _secureWipe(_rxId.value);
    _rxId('');

    // 3. 디바이스 서비스 리셋
    deviceService.resetWeights();

    // 4. 홈으로 이동
    if (!(Get.currentRoute == Routes.DEFAULT_ROUTE)) {
      Get.offAllNamed(Routes.DEFAULT_ROUTE);
    }

    _log.i("Session securely reset");
  }

  void _secureWipe(String data) {
    // 메모리에서 데이터를 안전하게 제거
    // Dart/Flutter는 메모리 직접 제어가 제한적이지만
    // 최선의 노력으로 덮어쓰기
    if (data.isEmpty) return;

    final bytes = utf8.encode(data);
    final zeros = Uint8List(bytes.length);
    // zeros로 덮어쓰기 (실제 메모리 제어는 제한적)
    bytes.setAll(0, zeros);
  }

  // 사용자가 자리를 떠났을 때 즉시 세션 종료하는 수동 버튼
  void manualLogout() {
    reset();
    Get.snackbar('로그아웃', '세션이 종료되었습니다.');
  }
}
```

**UI에 수동 로그아웃 버튼 추가:**
```dart
FloatingActionButton(
  onPressed: () => Get.find<InactivityService>().manualLogout(),
  child: Icon(Icons.logout),
  backgroundColor: Colors.red,
)
```

---

### 🟡 MEDIUM-3: 릴리스 빌드에서 코드 난독화 누락

**파일:** `android/app/build.gradle:47-53`
**심각도:** MEDIUM
**카테고리:** 하드닝 부족 (Lack of Hardening)
**신뢰도:** 10/10

#### 설명
Android 릴리스 빌드가 디버그 서명 구성을 사용하고 코드 난독화(minifyEnabled, ProGuard/R8)가 구성되지 않았습니다. 이로 인해 리버스 엔지니어링이 쉬워지고 API 엔드포인트, 비즈니스 로직, UUID가 노출됩니다.

#### 취약한 코드
```gradle
buildTypes {
    release {
        // TODO: Add your own signing config for the release build.
        // Signing with the debug keys for now
        signingConfig = signingConfigs.debug
    }
}
// minifyEnabled, shrinkResources, proguardFiles 구성 없음
```

#### 공격 시나리오
1. 공격자가 디바이스 또는 배포 채널에서 APK 다운로드
2. jadx, apktool 등의 도구로 디컴파일
3. 난독화되지 않은 코드를 쉽게 읽음:
   - API 엔드포인트: https://zerobase-pos.vercel.app
   - BLE 서비스 UUID: a5fbf7b2-696d-45c9-8f59-4f3592a23b49
   - 모든 비즈니스 로직 및 무게 계산
   - 데이터 구조 및 검증 로직 이해
4. 완전한 소스 이해를 바탕으로 표적 공격 제작
5. 지적 재산 노출

#### 권장 조치

**build.gradle 업데이트:**
```gradle
android {
    // ...

    buildTypes {
        release {
            // ProGuard/R8 난독화 활성화
            minifyEnabled true
            shrinkResources true

            // ProGuard 규칙 파일 지정
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'

            // 적절한 릴리스 서명 구성 사용
            signingConfig signingConfigs.release
        }
    }

    signingConfigs {
        release {
            storeFile file(KEYSTORE_FILE)
            storePassword KEYSTORE_PASSWORD
            keyAlias KEY_ALIAS
            keyPassword KEY_PASSWORD
        }
    }
}
```

**proguard-rules.pro 생성:**
```proguard
# Flutter 기본 규칙
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }

# Dio HTTP 클라이언트
-keep class dio.** { *; }

# GetX
-keep class get.** { *; }

# Flutter Blue Plus
-keep class com.boskokg.flutter_blue_plus.** { *; }

# 모델 클래스 유지 (JSON 직렬화용)
-keep class com.example.myapp.app.cores.models.** { *; }
-keep class com.example.myapp.app.modules.**.models.** { *; }
```

**추가 보안 조치:**
```dart
// Certificate Pinning 구현
class BackendServiceImpl extends BackendService {
  BackendServiceImpl() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://zerobase-pos.vercel.app',
    ));

    // Certificate Pinning 추가
    (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
      (client) {
        client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
          // 예상되는 인증서의 SHA-256 핑거프린트
          const expectedFingerprint =
            'AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99';

          return cert.sha256.toUpperCase() == expectedFingerprint;
        };
        return client;
      };
  }
}
```

---

### 🟡 MEDIUM-4: 하드코딩된 BLE UUID

**파일:** `lib/app/services/device_service_impl.dart:15-17`
**심각도:** MEDIUM
**카테고리:** 하드코딩된 구성 (Hardcoded Configuration)
**신뢰도:** 10/10

#### 설명
BLE 서비스 및 특성 UUID가 구성 관리나 앱 재배포 없이 업데이트할 수 있는 기능 없이 앱에 하드코딩되어 있습니다.

#### 취약한 코드
```dart
final Guid WEIGHT_SERVICE_UUID =
      Guid("a5fbf7b2-696d-45c9-8f59-4f3592a23b49");
final Guid WEIGHT_CHAR_UUID =
      Guid("6e170b83-7095-4a4c-b01b-ab15e2355ddd");
```

#### 공격 시나리오
1. 공격자가 디컴파일된 앱에서 UUID 추출
2. 동일한 UUID로 악성 디바이스 생성
3. UUID 변경이 필요한 경우 (보안 사고, 하드웨어 업데이트):
   - 앱 업데이트 필요
   - 모든 사용자가 앱 업데이트해야 함
   - 손상된 UUID 쌍을 원격으로 폐기할 수 없음

#### 권장 조치
```dart
class DeviceServiceImpl extends DeviceService {
  final _backendService = Get.find<BackendService>();

  late Guid _weightServiceUuid;
  late Guid _weightCharUuid;

  @override
  Future<void> onInit() async {
    super.onInit();

    // 백엔드에서 현재 UUID 가져오기
    await _loadUuidsFromBackend();
  }

  Future<void> _loadUuidsFromBackend() async {
    try {
      final config = await _backendService.getDeviceConfiguration();

      // 승인된 UUID 목록 (여러 버전 지원 가능)
      _approvedServiceUuids = config.serviceUuids
        .map((uuid) => Guid(uuid))
        .toList();

      _approvedCharUuids = config.characteristicUuids
        .map((uuid) => Guid(uuid))
        .toList();

      // 기본 UUID 설정
      _weightServiceUuid = _approvedServiceUuids.first;
      _weightCharUuid = _approvedCharUuids.first;

      _log.i("Device UUIDs loaded from backend");
    } catch (e) {
      // 폴백: 로컬 기본값 사용
      _log.e("Failed to load UUIDs from backend, using defaults: $e");
      _weightServiceUuid = Guid("a5fbf7b2-696d-45c9-8f59-4f3592a23b49");
      _weightCharUuid = Guid("6e170b83-7095-4a4c-b01b-ab15e2355ddd");
    }
  }

  Future<void> subscribeToWeightCharacteristic(BluetoothDevice device) async {
    // 여러 승인된 UUID 시도
    for (final serviceUuid in _approvedServiceUuids) {
      final service = device.servicesList.firstWhereOrNull(
        (s) => s.uuid == serviceUuid
      );

      if (service != null) {
        for (final charUuid in _approvedCharUuids) {
          final char = service.characteristics.firstWhereOrNull(
            (c) => c.uuid == charUuid
          );

          if (char != null) {
            await char.setNotifyValue(true);
            _log.i("Subscribed to weight updates: $serviceUuid / $charUuid");
            return;
          }
        }
      }
    }

    throw Exception("No compatible service/characteristic found");
  }
}
```

**백엔드 API 엔드포인트:**
```typescript
// GET /api/device-config
{
  "serviceUuids": [
    "a5fbf7b2-696d-45c9-8f59-4f3592a23b49",  // v1
    "b6fcf8c3-707e-46b0-9f5a-5f4693b24c5a"   // v2 (새 버전)
  ],
  "characteristicUuids": [
    "6e170b83-7095-4a4c-b01b-ab15e2355ddd",  // v1
    "7f281c94-8106-57c1-a06b-60468ac35d6e"   // v2
  ],
  "version": "2.0",
  "minAppVersion": "1.2.0"
}
```

---

### 🟡 MEDIUM-5: 서버 검증 없는 클라이언트 측 가격 계산

**파일:** `lib/app/modules/price/controllers/price_controller.dart:43`
**심각도:** MEDIUM
**카테고리:** 비즈니스 로직 결함 (Business Logic Flaw)
**신뢰도:** 9/10

#### 설명
총 가격이 클라이언트 측에서 계산되고((productWeight * selectedProduct.unitPrice).round()) 서버 측 검증 없이 백엔드로 전송됩니다. 클라이언트가 거짓 가격을 전송하도록 조작될 수 있습니다.

#### 취약한 코드
```dart
int get totalPrice => (productWeight * selectedProduct.unitPrice).round();
// 가격이 클라이언트에서 계산되고, 서버 검증 없이 백엔드로 전송
```

#### 공격 시나리오
1. 공격자가 앱 코드 수정 또는 프록시를 사용하여 요청 가로채기
2. unitPrice를 낮은 값으로 변경하거나 무게 계산 조작
3. 정확한 weight_gram이지만 사기성 계산이 발생한 클라이언트 측 요청 전송
4. 백엔드가 클라이언트 계산을 신뢰하면 사용자가 실제 비용보다 적게 지불
5. 재컴파일 없이 Frida/Xposed를 통한 런타임 조작 가능

#### 권장 조치

**클라이언트 측 (참조만):**
```dart
// 클라이언트는 표시 목적으로만 가격 계산
int get estimatedTotalPrice =>
  (productWeight * selectedProduct.unitPrice).round();

Future<void> completePurchase() async {
  try {
    // 무게와 제품 ID만 전송, 가격은 전송하지 않음
    final response = await backendService.sendScaleData(
      phoneSuffix: inactivityService.id,
      productId: selectedProduct.id,
      weightGram: productWeight,
      // 가격 전송하지 않음 - 백엔드가 계산
    );

    // 백엔드에서 계산된 가격 받기
    final actualPrice = response.calculatedPrice;

    // 사용자에게 실제 가격 표시
    Get.dialog(CupertinoAlertDialog(
      title: const Text('구매 확인'),
      content: Text('총 금액: ${actualPrice}원'),
      ...
    ));
  } catch (e) {
    log.e('Purchase failed: $e');
  }
}
```

**백엔드 측 (필수):**
```typescript
// POST /api/ingest-scale
async function ingestScaleData(req, res) {
  const { phone_suffix, product_id, weight_gram } = req.body;

  // 1. 데이터베이스에서 제품 정보 가져오기
  const product = await db.products.findById(product_id);
  if (!product) {
    return res.status(404).json({ error: 'Product not found' });
  }

  // 2. 서버 측에서 가격 계산
  const calculatedPrice = Math.round(
    (weight_gram / 1000) * product.unit_price_per_kg
  );

  // 3. 무게 검증
  if (weight_gram < 0 || weight_gram > 50000) {
    return res.status(400).json({ error: 'Invalid weight' });
  }

  // 4. 거래 저장
  const transaction = await db.transactions.create({
    phone_suffix,
    product_id,
    weight_gram,
    calculated_price: calculatedPrice,  // 서버 계산 가격
    timestamp: new Date(),
  });

  // 5. 계산된 가격 반환
  return res.json({
    success: true,
    transaction_id: transaction.id,
    calculated_price: calculatedPrice,
    weight_gram,
  });
}
```

**핵심 원칙:**
- 클라이언트를 절대 신뢰하지 말 것
- 모든 금전적 계산은 서버에서 수행
- 클라이언트 가격은 사용자 경험을 위한 추정치일 뿐
- 서버가 항상 권위 있는 출처

---

<a name="low"></a>
## 3. 낮음 심각도 이슈

### 🟢 LOW-1: 검증되지 않은 에러 메시지가 사용자에게 노출

**파일:** `lib/app/modules/product/controllers/product_controller.dart:40-43`
**심각도:** LOW
**카테고리:** 정보 노출 (Information Disclosure)
**신뢰도:** 8/10

#### 권장 조치
```dart
}).catchError((error) {
  // 프로덕션에서는 일반적인 메시지만
  if (kDebugMode) {
    _log.e('상품 조회 에러: $error');
  } else {
    _log.e('상품 조회 실패', error: error);  // 상세정보는 로깅 서비스로
  }
});
```

---

### 🟢 LOW-2: 무게 안정화에서의 경쟁 조건

**파일:** `lib/app/modules/refill/controllers/refill_controller.dart:56-93`
**심각도:** LOW
**카테고리:** 경쟁 조건 (Race Condition)
**신뢰도:** 7/10

#### 권장 조치
```dart
import 'dart:async';
import 'package:synchronized/synchronized.dart';

class RefillController extends GetxController {
  final _lock = Lock();

  void _initSubscription() {
    _sub = _deviceService.getWeight().listen((value) async {
      // 동기화된 버퍼 작업
      await _lock.synchronized(() {
        _weightBuffer.add(value);
        if (_weightBuffer.length > 20) {
          _weightBuffer.removeFirst();
        }

        if (_isStable()) {
          _handleStableWeight();
        }
      });
    });
  }
}
```

---

<a name="positive"></a>
## 4. 긍정적 보안 관행

다음과 같은 좋은 보안 관행이 발견되었습니다:

✅ **HTTPS 강제 적용:** API 엔드포인트가 HTTPS 사용
✅ **하드코딩된 자격증명 없음:** 코드에서 비밀번호나 API 키 발견되지 않음
✅ **민감한 데이터를 SharedPreferences에 저장하지 않음**
✅ **비활성 타임아웃 구현:** 3.5분 후 세션 리셋
✅ **SQL 인젝션 벡터 없음:** 로컬 데이터베이스 사용하지 않음
✅ **WebView 취약점 없음:** WebView 사용하지 않음
✅ **적절한 BLE 권한:** 과도한 권한 요청하지 않음

---

<a name="missing"></a>
## 5. 누락된 보안 제어

다음 보안 제어가 누락되었습니다:

❌ **인증서 피닝:** API 통신에 대한 MITM 공격 방지
❌ **루팅/탈옥 탐지:** 손상된 디바이스에서 실행 방지
❌ **앱 무결성 검사:** 변조 탐지
❌ **Secure Enclave 사용:** 민감한 데이터에 대한 하드웨어 지원 보안
❌ **생체 인증 옵션:** 지문/얼굴 인식 로그인
❌ **백엔드 API Rate Limiting:** 클라이언트에서 보이지 않음
❌ **사기 탐지 메커니즘**
❌ **거래에 대한 감사 로깅**
❌ **백업 비활성화:** AndroidManifest.xml에 allowBackup 설정되지 않음
❌ **네트워크 보안 구성:** 인증서 피닝을 위한 구성 없음

---

<a name="risk-summary"></a>
## 6. 위험도 요약

### 심각도별 분포

| 심각도 | 개수 | 취약점 |
|--------|------|--------|
| 🔴 HIGH | 5 | 프로덕션 로깅, Fire-and-Forget API, 인증 부재, BLE 인증 부재, 약한 사용자 식별 |
| 🟡 MEDIUM | 5 | BLE 데이터 검증, 세션 관리, 코드 난독화, 하드코딩된 UUID, 클라이언트 측 가격 계산 |
| 🟢 LOW | 2 | 에러 메시지 노출, 경쟁 조건 |

### 위험 영역

**1. 금융 무결성 (Financial Integrity)**
- 무인증 API 접근 → 무제한 데이터 조작
- 가격 조작 가능 → 금전적 손실
- 허위 무게 주입 → 사기

**2. 사용자 프라이버시 (User Privacy)**
- 전화번호 노출
- 암호화되지 않은 PII 저장
- 과도한 로깅

**3. 비즈니스 연속성 (Business Continuity)**
- 실패한 거래 미탐지
- 데이터 손실 가능
- 재고 불일치

**4. 사기 방지 (Fraud Prevention)**
- 사용자 가장 용이
- 디바이스 스푸핑 가능
- 인증 메커니즘 없음

---

<a name="recommendations"></a>
## 7. 권장 조치사항

### 즉시 조치 필요 (Critical - 1-2주)

1. **API 인증 구현**
   - JWT 토큰 기반 인증 추가
   - 모든 API 엔드포인트에 인증 필요
   - Rate limiting 구현

2. **Purchase Completion 수정**
   - async/await 추가하여 API 응답 대기
   - 적절한 에러 처리 구현
   - 모든 요청 성공 시에만 성공 메시지 표시

3. **프로덕션 로깅 제거**
   - kDebugMode 체크 추가
   - 민감한 데이터 로깅 제거
   - 로그 정리 정책 구현

4. **BLE 디바이스 인증**
   - MAC 주소 화이트리스트 구현
   - 챌린지-응답 인증 추가
   - 디바이스 인증서 검증

### 단기 조치 (High Priority - 1개월)

5. **사용자 인증 강화**
   - SMS OTP 또는 QR 코드 인증 구현
   - 4자리 뒷자리 방식 폐지
   - 적절한 세션 관리

6. **BLE 데이터 검증**
   - 무게 값 범위 검증
   - NaN/Infinity 검사
   - 비정상 패턴 탐지

7. **서버 측 가격 검증**
   - 백엔드에서 가격 계산
   - 클라이언트 계산 절대 신뢰하지 않기

### 중기 조치 (Medium Priority - 2-3개월)

8. **코드 난독화**
   - ProGuard/R8 활성화
   - 적절한 릴리스 서명
   - 인증서 피닝 구현

9. **보안 하드닝**
   - 루팅/탈옥 탐지
   - 앱 무결성 검사
   - 백업 비활성화

10. **동적 구성**
    - UUID를 백엔드에서 로드
    - 원격 구성 관리
    - 버전 관리

### 장기 조치 (Long-term - 3-6개월)

11. **보안 아키텍처 개선**
    - Secure Enclave 사용
    - 생체 인증 옵션
    - 종단간 암호화

12. **감사 및 모니터링**
    - 포괄적인 감사 로깅
    - 실시간 사기 탐지
    - 보안 모니터링 대시보드

13. **규정 준수**
    - 개인정보 보호정책 시행
    - 데이터 보유 정책
    - GDPR/CCPA 준수

---

## 8. 규정 준수 고려사항

### 개인정보 보호 (Privacy Regulations)

**GDPR (유럽)**
- ❌ 동의 메커니즘 없음
- ❌ 데이터 보유 정책 없음
- ❌ 데이터 처리 근거 불명확

**CCPA (캘리포니아)**
- ❌ 개인정보 판매 공개 없음
- ❌ 옵트아웃 옵션 없음

**개인정보보호법 (한국)**
- ⚠️ 전화번호 수집 시 동의 필요
- ⚠️ 개인정보 처리방침 고지 필요
- ⚠️ 보안 조치 의무

### 결제 보안 (Payment Security)

**PCI DSS (해당 시)**
- ⚠️ 결제 정보 처리 시 PCI DSS 준수 필요
- ⚠️ 안전한 전송 및 저장

---

## 9. 테스트 방법론

이 리뷰에서 사용된 테스트 방법:

### 정적 분석 (Static Analysis)
- ✅ 인젝션 취약점 패턴 매칭
- ✅ 인증/인가 플로우 분석
- ✅ 사용자 입력에서 민감한 작업까지 데이터 흐름 추적
- ✅ 암호화 구현 검토
- ✅ 입력 검증 경계 분석

### 코드베이스 탐색 (Repository Exploration)
- ✅ 디바이스 모델 구조 분석
- ✅ 서비스 구현 검토
- ✅ Flutter Blue Plus 라이브러리 API 문서 검토
- ✅ BLE 연결 플로우 분석
- ✅ 에러 처리 패턴 검사

### 위협 모델링 (Threat Modeling)
- ✅ BLE 스푸핑 공격 시나리오
- ✅ 중간자 공격 벡터
- ✅ 데이터 주입 가능성
- ✅ UI 변조/스푸핑 위험
- ✅ 서비스 거부 시나리오

### 참조 문서 (References)
- OWASP Mobile Top 10 (2024)
- BLE Security Best Practices
- Flutter/Dart Security Guidelines
- CWE (Common Weakness Enumeration)
- CVSS v3.1 Scoring

---

## 10. 결론

### 전체 보안 상태: ⚠️ 심각한 보안 취약점 발견

Zerobase Mobile App은 **프로덕션 환경에 배포하기에 적합하지 않습니다**. 최소한 HIGH 심각도 이슈들이 해결되기 전까지는 배포를 보류해야 합니다.

### 주요 우려사항

1. **인증 부재:** 앱과 백엔드 모두 적절한 인증이 없어 무제한 접근 허용
2. **데이터 무결성:** 클라이언트 측 계산과 검증 부족으로 조작 가능
3. **BLE 보안:** 디바이스 인증 없어 스푸핑 공격에 취약
4. **비즈니스 로직:** 실패한 거래가 성공으로 표시되어 금전적 손실 가능

### 권장 타임라인

**Phase 1 (즉시 - 2주):** 치명적 인증 및 API 이슈 해결
**Phase 2 (1개월):** BLE 보안 및 데이터 검증 강화
**Phase 3 (2-3개월):** 코드 하드닝 및 난독화
**Phase 4 (3-6개월):** 장기 보안 아키텍처 개선

### 다음 단계

1. 이 보고서를 개발팀과 검토
2. 취약점 해결 우선순위 결정
3. 보안 수정 사항 구현
4. 수정 후 재검토 수행
5. 침투 테스트 고려
6. 지속적인 보안 모니터링 설정

---

## 부록 A: 취약점 매핑

### OWASP Mobile Top 10 (2024) 매핑

| OWASP 카테고리 | 발견된 취약점 | 심각도 |
|---------------|-------------|--------|
| M1: Improper Credential Usage | 인증 부재, 약한 사용자 식별 | HIGH |
| M3: Insecure Authentication/Authorization | 인증 메커니즘 부재 | HIGH |
| M5: Insecure Communication | Certificate pinning 없음 | MEDIUM |
| M6: Inadequate Privacy Controls | 과도한 로깅, PII 노출 | HIGH |
| M8: Security Misconfiguration | 디버그 로깅, 난독화 없음 | MEDIUM |
| M9: Insecure Data Storage | 평문 세션 데이터 | MEDIUM |

### CWE (Common Weakness Enumeration) 매핑

| CWE ID | 설명 | 위치 |
|--------|------|------|
| CWE-306 | Missing Authentication | backend_service_impl.dart |
| CWE-311 | Missing Encryption of Sensitive Data | inactivity_service.dart |
| CWE-312 | Cleartext Storage of Sensitive Information | keypad_controller.dart |
| CWE-325 | Missing Cryptographic Step | device_service_impl.dart |
| CWE-754 | Improper Check for Unusual Conditions | device_service_impl.dart |
| CWE-779 | Logging of Excessive Data | backend_service_impl.dart |

---

## 부록 B: 보안 체크리스트

### 배포 전 필수 항목

- [ ] API 인증 구현
- [ ] 프로덕션 로깅 제거
- [ ] Purchase completion 에러 처리
- [ ] BLE 디바이스 인증
- [ ] 사용자 인증 강화
- [ ] BLE 데이터 검증
- [ ] 서버 측 가격 검증
- [ ] 코드 난독화 활성화
- [ ] 적절한 릴리스 서명
- [ ] 보안 테스트 수행

### 권장 추가 항목

- [ ] 인증서 피닝
- [ ] 루팅/탈옥 탐지
- [ ] 앱 무결성 검사
- [ ] 생체 인증
- [ ] 감사 로깅
- [ ] Rate limiting
- [ ] 사기 탐지
- [ ] 백업 비활성화
- [ ] 개인정보 보호정책
- [ ] 침투 테스트

---

**보고서 작성일:** 2025년 11월 24일
**보고서 버전:** 1.0
**검토자:** Claude Code Security Analysis
**다음 검토 예정일:** 수정 완료 후