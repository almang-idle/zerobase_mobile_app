# ZEROBASE Mobile App

> KAIST 2025 Fall Tech for Impact Project

ZEROBASE는 BLE(Bluetooth Low Energy)로 연결되는 스마트 저울과 연동하여 리필 스테이션에서 정확한 무게 측정 및 결제를 지원하는 Flutter 앱입니다.

## 주요 기능

### 🔵 BLE 디바이스 연결
- ZEROBASE-SCALE 디바이스 자동 스캔 및 연결
- 블루투스 상태 감지 및 설정 안내
- 실시간 무게 데이터 수신 (4바이트 Little-Endian float)

### ⚖️ 무게 측정
- 실시간 무게 측정 (최대 50kg)
- 빈 용기 무게 측정 (Tare 기능)
- 총 무게 및 내용물 무게 계산

### 🛒 제품 선택 및 결제
- 제품 카탈로그 조회
- 장바구니 기능
- 무게 기반 가격 계산

### 📱 리필 가이드
- 단계별 리필 안내 UI
- 애니메이션 가이드 (위/아래 화살표)

### ⏱️ 자동 화면 초기화
- 사용자 비활동 감지
- 일정 시간 후 자동으로 초기 화면 복귀

## 기술 스택

- **Flutter** 3.4.3+
- **GetX** 4.6.6 - 상태 관리 및 라우팅
- **flutter_blue_plus** 2.0.0 - BLE 통신
- **app_settings** 5.1.1 - 시스템 설정 이동
- **dio** 5.9.0 - HTTP 통신
- **Cupertino Widgets** - iOS 스타일 UI

## 프로젝트 구조

```
lib/
├── app/
│   ├── cores/
│   │   ├── bases/          # BaseView, BaseController
│   │   ├── models/         # TagLogger, Device 모델
│   │   └── values/         # BleConstants, AppColors
│   ├── modules/
│   │   ├── logo/           # 스플래시 및 BLE 연결
│   │   ├── main/           # 메인 화면 및 온보딩
│   │   ├── product/        # 제품 선택
│   │   ├── refill/         # 리필 가이드
│   │   ├── keypad/         # 전화번호 입력
│   │   └── price/          # 가격 확인 및 결제
│   ├── services/
│   │   ├── device_service.dart       # BLE 디바이스 관리 (추상 클래스)
│   │   ├── device_service_impl.dart  # 실제 BLE 구현
│   │   ├── backend_service.dart      # 백엔드 API 통신
│   │   └── inactivity_service.dart   # 비활동 감지
│   └── routes/
│       └── app_pages.dart  # 라우트 정의
└── main.dart
```

## 시작하기

### 필수 요구사항

- Flutter SDK 3.4.3 이상
- Dart SDK 3.4.3 이상
- iOS 12.0 이상 (iPad)
- Android 5.0 (API 21) 이상
- CocoaPods (iOS 개발용)
- Xcode 14.0 이상

### 설치

1. 저장소 클론
```bash
git clone https://github.com/almang-idle/zerobase_mobile_app.git
cd zerobase_mobile_app
```

2. 의존성 설치
```bash
flutter pub get
```

3. iOS CocoaPods 설치
```bash
cd ios
pod install
cd ..
```

4. 앱 실행
```bash
# 연결된 디바이스 확인
flutter devices

# 선택한 디바이스에서 실행
flutter run -d <device-id>
```

## BLE 통신 사양

### 디바이스 식별
- **디바이스 이름**: `ZEROBASE-SCALE` (접두사)

### UUID 정의
- **Service UUID**: `a5fbf7b2-696d-45c9-8f59-4f3592a23b49`
- **Weight Characteristic UUID**: `6e170b83-7095-4a4c-b01b-ab15e2355ddd`

### 데이터 형식
- **무게 데이터**: 4바이트 Little-Endian Float
- **단위**: 그램(g)
- **범위**: 0 ~ 50,000g (0 ~ 50kg)
- **이상 감지 임계값**: 10kg 급격한 변화

## 화면 흐름

```
LogoView (스플래시)
    ↓
[블루투스 체크]
    ├─ OFF → BluetoothSettingsDialog
    └─ ON → [디바이스 스캔]
              ├─ 연결 안됨 → ScanDevicesDialog
              └─ 연결됨 → MainView
                            ↓
                        OnboardingView
                            ↓
                        ProductView (제품 선택)
                            ↓
                        RefillView (리필 안내)
                            ↓
                        KeypadView (전화번호 입력)
                            ↓
                        PriceView (가격 확인 및 결제)
                            ↓
                        MainView (복귀)
```

## 주요 서비스

### DeviceService
BLE 디바이스 관리 및 무게 데이터 처리
- `connectToDevice(deviceId)` - 디바이스 연결
- `getWeight()` - 실시간 무게 스트림
- `setEmptyBottleWeight(weight)` - 빈 용기 무게 설정
- `setTotalWeight(weight)` - 총 무게 설정

### BackendService
백엔드 API 통신
- 제품 목록 조회
- 주문 생성 및 결제

### InactivityService
사용자 비활동 감지 및 자동 초기화
- 설정된 시간 동안 활동이 없으면 메인 화면으로 복귀

## 보안

- 프로덕션 환경에서 민감한 정보 로깅 방지
- API 에러 처리 시 상세 정보 노출 차단
- BLE 데이터 검증 및 이상 감지

## 개발 팁

### 로깅
프로젝트에서는 `TagLogger`를 사용합니다:
```dart
final log = TagLogger("ControllerName");
log.i("Info message");
log.e("Error message");
```

### 더미 모드
실제 BLE 디바이스 없이 테스트하려면 `device_service_dummy.dart` 사용 가능

## 라이선스

이 프로젝트는 KAIST Tech for Impact 프로그램의 일환으로 개발되었습니다.

## 기여자

KAIST 2025 Fall Tech for Impact Team

## 문의

프로젝트 관련 문의사항은 이슈를 등록하거나 아래 메일로 연락주세요.

**Email**: khjalk8625@kaist.ac.kr