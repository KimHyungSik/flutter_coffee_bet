import 'package:flutter/material.dart';

class GameOverWidget extends StatelessWidget {
  final VoidCallback onRestart;

  const GameOverWidget({super.key, required this.onRestart});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Column(
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
      ),
    );
  }
}