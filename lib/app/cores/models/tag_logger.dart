// lib/utils/tagged_logger.dart
import 'package:logger/logger.dart';

/// 태그를 자동으로 붙여주는 Logger 래퍼 클래스
class TagLogger {

  /// 모든 TaggedLogger 인스턴스가 공유할 실제 Logger
  /// (PrettyPrinter 설정 등을 한 곳에서 관리하기 위함)
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0, // 메소드 호출 스택은 0줄
      errorMethodCount: 5, // 에러는 5줄
      lineLength: 80,
      colors: true,
      printEmojis: true,
      printTime: false,
    ),
  );

  /// 이 로거 인스턴스의 고유 태그
  final String tag;

  /// 생성자: 태그를 받아서 초기화합니다.
  TagLogger(this.tag);

  /// Info 로그
  void i(String message) {
    _logger.i('[$tag] $message');
  }

  /// Debug 로그
  void d(String message) {
    _logger.d('[$tag] $message');
  }

  /// Warning 로그
  void w(String message) {
    _logger.w('[$tag] $message');
  }

  /// Error 로그
  void e(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e('[$tag] $message', error: error, stackTrace: stackTrace);
  }

  /// Verbose 로그
  void v(String message) {
    _logger.v('[$tag] $message');
  }
}