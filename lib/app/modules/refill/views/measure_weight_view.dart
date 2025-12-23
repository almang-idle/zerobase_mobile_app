import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/app/cores/bases/base_widget.dart';
import 'package:myapp/app/cores/values/app_colors.dart';
import 'package:myapp/app/modules/refill/controllers/refill_controller.dart';

class MeasureWeightView extends BaseWidget<RefillController> {
  MeasureWeightView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Obx(
        () {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 500), // 화면 전환 속도
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: controller.stableFlag
                ? const MeasurementSuccessView(key: ValueKey('success'))
                : _buildLoadingWidget(key: const ValueKey('loading')),
          );
        },
      ),
    );
  }

  // 로딩 위젯
  Widget _buildLoadingWidget({Key? key}) {
    return Center(
      key: key,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 126,
            width: 126,
            child: SizedBox(
              height: 102,
              width: 102,
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 12,
              ),
            ),
          ),
          SizedBox(height: 35),
          Text(
            "제품이 담긴 병의 무게를 측정 중입니다",
            style: TextStyle(fontSize: 30, color: AppColors.primary),
          ),
          SizedBox(height: 35),
          Text(
            "병을 움직이지 마세요",
            style: TextStyle(fontSize: 45, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

// 이 코드를 MeasureWeightView 파일 상단이나 별도의 파일에 추가하세요.

class MeasurementSuccessView extends StatefulWidget {
  const MeasurementSuccessView({super.key});

  @override
  State<MeasurementSuccessView> createState() => _MeasurementSuccessViewState();
}

class _MeasurementSuccessViewState extends State<MeasurementSuccessView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _iconScaleAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // 전체 애니메이션 시간 (1초)
    );

    _iconScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );
    _textSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ScaleTransition(
          scale: _iconScaleAnimation,
          child: const Icon(
            Icons.check,
            color: AppColors.green,
            size: 133,
          ),
        ),
        const SizedBox(height: 33),
        FadeTransition(
          opacity: _textFadeAnimation,
          child: SlideTransition(
            position: _textSlideAnimation,
            child: const Text(
              "무게 측정이 완료되었습니다",
              style: TextStyle(
                fontSize: 30,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
