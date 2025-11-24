import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/app/my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 화면 방향을 가로로 고정
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(MyApp());
}
