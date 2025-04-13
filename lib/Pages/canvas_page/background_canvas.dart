import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BackgroundCanvas extends StatelessWidget {
  const BackgroundCanvas({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BackgroundCanvasPainter(),
      size: Size.infinite,
    );
  }
}

class _BackgroundCanvasPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Draw a white rectangle as the background
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false; // No need to repaint unless the background changes
  }
}
