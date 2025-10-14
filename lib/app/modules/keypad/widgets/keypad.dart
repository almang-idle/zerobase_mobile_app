import 'package:flutter/material.dart';

class Keypad extends StatelessWidget {
  final Function(String) onNumberPressed;
  final VoidCallback onBackspacePressed;

  const Keypad(
      {required this.onNumberPressed, required this.onBackspacePressed});

  @override
  Widget build(BuildContext context) {
    final keys = [
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '',
      '0',
      'backspace'
    ];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.5,
      ),
      itemCount: keys.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final key = keys[index];

        if (key.isEmpty) {
          return const SizedBox.shrink();
        }

        return TextButton(
          style: TextButton.styleFrom(
            shape: const CircleBorder(),
          ),
          onPressed: () {
            if (key == 'backspace') {
              onBackspacePressed();
            } else {
              onNumberPressed(key);
            }
          },
          child: key == 'backspace'
              ? const Icon(Icons.backspace_outlined, color: Colors.black)
              : Text(
                  key,
                  style: const TextStyle(fontSize: 28, color: Colors.black),
                ),
        );
      },
    );
  }
}
