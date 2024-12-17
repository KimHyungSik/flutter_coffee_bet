import 'package:flutter/material.dart';

class TouchPainter extends CustomPainter {
  final Map<int, Offset> touches;
  final List<Color> touchColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.purple,
  ];

  TouchPainter(this.touches);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;

    for (var entry in touches.entries) {
      paint.color = touchColors[entry.key % touchColors.length];
      canvas.drawCircle(entry.value, 30, paint); // Draw a circle at each touch
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
