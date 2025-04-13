// 该控件为一个画布，用于实现绘制
import 'package:flutter/material.dart';
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
      final path = Path();
      if (current == PenCanvasController.nullPoint ||
          next == PenCanvasController.nullPoint) {
        continue;
      }

      paint.strokeWidth =
          pen.pressureSensitivity * current.pressure + pen.width;
      paint.strokeWidth -= pen.speedSensitivity * current.speed; // 叠加速度灵敏度

      path.moveTo(current.offset.dx, current.offset.dy);
      path.quadraticBezierTo(
        current.offset.dx,
        current.offset.dy,
        next.offset.dx,
        next.offset.dy,
      );

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant PenCanvasPainter oldDelegate) {
    return oldDelegate.points.length != points.length;
  }
}

class Point {
  late final Offset offset; // 点的坐标
  late double pressure; // 压力值
  late double speed; // 速度值（画笔速度越快，越细）
  Point(this.offset, this.pressure, this.speed);
}

class Pen {
  final int id;
  final Color color;
  final double width;
  final double pressureSensitivity;
  final double speedSensitivity;

  /// 构造函数，id 默认为当前时间戳
  Pen(
    this.color,
    this.width,
    this.pressureSensitivity,
    this.speedSensitivity,
  ) : id = DateTime.now().millisecondsSinceEpoch;

  /// 用于判断两个笔是否“等价” —— 忽略 id，仅比较内容
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Pen &&
        other.color == color &&
        other.width == width &&
        other.pressureSensitivity == pressureSensitivity &&
        other.speedSensitivity == speedSensitivity;
  }

  @override
  int get hashCode => Object.hash(
        color,
        width,
        pressureSensitivity,
        speedSensitivity,
      );

  /// 创建一个新 Pen，但复制当前数据（除 id）
  Pen copy() {
    return Pen(
      color,
      width,
      pressureSensitivity,
      speedSensitivity,
    );
  }

  @override
  String toString() {
    return 'Pen(id: $id, color: $color, width: $width, pressureSensitivity: $pressureSensitivity, speedSensitivity: $speedSensitivity)';
  }
}

class PenCanvasController extends GetxController {
  final RxList<Point> points = <Point>[].obs; // 画布上的点
  static final nullPoint = Point(Offset(-1, -1), -1, -1);
  static final bool onlyStylus = false; // 是否只允许使用手写笔
  int _pointCount = 0;
  int get pointCount => _pointCount; // 画布上的点的数量

  void addPoint(Offset offset, double pressure, double speed) {
    points.add(Point(offset, pressure, speed));
    _pointCount++;
  }

  void addBreak() {
    points.add(nullPoint);
  }

  void clear() {
    points.clear();
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

  static Pen genPen({
    Color color = Colors.blue,
    double width = 1,
    double pressureSensitivity = 20,
    double speedSensitivity = 0,
  }) {
    return Pen(color, width, pressureSensitivity, speedSensitivity);
  }
}
