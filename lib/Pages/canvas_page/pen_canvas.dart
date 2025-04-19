// 该控件为一个画布，用于实现绘制
import 'package:flutter/material.dart';
import 'package:echo_note/component/stroke/pen.dart';
import 'package:get/get.dart';

class PenCanvas extends StatelessWidget {
  // 一支笔对应一个画布
  final List<Point> points;
  final Pen pen;

  const PenCanvas({super.key, required this.points, required this.pen});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: PenCanvasPainter(points, pen),
      size: Size.infinite,
      isComplex: false,
      willChange: true,
    );
  }
}

class PenCanvasPainter extends CustomPainter {
  List<Point> points;
  Pen pen;
  PenCanvasPainter(this.points, this.pen);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) {
      return;
    }

    var paint =
        Paint()
          ..color = pen.color
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

    for (int i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];
      if (current == PenCanvasController.nullPoint ||
          next == PenCanvasController.nullPoint) {
        continue;
      }

      paint.strokeWidth =
          pen.pressureSensitivity * current.pressure + pen.width;
      paint.strokeWidth -= pen.speedSensitivity * current.speed; // 叠加速度灵敏度

      final path = Path();
      path.moveTo(current.offset.dx, current.offset.dy);
      // path.quadraticBezierTo(
      //   current.offset.dx,
      //   current.offset.dy,
      //   next.offset.dx,
      //   next.offset.dy,
      // );
      path.lineTo(next.offset.dx, next.offset.dy);

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant PenCanvasPainter oldDelegate) {
    return oldDelegate.points.length != points.length;
  }
}

class PenCanvasController extends GetxController {
  final int tag;
  final RxList<Point> points = <Point>[].obs; // 画布上的点
  Pen pen = Pen.genPen(); // 画笔
  static final nullPoint = Point(Offset(-1, -1), -1, -1);
  static final bool onlyStylus = true; // 是否只允许使用手写笔
  int _pointCount = 0;
  int get pointCount => _pointCount; // 画布上的点的数量

  PenCanvasController({required this.tag});

  void addPoint(Point point) {
    points.add(point);
    _pointCount++;
    // debugPrint(_pointCount.toString());
  }

  void addBreak() {
    points.add(nullPoint);
  }

  void clear() {
    points.clear();
    _pointCount = 0;
  }

  void recall() {
    if (points.isEmpty) {
      return;
    }

    points.removeLast();
    while (points.last != nullPoint) {
      points.removeLast();
    }
  }
}
