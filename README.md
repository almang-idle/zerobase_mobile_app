# 🌿 스마트 리필 프로세스 (Smart Refill Process)

> **저울에 올리기만 하면 무게, 가격, 정보가 자동으로 처리되는 제로웨이스트 샵 전용 스마트 리필 시스템**
>
> **A smart refill system for zero-waste shops where weight, price, and product info are processed automatically just by placing the item on the scale.**

**KAIST 2025 Fall Tech for Impact Project** | **Team 알맹이들**

---

## 🌱 솔루션 한 줄 요약

저울에 올리기만 하면 무게, 가격, 정보가 자동으로 처리되는 제로웨이스트 샵 전용 스마트 리필 시스템
https://github.com/user-attachments/assets/ed87a3ea-8346-4bac-95a8-fca7b1b090b6
---

## 🧐 풀고자 하는 사회 문제

### 1. 생활 실천의 장벽

대한민국 성인의 **86%는 기후변화를 걱정**하지만, 실제로 지속적인 친환경 행동을 실천하는 비율은 제한적입니다. 환경 행동에 대한 의지는 높지만(기후 불안감↑), 이를 실제 행동으로 옮기지 못하는 **심리적 간극**이 존재하며, "내 행동이 도움이 된다"는 효능감이 낮아지고 있습니다.

**주요 문제**:
- 환경 보호 의지는 높으나 실천율은 낮음
- 행동 의지와 실천 사이의 심리적 간극
- 개인 행동의 효능감 저하

### 2. 현장에서의 문제

제로웨이스트 샵(알맹상점 등) 현장에서는 패키지(껍데기)가 없어 **제품 정보 제공이 어렵습니다**. 또한, 고객들은 **복잡하고 헷갈리는 리필 과정**으로 인해 첫 리필 시 당황하거나 불편함을 겪습니다.

**리필 과정의 복잡성**:
1. 공병 무게 측정
2. 영점 조절
3. 내용물 담기
4. 재측정
5. 가격 계산
6. 제품 정보 확인
7. 결제 처리

### 🎯 핵심 목표

일상화 장벽과 현장의 불편함이 맞물려 일회성 경험에 그치는 리필 문화를 개선하여, **알맹상점이 친환경 생활의 '첫걸음'이 되고 지속 가능한 삶으로 이어지도록 합니다.**

---

## 💡 솔루션 개요

### ⚖️ 리필 자동화 시스템

고객이 저울에 리필 용기를 올리기만 하면 **무게 측정, 가격 계산, 제품 정보 매칭이 자동으로 이루어지는 통합 시스템**입니다.

#### 시스템 구성

**1. 하드웨어 (Smart Scale)**
- **Raspberry Pi** - 메인 컴퓨팅 유닛
- **HX711 Amplifier** - 로드셀 신호 증폭
- **Load Cell** - 정밀 무게 측정 (최대 50kg, ±1.0g 정밀도)
- **Custom Acrylic Frame** - 견고한 저울 프레임

**2. ZEROBASE 모바일 앱 (이 저장소)**
- **Flutter 기반** 크로스 플랫폼 키오스크 앱
- **BLE 통신**을 통한 스마트 저울 연동
- 실시간 무게 측정 및 제품 정보 표시
- 직관적인 단계별 리필 가이드
- 자동 비활동 감지 및 초기화

**3. POS 시스템**
- Firestore 기반 실시간 데이터 동기화
- 자동 장바구니 추가 및 가격 계산
- 고객별 리필 내역 관리

**4. 백엔드 API**
- Next.js/Vercel 기반
- 제품 카탈로그 관리
- 리필 데이터 수집 및 분석
- Kakao AlimTalk 연동

### ✨ 핵심 특징

#### 1. Seamless Experience (매끄러운 사용자 경험)
- 기존 6~7단계 과정을 **2단계로 단축**
  1. 빈 용기를 저울에 올리기
  2. 리필 후 저울에 올리기
- 복잡한 영점 조절, 재측정 과정 자동화

#### 2. Real-time Synchronization (실시간 동기화)
```
Smart Scale (BLE) → ZEROBASE App → Backend API → POS System
```
- 저울에서 측정된 무게가 실시간으로 POS에 반영
- 자동 장바구니 추가 및 가격 계산
- Firestore를 통한 즉각적인 데이터 동기화

#### 3. Information Accessibility (정보 접근성)
- 패키지 없이도 제품 정보를 명확히 전달
- 애니메이션 가이드로 직관적인 사용법 안내
- 온보딩 화면으로 첫 사용자 지원

#### 4. Kakao AlimTalk Integration
- 결제 후 리필 경험 데이터 전송
- 탄소 저감량 등 환경 기여도 시각화
- 개인 행동의 효능감 고취

### 🆚 유사 솔루션 대비 특장점

| 구분 | 기존 리필 스테이션 | 스마트 리필 프로세스 |
|------|------------------|---------------------|
| 무게 측정 | 수동 저울, 눈금 확인 | BLE 자동 측정, 디지털 표시 |
| 사용자 경험 | 복잡한 6~7단계 절차 | 간편한 2단계 프로세스 |
| 정확도 | 사람의 눈금 읽기 오차 | ±1.0g 정밀 측정 |
| 제품 정보 | 별도 안내 필요 | 태블릿에 자동 표시 |
| 결제 편의성 | 수동 계산 및 입력 | 자동 장바구니 추가 |
| 피드백 | 없음 | Kakao AlimTalk으로 탄소 저감량 전송 |

### 📊 기대 효과

#### 1. 환경적 효과
- 일회용 포장재 사용 감소
- 플라스틱 쓰레기 배출량 저감
- 재사용 문화 확산 기여

#### 2. 사회적 효과
- 제로웨이스트 실천 접근성 향상
- **환경 보호 효능감 제고** (탄소 저감량 피드백)
- 지속 가능한 소비 문화 조성
- 친환경 생활의 첫걸음 경험 제공

#### 3. 경제적 효과
- 자동화로 인한 운영 효율성 증대
- 정확한 측정으로 재고 관리 효율화
- 고객 만족도 향상을 통한 재방문율 증가

---

## 🚀 기술 스택

### ZEROBASE 모바일 앱 (이 저장소)

#### 핵심 기술
- **Flutter** 3.4.3+ - 크로스 플랫폼 모바일 프레임워크
- **Dart** 3.4.3+ - 프로그래밍 언어
- **GetX** 4.6.6 - 상태 관리 및 라우팅

#### 주요 라이브러리
- **flutter_blue_plus** 2.0.0 - BLE 통신
- **Dio** 5.9.0 - HTTP 클라이언트
- **app_settings** 5.1.1 - 시스템 설정 연동
- **smooth_page_indicator** 1.2.1 - 온보딩 UI
- **logger** 2.6.2 - 구조화된 로깅

#### 지원 플랫폼
- iOS 12.0+ (iPad 최적화, 가로 모드)
- Android 5.0+ (API 21)

### 전체 시스템

#### 하드웨어
- **Raspberry Pi** - Python 기반 저울 제어
- **HX711 & Load Cell** - 정밀 무게 측정

#### 백엔드 & 인프라
- **Next.js** - 서버리스 API
- **Vercel** - 호스팅
- **Firestore** - 실시간 데이터베이스
- **Kakao AlimTalk API** - 알림톡 발송

---

## 📦 설치 및 실행 방법

### 1. 하드웨어 설정 (Smart Scale)

#### 필수 요구사항
- Raspberry Pi (3 이상 권장)
- HX711 Amplifier
- Load Cell (50kg)
- Custom Acrylic Frame

#### 캘리브레이션
```bash
# 가상환경 진입
source hxenv311/bin/activate

# 캘리브레이션 스크립트 실행
python calibrate.py

# 안내에 따라 저울을 비운 상태에서 엔터
# (Follow instructions: Empty scale and press Enter)
```

### 2. ZEROBASE 모바일 앱 설치

#### 필수 요구사항
- Flutter SDK 3.4.3 이상
- Dart SDK 3.4.3 이상
- iOS 개발: Xcode 14.0+, CocoaPods
- Android 개발: Java 21

#### 설치 단계

**1) 저장소 클론**
```bash
git clone https://github.com/almang-idle/zerobase_mobile_app.git
cd zerobase_mobile_app
```

**2) 의존성 설치**
```bash
flutter pub get
```

**3) iOS 설정 (iOS 개발 시)**
```bash
cd ios
pod install
cd ..
```

**4) 앱 실행**
```bash
# 연결된 디바이스 확인
flutter devices

# 선택한 디바이스에서 실행
flutter run -d <device-id>

# 릴리스 모드 실행
flutter run --release -d <device-id>
```

#### 빌드

**Android APK**:
```bash
flutter build apk --release
```

**iOS** (macOS 필요):
```bash
flutter build ios --release
```

### 3. API & Network Logic

#### API 엔드포인트
- **제품 목록 조회**: `GET /api/products`
- **저울 데이터 전송**: `POST /api/ingest-scale`
  ```json
  {
    "phone_suffix": "1234",
    "product_id": "xyz...",
    "weight_gram": 250
  }
  ```

#### POS 운영 흐름
1. POS는 특정 `phone_suffix`에 대한 Firestore 이벤트 모니터링
2. 실시간 무게 업데이트가 "Refill Standby" 리스트에 표시
3. 고객 카드 클릭 시 자동으로 가격 계산 (`weight` × `unit_price`)
4. 장바구니에 자동 추가

---

## 🎥 데모

데모 영상 링크 추가 예정

<!-- 데모 영상이 준비되면 아래 형식으로 추가하세요
[![Smart Refill Process Demo](thumbnail.png)](https://your-video-link.com)
-->

**주요 데모 내용**:
- Calibration Demo: 저울 영점 조절 시연
- Refill Process Demo: 용기를 올리고 POS에 자동 입력되는 과정 시연
- User Experience: 고객 관점의 전체 리필 과정

---

## 📚 연관 자료

### 프로젝트 자료
- 최종 발표 자료: [링크 추가 예정]
- 프로젝트 문서: [링크 추가 예정]

### 파트너
- **알맹상점 (Almang Store)**: [https://almang.net/](https://almang.net/)
- 펠로우 조직: [링크 추가 예정]

### 기술 문서
- [Flutter 공식 문서](https://flutter.dev/docs)
- [GetX 문서](https://github.com/jonataslaw/getx)
- [flutter_blue_plus 문서](https://pub.dev/packages/flutter_blue_plus)
- [Raspberry Pi 공식 문서](https://www.raspberrypi.org/documentation/)

### 관련 리소스
- BLE 통신 사양: 프로젝트 내 `/docs/ble-specification.md`
- 보안 감사 리포트: `/reviews/comprehensive-security-review-2025-11-24.md`

---

## 👥 팀 소개 - Team 알맹이들

우리는 환경 친화적 일상의 시작점을 만드는 **Team 알맹이들**입니다.

### KAIST 2025 Fall Tech for Impact Team

| 이름 | 역할 | 담당 업무 |
|:---:|:---:|:---|
| **김민정** | UX/UI, HW | UX/UI 디자인 및 기획<br/>저울 하드웨어 개발 |
| **김윤서** | POS SW, UX | POS 소프트웨어 개발<br/>UX 디자인 |
| **김한준** | Zero Base SW, HW | ZERO BASE 소프트웨어 개발<br/>저울 하드웨어 개발 |
| **추다은** | Team Leader | 파트너십 커뮤니케이션<br/>프로젝트 총괄 |
| **한유정** | Archiving | 산출물 아카이빙 및 자료 제작 |

### 멘토
- **민경훈** - 카카오모빌리티 / 백엔드 개발자

### 연락처
- **Email**: khjalk8625@kaist.ac.kr
- **GitHub**: [https://github.com/almang-idle/zerobase_mobile_app](https://github.com/almang-idle/zerobase_mobile_app)
- **GitHub Issues**: [이슈 등록](https://github.com/almang-idle/zerobase_mobile_app/issues)

---

## 🔧 프로젝트 구조

### ZEROBASE Mobile App (이 저장소)

```
zerobase_mobile_app/
├── lib/
│   ├── app/
│   │   ├── cores/           # 공통 컴포넌트
│   │   ├── modules/         # 기능 모듈
│   │   │   ├── logo/        # 스플래시 & BLE 연결
│   │   │   ├── main/        # 메인 화면 & 온보딩
│   │   │   ├── product/     # 제품 선택
│   │   │   ├── refill/      # 리필 가이드
│   │   │   ├── keypad/      # 전화번호 입력
│   │   │   └── price/       # 결제 확인
│   │   ├── services/        # 비즈니스 로직
│   │   │   ├── device_service_impl.dart  # BLE 저울 통신
│   │   │   ├── backend_service_impl.dart # API 통신
│   │   │   └── inactivity_service.dart   # 세션 관리
│   │   └── routes/          # 라우팅
│   └── main.dart            # 앱 진입점
├── android/                 # Android 플랫폼
├── ios/                     # iOS 플랫폼
├── assets/                  # 정적 자산
└── reviews/                 # 보안 감사
```

---

## 📱 사용자 플로우

### ZEROBASE 앱 화면 흐름

```
LogoView (스플래시 & BLE 연결)
    ↓
[블루투스 체크 & 저울 연결]
    ↓
MainView (메인 화면)
    ↓
OnboardingView (첫 사용자 가이드)
    ↓
ProductView (제품 선택)
    ↓
RefillView (리필 가이드)
    ├─ GuidePutView: "빈 용기를 저울에 올려주세요"
    │   └─ MeasureWeightView: 빈 병 무게 측정
    │
    ├─ GuideFillView: "제품을 채워주세요"
    │   └─ MeasureWeightView: 총 무게 측정
    ↓
KeypadView (전화번호 뒷자리 입력)
    ↓
PriceView (가격 확인 & 결제)
    ↓
[Firestore → POS 자동 전송]
    ↓
MainView (초기 화면 복귀)
```

### 전체 시스템 플로우

```
고객 → ZEROBASE App → Smart Scale (BLE) → Backend API → Firestore
                                                              ↓
                                                          POS System
                                                              ↓
                                                        Kakao AlimTalk
```

---

## 🔒 보안

프로젝트의 보안 감사 결과 및 개선 권장 사항은 `/reviews/comprehensive-security-review-2025-11-24.md`에서 확인할 수 있습니다.

**주요 보안 고려사항**:
- API 인증 구현 필요
- BLE 디바이스 인증 강화
- 프로덕션 로깅 최소화
- 에러 핸들링 개선

---

## 📄 라이선스

이 프로젝트는 KAIST Tech for Impact 프로그램의 일환으로 개발되었습니다.

Copyright © 2024 Team 알맹이들. All Rights Reserved.

---

## 🌟 기여하기

프로젝트에 기여하고 싶으시다면 다음 단계를 따라주세요:
1. 이 저장소를 Fork 합니다
2. 새로운 브랜치를 생성합니다 (`git checkout -b feature/amazing-feature`)
3. 변경사항을 커밋합니다 (`git commit -m 'Add some amazing feature'`)
4. 브랜치에 Push 합니다 (`git push origin feature/amazing-feature`)
5. Pull Request를 생성합니다

---

**Made with 💚 for a sustainable future | 지속 가능한 미래를 위해**

---
---

# English Version

---

## 🌱 Solution Summary

A smart refill system for zero-waste shops where weight, price, and product info are processed automatically just by placing the item on the scale.

---

## 🧐 Problem Definition

### 1. Barriers to Daily Practice

**86% of Korean adults worry about climate change**, yet the rate of continuous eco-friendly practice is limited. While the willingness to act is high (climate anxiety↑), there is a **psychological gap** preventing action, and the belief that "my actions help" is diminishing.

**Key Issues**:
- High environmental awareness but low practice rate
- Psychological gap between intention and action
- Declining sense of personal efficacy

### 2. Field Problems

At zero-waste shops (such as Almang Store), providing product information is difficult due to the lack of packaging. Additionally, customers often find the **refill process complex and confusing**, leading to inconvenience during their first experience.

**Complex Refill Process**:
1. Weigh empty bottle
2. Tare the scale
3. Fill the product
4. Re-weigh
5. Calculate price
6. Check product info
7. Process payment

### 🎯 Core Goal

To transform the refill culture from a one-time experience caused by barriers and inconvenience, making **Almang Store the first step toward an eco-friendly lifestyle** that leads to sustainable living.

---

## 💡 Solution Overview

### ⚖️ Refill Automation System

An integrated system where **weight measurement, price calculation, and product information matching are automatically processed** just by placing the refill container on the scale.

#### System Components

**1. Hardware (Smart Scale)**
- **Raspberry Pi** - Main computing unit
- **HX711 Amplifier** - Load cell signal amplification
- **Load Cell** - Precise weight measurement (up to 50kg, ±1.0g precision)
- **Custom Acrylic Frame** - Robust scale frame

**2. ZEROBASE Mobile App (This Repository)**
- **Flutter-based** cross-platform kiosk app
- **BLE communication** with smart scale
- Real-time weight measurement and product info display
- Intuitive step-by-step refill guide
- Automatic inactivity detection and reset

**3. POS System**
- Firestore-based real-time data synchronization
- Automatic cart addition and price calculation
- Customer refill history management

**4. Backend API**
- Next.js/Vercel based
- Product catalog management
- Refill data collection and analysis
- Kakao AlimTalk integration

### ✨ Core Features

#### 1. Seamless Experience
- Reduced from 6-7 steps to **just 2 steps**
  1. Place empty container on scale
  2. Place refilled container on scale
- Automated taring and re-measurement process

#### 2. Real-time Synchronization
```
Smart Scale (BLE) → ZEROBASE App → Backend API → POS System
```
- Real-time weight data from scale to POS
- Automatic cart addition and price calculation
- Instant data sync via Firestore

#### 3. Information Accessibility
- Clear product information without packaging
- Intuitive animation guides
- Onboarding screen for first-time users

#### 4. Kakao AlimTalk Integration
- Post-purchase refill experience data delivery
- Carbon reduction visualization
- Enhanced sense of personal efficacy

### 🆚 Advantages Over Similar Solutions

| Category | Traditional Refill Stations | Smart Refill Process |
|----------|----------------------------|---------------------|
| Weight Measurement | Manual scale, visual reading | BLE automatic measurement, digital display |
| User Experience | Complex 6-7 step procedure | Simple 2-step process |
| Accuracy | Human reading errors | ±1.0g precision measurement |
| Product Info | Requires separate guidance | Auto-displayed on tablet |
| Payment Convenience | Manual calculation & input | Automatic cart addition |
| Feedback | None | Carbon reduction via Kakao AlimTalk |

### 📊 Expected Impact

#### 1. Environmental Impact
- Reduction in single-use packaging materials
- Decrease in plastic waste emissions
- Contribution to spreading reuse culture

#### 2. Social Impact
- Improved accessibility to zero-waste practices
- **Enhanced environmental efficacy** (carbon reduction feedback)
- Creating a sustainable consumption culture
- First step toward eco-friendly lifestyle

#### 3. Economic Impact
- Increased operational efficiency through automation
- Improved inventory management through accurate measurement
- Higher customer satisfaction and return rate

---

## 🚀 Tech Stack

### ZEROBASE Mobile App (This Repository)

#### Core Technologies
- **Flutter** 3.4.3+ - Cross-platform mobile framework
- **Dart** 3.4.3+ - Programming language
- **GetX** 4.6.6 - State management & routing

#### Key Libraries
- **flutter_blue_plus** 2.0.0 - BLE communication
- **Dio** 5.9.0 - HTTP client
- **app_settings** 5.1.1 - System settings integration
- **smooth_page_indicator** 1.2.1 - Onboarding UI
- **logger** 2.6.2 - Structured logging

#### Supported Platforms
- iOS 12.0+ (iPad optimized, landscape mode)
- Android 5.0+ (API 21)

### Overall System

#### Hardware
- **Raspberry Pi** - Python-based scale control
- **HX711 & Load Cell** - Precision weight measurement

#### Backend & Infrastructure
- **Next.js** - Serverless API
- **Vercel** - Hosting
- **Firestore** - Real-time database
- **Kakao AlimTalk API** - Notification messaging

---

## 📦 Installation & Setup

### 1. Hardware Setup (Smart Scale)

#### Requirements
- Raspberry Pi (3 or higher recommended)
- HX711 Amplifier
- Load Cell (50kg)
- Custom Acrylic Frame

#### Calibration
```bash
# Activate virtual environment
source hxenv311/bin/activate

# Run calibration script
python calibrate.py

# Follow instructions: Empty scale and press Enter
```

### 2. ZEROBASE Mobile App Installation

#### Prerequisites
- Flutter SDK 3.4.3+
- Dart SDK 3.4.3+
- iOS development: Xcode 14.0+, CocoaPods
- Android development: Java 21

#### Installation Steps

**1) Clone Repository**
```bash
git clone https://github.com/almang-idle/zerobase_mobile_app.git
cd zerobase_mobile_app
```

**2) Install Dependencies**
```bash
flutter pub get
```

**3) iOS Setup (iOS only)**
```bash
cd ios
pod install
cd ..
```

**4) Run App**
```bash
# Check connected devices
flutter devices

# Run on selected device
flutter run -d <device-id>

# Run in release mode
flutter run --release -d <device-id>
```

#### Build

**Android APK**:
```bash
flutter build apk --release
```

**iOS** (macOS required):
```bash
flutter build ios --release
```

### 3. API & Network Logic

#### API Endpoints
- **Get Product List**: `GET /api/products`
- **Ingest Scale Data**: `POST /api/ingest-scale`
  ```json
  {
    "phone_suffix": "1234",
    "product_id": "xyz...",
    "weight_gram": 250
  }
  ```

#### POS Operation Flow
1. POS monitors Firestore events for specific `phone_suffix`
2. Real-time weight updates displayed on "Refill Standby" list
3. Clicking customer card automatically calculates price (`weight` × `unit_price`)
4. Automatically added to cart

---

## 🎥 Demo

Demo video link coming soon

<!-- Add your demo video using this format when ready
[![Smart Refill Process Demo](thumbnail.png)](https://your-video-link.com)
-->

**Demo Content**:
- Calibration Demo: Scale taring demonstration
- Refill Process Demo: Container placement and automatic POS entry
- User Experience: Complete refill process from customer perspective

---

## 📚 References & Resources

### Project Resources
- Final Presentation: [Link coming soon]
- Project Documentation: [Link coming soon]

### Partners
- **Almang Store**: [https://almang.net/](https://almang.net/)
- Fellow Organization: [Link coming soon]

### Technical Documentation
- [Flutter Official Docs](https://flutter.dev/docs)
- [GetX Documentation](https://github.com/jonataslaw/getx)
- [flutter_blue_plus Documentation](https://pub.dev/packages/flutter_blue_plus)
- [Raspberry Pi Official Documentation](https://www.raspberrypi.org/documentation/)

### Related Resources
- BLE Communication Spec: `/docs/ble-specification.md` (in project)
- Security Audit Report: `/reviews/comprehensive-security-review-2025-11-24.md`

---

## 👥 Team - Team Almang-e-deul

We are **Team Almang-e-deul**, creating the starting point for an eco-friendly daily life.

### KAIST 2025 Fall Tech for Impact Team

| Name | Role | Responsibilities |
|:---:|:---:|:---|
| **Minjeong Kim** | UX/UI, HW | UX/UI Design & Planning<br/>Scale Hardware Development |
| **Yunseo Kim** | POS SW, UX | POS Software Development<br/>UX Design |
| **Hanjun Kim** | Zero Base SW, HW | ZERO BASE Software Development<br/>Scale Hardware Development |
| **Daeun Chu** | Team Leader | Partnership Communication<br/>Project Management |
| **Yujeong Han** | Archiving | Output Archiving & Documentation |

### Mentors
- **Kyunghoon Min** - Kakao Mobility / Backend Developer

### Contact
- **Email**: khjalk8625@kaist.ac.kr
- **GitHub**: [https://github.com/almang-idle/zerobase_mobile_app](https://github.com/almang-idle/zerobase_mobile_app)
- **GitHub Issues**: [Report Issue](https://github.com/almang-idle/zerobase_mobile_app/issues)

---

## 🔧 Project Structure

### ZEROBASE Mobile App (This Repository)

```
zerobase_mobile_app/
├── lib/
│   ├── app/
│   │   ├── cores/           # Shared components
│   │   ├── modules/         # Feature modules
│   │   │   ├── logo/        # Splash & BLE connection
│   │   │   ├── main/        # Main screen & onboarding
│   │   │   ├── product/     # Product selection
│   │   │   ├── refill/      # Refill guide
│   │   │   ├── keypad/      # Phone input
│   │   │   └── price/       # Checkout confirmation
│   │   ├── services/        # Business logic
│   │   │   ├── device_service_impl.dart  # BLE scale communication
│   │   │   ├── backend_service_impl.dart # API communication
│   │   │   └── inactivity_service.dart   # Session management
│   │   └── routes/          # Routing
│   └── main.dart            # App entry point
├── android/                 # Android platform
├── ios/                     # iOS platform
├── assets/                  # Static assets
└── reviews/                 # Security reviews
```

---

## 📱 User Flow

### ZEROBASE App Screen Flow

```
LogoView (Splash & BLE Connection)
    ↓
[Bluetooth Check & Scale Connection]
    ↓
MainView (Main Screen)
    ↓
OnboardingView (First-time User Guide)
    ↓
ProductView (Product Selection)
    ↓
RefillView (Refill Guide)
    ├─ GuidePutView: "Place empty container on scale"
    │   └─ MeasureWeightView: Empty bottle weight measurement
    │
    ├─ GuideFillView: "Fill your product"
    │   └─ MeasureWeightView: Total weight measurement
    ↓
KeypadView (Phone Number Suffix Input)
    ↓
PriceView (Price Confirmation & Checkout)
    ↓
[Firestore → Auto-send to POS]
    ↓
MainView (Return to Initial Screen)
```

### Overall System Flow

```
Customer → ZEROBASE App → Smart Scale (BLE) → Backend API → Firestore
                                                                 ↓
                                                             POS System
                                                                 ↓
                                                           Kakao AlimTalk
```

---

## 🔒 Security

Security audit results and improvement recommendations can be found in `/reviews/comprehensive-security-review-2025-11-24.md`.

**Key Security Considerations**:
- API authentication implementation needed
- Strengthened BLE device authentication
- Minimized production logging
- Improved error handling

---

## 📄 License

This project was developed as part of the KAIST Tech for Impact program.

Copyright © 2024 Team Almang-e-deul. All Rights Reserved.

---

## 🌟 Contributing

If you'd like to contribute to this project:
1. Fork this repository
2. Create a new branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Create a Pull Request

---

**Made with 💚 for a sustainable future | 지속 가능한 미래를 위해**
