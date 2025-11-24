/// 무게 측정 관련 상수 정의
///
/// 무게 안정화 알고리즘 및 측정 범위에 사용되는 상수들을 정의합니다.
class WeightConstants {
  /// 무게 안정화 판단 오차 범위 (그램)
  ///
  /// 버퍼 내 무게 값들이 평균에서 이 값 이내로 분포되어 있으면 안정 상태로 판단합니다.
  static const double stabilityTolerance = 1.0;

  /// 최소 측정 무게 (그램)
  ///
  /// 이 값 이하의 무게는 측정하지 않습니다.
  static const double minimumWeight = 100.0;

  /// 무게 버퍼 크기
  ///
  /// 무게 안정화 판단을 위해 저장하는 최근 측정값의 개수입니다.
  static const int bufferSize = 20;

  // private 생성자 - 인스턴스화 방지
  WeightConstants._();
}
