// import 'package:flutter/material.dart';
// class GridPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.grey.withOpacity(0.5) // Adjust the color and opacity as needed
//       ..strokeCap = StrokeCap.round;
//
//     const double gridCellSize = 40; // Size of each grid cell
//     const double dotRadius = 2; // Radius of each dot
//
//     // Draw dots
//     for (double x = 0; x < size.width; x += gridCellSize) {
//       for (double y = 0; y < size.height; y += gridCellSize) {
//         canvas.drawCircle(Offset(x, y), dotRadius, paint);
//       }
//     }
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }