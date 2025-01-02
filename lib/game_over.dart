import 'package:coffee_bet/user_circle_painter.dart';
import 'package:flutter/material.dart';

class GameOverWidget extends StatelessWidget {
  final VoidCallback onRestart;
  final Map<int, Offset> failingPointers;

  const GameOverWidget(
      {super.key, required this.onRestart, required this.failingPointers});

  @override
  Widget build(BuildContext context) {
    print("LOGEE $failingPointers");
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
                    color: Colors.redAccent,
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: Offset(2, 2),
                        blurRadius: 10,
                        color: Colors.black54,
                      ),
                      Shadow(
                        offset: Offset(-2, -2),
                        blurRadius: 10,
                        color: Colors.black38,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: onRestart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 8,
                    shadowColor: Colors.black54,
                  ),
                  child: const Text(
                    '다시 하기',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
