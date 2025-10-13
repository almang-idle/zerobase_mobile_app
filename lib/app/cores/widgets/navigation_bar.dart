import 'package:flutter/material.dart';

import '../values/app_colors.dart';

class MyNavigationBar {
  static BottomNavigationBar main({required onTap, required currentIndex}) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.primaryNormal,
      onTap: onTap,
      items: [],
    );
  }
}
