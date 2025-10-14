import 'package:flutter/cupertino.dart';

class AnimatedArrowDownImage extends StatefulWidget {
  const AnimatedArrowDownImage({super.key});

  @override
  _AnimatedArrowDownImageState createState() => _AnimatedArrowDownImageState();
}

class _AnimatedArrowDownImageState extends State<AnimatedArrowDownImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, 0.3),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: Image.asset(
        'assets/images/down_arrow.png',
        width: 226,
        height: 215,
      ),
    );
  }
}