// 该控件为一个画布，用于实现绘制
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserCanvas extends StatelessWidget {
  const UserCanvas({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _UserCanvasPainter());
  }
}

class _UserCanvasPainter extends CustomPainter {
  final canvasController = Get.find<CanvasController>(); // 获取控制器实例

  @override
  void paint(Canvas canvas, Size size) {
    canvasController.drawBackground(canvas, size, Colors.white); // 绘制背景
    // 在画布上绘制点
    var path = Path();
    if (canvasController.points.isEmpty) {
      return;
    }
    path.moveTo(canvasController.points[0].dx, canvasController.points[0].dy);

    for (int i = 1; i < canvasController.points.length; i++) {
      var last = canvasController.points[i - 1];
      var current = canvasController.points[i];
      path.quadraticBezierTo(
        (last.dx + current.dx) / 2,
        (last.dy + current.dy) / 2,
        current.dx,
        current.dy,
      );
    }

    canvas.drawPath(path, canvasController.paint); // 使用控制器中的画笔绘制路径
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class CanvasController extends GetxController {
  var points = <Offset>[].obs; // 用于存储绘制的点
  bool onlyStylus = false; // 是否只允许使用手写笔绘制
  var paint =
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke; // 设置画笔颜色

  void addPoint(Offset point) {
    points.add(point);
    update(); // 更新画布
  }

  void clearPoints() {
    points.clear();
  }

  void setPaintColor(Color color) {
    paint.color = color;
  }

  void setPaintWidth(double width) {
    paint.strokeWidth = width;
  }

  void drawBackground(Canvas canvas, Size size, Color color) {
    final backgroundPaint =
        Paint()
          ..color =
              color // 设置背景颜色
          ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      backgroundPaint,
    );
  }
}
