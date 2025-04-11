import 'package:flutter/material.dart';

class EchoScrollBehavior extends MaterialScrollBehavior {
  
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(); // 在所有平台启用回弹
  }

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child; // 移除默认的蓝色“水波纹”效果
  }
}
