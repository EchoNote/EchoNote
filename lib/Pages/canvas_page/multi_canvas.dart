// 将不同的pen_canvas叠加起来
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:echo_note/component/stroke/pen.dart';
import 'background_canvas.dart';
import 'pen_canvas.dart';
import 'pen_canvas_static.dart';
import 'dart:ui' as ui;

class MultiCanvas extends StatelessWidget {
  final int tag;
  const MultiCanvas({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    MultiCanvasController controller = Get.find<MultiCanvasController>(
      tag: tag.toString(),
    );
    return Stack(
      children: [
        const BackgroundCanvas(),

        Obx(() {
          final picture = controller.penCanvasStaticController.get0();
          return RepaintBoundary(
            child: PenCanvasStatic(
              staticCanvasUpdateCount:
                  controller
                      .penCanvasStaticController
                      .staticCanvasUpdateCount
                      .value,
              picture: picture,
            ),
          );
        }),

        Obx(
          () => RepaintBoundary(
            child: PenCanvas(
              points: controller.penCanvasController.points.toList(),
              pen: controller.penCanvasController.pen,
            ),
          ),
        ),
      ],
    );
  }
}

class MultiCanvasController extends GetxController {
  final int tag;
  late final PenCanvasStaticController penCanvasStaticController;
  late final PenCanvasController penCanvasController;
  static const int _maxCount = 50;
  static const int _checkMinDuration = 5000; // 至少五秒才检查
  bool _allowCheck = true;
  bool get allowCheck => _allowCheck;

  MultiCanvasController({required this.tag}) {
    Get.put(this, tag: tag.toString());
    Get.put(
      penCanvasStaticController = PenCanvasStaticController(tag: tag),
      tag: tag.toString(),
    );
    Get.put(
      penCanvasController = PenCanvasController(tag: tag),
      tag: tag.toString(),
    );
  }

  void merge() {
    penCanvasStaticController.merge();
    penCanvasController.clear();
    debugPrint("merge");
  }

  void setPen(Pen pen) {
    merge();
    penCanvasStaticController.pen = pen;
    penCanvasController.pen = pen;
  }

  void addPoint(Point point) {
    penCanvasController.addPoint(point);
    penCanvasStaticController.addPoint(point);
  }

  void addBreak() {
    penCanvasController.addBreak();
    penCanvasStaticController.addBreak();
  }

  void check() {
    if (!_allowCheck) return;
    _allowCheck = false;
    debugPrint("check");
    if (penCanvasController.pointCount > _maxCount) {
      merge();
    }

    Timer(const Duration(milliseconds: _checkMinDuration), () {
      _allowCheck = true;
    });
  }
}
