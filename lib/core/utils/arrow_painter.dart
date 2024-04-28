import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.square;

    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);

    const arrowSize = 6.0; // Smaller size for the arrowhead
    canvas.drawLine(Offset(size.width, size.height / 2), Offset(size.width - arrowSize, size.height / 2 - arrowSize), paint);
    canvas.drawLine(Offset(size.width, size.height / 2), Offset(size.width - arrowSize, size.height / 2 + arrowSize), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
