// lib/utils/tagged_logger.dart
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';

class ToastLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      // 메소드 호출 스택은 0줄
      errorMethodCount: 5,
      // 에러는 5줄
      lineLength: 80,
      colors: true,
      printEmojis: true,
      printTime: false,
    ),
  );

  final String tag;

  ToastLogger(this.tag);

  /// Info 로그
  void i(dynamic message) {
    String msg = '[$tag] $message';
    _logger.i(msg);
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

  /// Debug 로그
  void d(dynamic message) {
    String msg = '[$tag] $message';
    _logger.d(msg);
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

  /// Warning 로그
  void w(dynamic message) {
    String msg = '[$tag] $message';
    _logger.w(msg);
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

  /// Error 로그
  void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    String msg = '[$tag] $message';
    _logger.e('[$tag] $message', error: error, stackTrace: stackTrace);
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

  /// Verbose 로그
  void v(dynamic message) {
    String msg = '[$tag] $message';
    _logger.v(msg);
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }
}
