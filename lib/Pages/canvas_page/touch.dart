import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'multi_canvas.dart';
import 'pen_canvas.dart';
import 'package:echo_note/component/stroke/pen.dart';

class Touch extends StatelessWidget {
  final int tag;
  const Touch({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    final multiCanvasController = Get.find<MultiCanvasController>(
      tag: tag.toString(),
    );

    return Listener(
      onPointerDown: (event) {
        if (PenCanvasController.onlyStylus) {
          if (event.kind == PointerDeviceKind.stylus) {
            multiCanvasController.addPoint(
              Point(event.localPosition, event.pressure, 0),
            );
          }
        } else {
          multiCanvasController.addPoint(
            Point(event.localPosition, event.pressure, 0),
          );
        }
      },

      onPointerMove: (event) {
        if (PenCanvasController.onlyStylus) {
          if (event.kind == PointerDeviceKind.stylus) {
            multiCanvasController.addPoint(
              Point(event.localPosition, event.pressure, 0),
            );
          }
        } else {
          multiCanvasController.addPoint(
            Point(event.localPosition, event.pressure, 0),
          );
        }
      },

      onPointerUp: (event) {
        if (PenCanvasController.onlyStylus) {
          if (event.kind == PointerDeviceKind.stylus) {
            multiCanvasController.addPoint(
              Point(event.localPosition, event.pressure, 0),
            );
            multiCanvasController.addBreak();
          }
        } else {
          multiCanvasController.addPoint(
            Point(event.localPosition, event.pressure, 0),
          );
          multiCanvasController.addBreak();
        }
        multiCanvasController.check();
      },

      child: MultiCanvas(tag: tag),
    );
  }
}
