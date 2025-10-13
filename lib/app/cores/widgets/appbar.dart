import 'package:flutter/material.dart';

class MyAppbar {
  static PreferredSizeWidget main({
    required String title,
  }) {
    return AppBar(
      title: Text(title),
    );
  }
}
