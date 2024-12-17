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
    final circlePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white;

    for (var entry in touches.entries) {
      circlePaint.color = touchColors[entry.key % touchColors.length];
      strokePaint.color = touchColors[entry.key % touchColors.length];

      canvas.drawCircle(entry.value, 50, circlePaint); // Draw a circle at each touch
      canvas.drawCircle(entry.value, 60, strokePaint); // Draw a stroke at each touch
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
