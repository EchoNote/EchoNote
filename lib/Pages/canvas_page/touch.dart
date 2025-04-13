import 'package:echo_note/Pages/canvas_page/multi_canvas.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'pen_canvas.dart';

class Touch extends StatelessWidget {
  const Touch({super.key});

  @override
  Widget build(BuildContext context) {
    var multiCanvasController = Get.put(MultiCanvasController());
    return Listener(
      onPointerDown: (event) {
        if (PenCanvasController.onlyStylus) {
          if (event.kind == PointerDeviceKind.stylus) {
            
            multiCanvasController.penCanvasController.addPoint(
              event.localPosition,
              event.pressure,
              0,
            );
          }
        } else {
          multiCanvasController.penCanvasController.addPoint(event.localPosition, event.pressure, 0);
        }
      },

      onPointerMove: (event) {
        if (PenCanvasController.onlyStylus) {
          if (event.kind == PointerDeviceKind.stylus) {
            multiCanvasController.penCanvasController.addPoint(
              event.localPosition,
              event.pressure,
              0,
            );
          }
        } else {
          multiCanvasController.penCanvasController.addPoint(event.localPosition, event.pressure, 0);
        }
      },

      onPointerUp: (event) {
        if (PenCanvasController.onlyStylus) {
          if (event.kind == PointerDeviceKind.stylus) {
            multiCanvasController.penCanvasController.addPoint(
              event.localPosition,
              event.pressure,
              0,
            );
            multiCanvasController.penCanvasController.addBreak();
          }
        } else {
          multiCanvasController.penCanvasController.addPoint(event.localPosition, event.pressure, 0);
          multiCanvasController.penCanvasController.addBreak();
        }
      },

      child: MultiCanvas(),
    );
  }
}
