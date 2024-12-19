import 'package:coffee_bet/user_circle_painter.dart';
import 'package:flutter/material.dart';

class GameOverWidget extends StatelessWidget {
  final VoidCallback onRestart;
  final Map<int, Offset> failingPointers;

  const GameOverWidget(
      {super.key, required this.onRestart, required this.failingPointers});

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
                const Text(
                  'Game Over!',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: onRestart,
                  child: const Text('Restart'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
