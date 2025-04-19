import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:get/get.dart';
import 'package:echo_note/component/stroke/pen.dart';
import 'package:echo_note/component/stroke/path_opt.dart';
import 'pen_canvas.dart';

class PenCanvasStatic extends StatelessWidget {
  final int staticCanvasUpdateCount;
  final ui.Picture? picture;
  const PenCanvasStatic({
    super.key,
    required this.staticCanvasUpdateCount,
    required this.picture,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PenCanvasStaticPainter(
        mergeCount: staticCanvasUpdateCount,
        picture: picture,
      ),
      size: Size.infinite,
      isComplex: true,
    );
  }
}

class _PenCanvasStaticPainter extends CustomPainter {
  final int mergeCount;
  final ui.Picture? picture;
  const _PenCanvasStaticPainter({
    required this.mergeCount,
    required this.picture,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // debugPrint("PenCanvasStaticPainter paint $mergeCount");
    canvas.drawPicture(picture!);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return mergeCount != (oldDelegate as _PenCanvasStaticPainter).mergeCount;
    // return false;
  }
}

class PenCanvasStaticController extends GetxController {
  final int tag;

  late ui.PictureRecorder recorder0;
  late Canvas canvas0;
  late ui.PictureRecorder recorder1;
  late Canvas canvas1;

  Pen pen = Pen.genPen();
  late Point lastPoint; // 上一个点

  final staticCanvasUpdateCount = 0.obs; // 合并次数

  final List<Point> points0 = [];
  final List<Point> points1 = [];
  final List<Pen> pens = [];

  Paint paint0 =
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

  Paint paint1 =
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

  PenCanvasStaticController({required this.tag}) {
    init();
    init0();
    init1();
    // Timer.periodic(Duration(milliseconds: 33), (_) => _init());
  }

  void init0() {
    recorder0 = ui.PictureRecorder();
    canvas0 = Canvas(recorder0);
  }

  void init1() {
    recorder1 = ui.PictureRecorder();
    canvas1 = Canvas(recorder1);
    lastPoint = PenCanvasController.nullPoint;
  }

  void addPoint(Point point) {
    Path path = Path();

    if (lastPoint == PenCanvasController.nullPoint ||
        point == PenCanvasController.nullPoint) {
      lastPoint = point;
      return;
    }

    path.moveTo(lastPoint.offset.dx, lastPoint.offset.dy);
    // path.quadraticBezierTo(
    //   lastPoint.offset.dx,
    //   lastPoint.offset.dy,
    //   point.offset.dx,
    //   point.offset.dy,
    // );

    path.lineTo(point.offset.dx, point.offset.dy);
    paint1.color = pen.color;
    paint1.strokeWidth = pen.pressureSensitivity * point.pressure + pen.width;
    paint1.strokeWidth -= pen.speedSensitivity * point.speed;

    canvas1.drawPath(path, paint1);
    lastPoint = point;

    points1.add(point);
  }

  void addBreak() {
    lastPoint = PenCanvasController.nullPoint;
    points1.add(PenCanvasController.nullPoint);

    if (pens.isEmpty) {
      pens.add(pen);
      return;
    }

    if (pens.last != pen) {
      pens.add(pen);
    }
  }

  void merge() {
    canvas0.drawPicture(recorder1.endRecording());
    init1();
    staticCanvasUpdateCount.value++;

    PathOptimization.optimizePath(points1).then((returnValue) {
      debugPrint(
        "optimize: before ${points1.length} after ${returnValue.length} sub -${points1.length - returnValue.length} portion ${(points1.length - returnValue.length) / points1.length}",
      );
      points0.addAll(returnValue);
      // points0.addAll(points1);
      points1.clear();

      init();
    });
  }

  ui.Picture get0() {
    final picture = recorder0.endRecording();
    init0();
    canvas0.drawPicture(picture);

    return picture;
  }

  // 根据所有点列表去绘制静态画布
  void init() {
    init0();

    if (pens.isNotEmpty) {
      paint0.color = pens.last.color;
    }

    for (int i = 0, j = 0; i < points0.length - 1; i++) {
      final prev = i > 0 ? points0[i - 1] : null;
      final current = points0[i];
      final next = points0[i + 1];

      // 如果当前点或下一个点是 nullPoint
      if (current == PenCanvasController.nullPoint ||
          next == PenCanvasController.nullPoint) {
        // 如果当前点是 nullPoint
        if (current == PenCanvasController.nullPoint) {
          // 判断下一个点的时间是否超过了下一个笔的时间戳
          if (j + 1 < pens.length && next.stamp < pens[j + 1].id) {
            // 更新笔的颜色
            j++;
            paint0.color = pens[j].color;
          }
        }
        continue;
      }

      final pressureInterpolated =
          (current.pressure + next.pressure) / 2; // 或用更复杂的曲线插值
      final speedInterpolated = (current.speed + next.speed) / 2;

      paint0.strokeWidth =
          pens[j].pressureSensitivity * pressureInterpolated +
          pens[j].width -
          pens[j].speedSensitivity * speedInterpolated;
      final path = Path();

      final control =
          (prev == null || prev == PenCanvasController.nullPoint)
              ? next.offset
              : _computeControlPoint(
                prev.offset,
                current.offset,
                next.offset,
                0.1,
              );

      path.moveTo(current.offset.dx, current.offset.dy);
      path.quadraticBezierTo(
        control.dx,
        control.dy,
        next.offset.dx,
        next.offset.dy,
      );
      // path.lineTo(next.offset.dx, next.offset.dy);

      canvas0.drawPath(path, paint0);
    }

    staticCanvasUpdateCount.value++;
  }

  Offset _computeControlPoint(
    Offset prev,
    Offset current,
    Offset next,
    double tension,
  ) {
    final dx = next.dx - prev.dx;
    final dy = next.dy - prev.dy;
    return Offset(current.dx + dx * tension, current.dy + dy * tension);
  }
}
