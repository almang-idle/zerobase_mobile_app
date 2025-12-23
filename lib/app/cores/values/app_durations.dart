/// 앱 전체에서 사용되는 Duration 상수 정의
///
/// 타이머, 애니메이션, 지연 시간 등에 사용되는 Duration 값들을 정의합니다.
class AppDurations {
  /// BLE 연결 상태 체크 주기
  static const connectionCheckInterval = Duration(seconds: 12);

  /// 무게 안정화 후 화면 전환 대기 시간
  static const weightStabilizationDelay = Duration(milliseconds: 1000);

  /// 리필 안내 화면 자동 전환 시간
  static const refillInstructionDelay = Duration(seconds: 5);

  /// 화면 전환 애니메이션 시간
  static const routeTransition = Duration(milliseconds: 500);

  /// 페이지 애니메이션 시간
  static const pageAnimation = Duration(milliseconds: 500);

  /// 사용자 비활동 타임아웃
  static const inactivityTimeout = Duration(minutes: 3, seconds: 30);

  /// 비활동 타이머 체크 주기
  static const inactivityCheckInterval = Duration(seconds: 1);

  /// 화살표 애니메이션 주기
  static const arrowAnimation = Duration(seconds: 1);

  /// 구매 완료 후 메시지 표시 시간
  static const purchaseCompleteMessage = Duration(seconds: 5);

  // private 생성자 - 인스턴스화 방지
  AppDurations._();
}