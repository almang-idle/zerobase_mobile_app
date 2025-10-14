import 'package:flutter/material.dart';
import 'package:myapp/app/cores/values/app_colors.dart';

class PhoneNumberDisplay extends StatelessWidget {
  final String pin;

  const PhoneNumberDisplay({super.key, required this.pin});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('010 - ',
            style: TextStyle(fontSize: 50, color: Colors.grey)),
        ...List.generate(4, (index) => _buildDot()),
        const Text(' - ', style: TextStyle(fontSize: 50, color: Colors.grey)),
        // 4자리 입력 칸
        ...List.generate(4, (index) {
          if (index == 0) {
            return _buildPinBox(
              number: index < pin.length ? pin[index] : null,
            );
          } else {
            return Padding(
              padding: const EdgeInsets.only(left: 20),
              child: _buildPinBox(
                number: index < pin.length ? pin[index] : null,
              ),
            );
          }
        }),
      ],
    );
  }

  Widget _buildDot() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: 24,
      height: 24,
      decoration: const BoxDecoration(
        color: Color(0xFF9D9D9D),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildPinBox({String? number}) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Center(
        child: Text(
          number ?? '',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
