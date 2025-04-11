import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'canvas.dart';

class Touch extends StatelessWidget {
  Touch({super.key});
  final controller = Get.find<CanvasController>(); // 获取控制器实例

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        debugPrint('Pointer down: ${event.localPosition}');
        if (controller.onlyStylus) {
          if (event.kind == PointerDeviceKind.stylus) {
            controller.addPoint(event.localPosition);
          }
        } else {
          controller.addPoint(event.localPosition);
        }
      },

      onPointerMove: (event) {
        debugPrint('Pointer move: ${event.localPosition}');
        if (controller.onlyStylus) {
          if (event.kind == PointerDeviceKind.stylus) {
            controller.addPoint(event.localPosition);
          }
        } else {
          controller.addPoint(event.localPosition);
        }
      },
      

      child: UserCanvas(),
    );
  }
}
