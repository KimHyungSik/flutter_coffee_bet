import 'package:coffee_bet/user_circle_painter.dart';
import 'package:flutter/material.dart';

import 'common/button/re_start_button.dart';

class GameOverWidget extends StatelessWidget {
  final VoidCallback onRestart;
  final Map<int, Offset> failingPointers;
  final String title;

  const GameOverWidget(
      {super.key, required this.onRestart, required this.failingPointers, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              painter: UserCirclePainter(failingPointers),
              child: Container(), // Covers the entire screen
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                reStartButton(onRestart),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
