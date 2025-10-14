import 'package:flutter/cupertino.dart';

class AnimatedArrowUpImage extends StatefulWidget {
  const AnimatedArrowUpImage({super.key});

  @override
  _AnimatedArrowUpImageState createState() => _AnimatedArrowUpImageState();
}

class _AnimatedArrowUpImageState extends State<AnimatedArrowUpImage>
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
      end: const Offset(0, -0.3),
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
      child: Transform.scale(
        scaleY: -1,
        child: Image.asset(
          'assets/images/down_arrow.png',
          width: 226,
          height: 215,
        ),
      ),
    );
  }
}