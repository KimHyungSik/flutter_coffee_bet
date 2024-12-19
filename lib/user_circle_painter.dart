import 'package:flutter/material.dart';

class UserCirclePainter extends CustomPainter {
  final Map<int, Offset> users;
  static const List<Color> touchColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.purple,
  ];

  UserCirclePainter(this.users);

  @override
  void paint(Canvas canvas, Size size) {
    final circlePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white;

    for (var entry in users.entries) {
      circlePaint.color = entry.key.userToColor();
      strokePaint.color = entry.key.userToColor();

      canvas.drawCircle(
          entry.value, 50, circlePaint); // Draw a circle at each touch
      canvas.drawCircle(
          entry.value, 60, strokePaint); // Draw a stroke at each touch
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

extension Coloring on int {
  Color userToColor() {
    return UserCirclePainter.touchColors[this % UserCirclePainter.touchColors.length];
  }
}
