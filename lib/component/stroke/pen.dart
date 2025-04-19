import 'package:flutter/material.dart';

class Point {
  final Offset offset; // 点的坐标
  final double pressure; // 压力值
  final double speed; // 速度值（画笔速度越快，越细）
  final int stamp; // 时间戳
  Point(this.offset, this.pressure, this.speed)
    : stamp = DateTime.now().millisecondsSinceEpoch;

  /// 用于判断两个点是否“等价” —— 忽略 stamp，仅比较内容
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Point &&
        other.offset == offset &&
        other.pressure == pressure &&
        other.speed == speed;
  }

  @override
  int get hashCode => Object.hash(offset, pressure, speed);

  static nullPoint() {
    return Point(Offset(-1, -1), -1, -1);
  }
}

class Pen {
  final int id;
  final Color color;
  final double width;
  final double pressureSensitivity;
  final double speedSensitivity;

  /// 构造函数，id 默认为当前时间戳
  Pen(this.color, this.width, this.pressureSensitivity, this.speedSensitivity)
    : id = DateTime.now().millisecondsSinceEpoch;

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
  int get hashCode =>
      Object.hash(color, width, pressureSensitivity, speedSensitivity);

  /// 创建一个新 Pen，但复制当前数据（除 id）
  Pen copy() {
    return Pen(color, width, pressureSensitivity, speedSensitivity);
  }

  @override
  String toString() {
    return 'Pen(id: $id, color: $color, width: $width, pressureSensitivity: $pressureSensitivity, speedSensitivity: $speedSensitivity)';
  }

  static Pen genPen({
    Color color = Colors.blue,
    double width = 1,
    double pressureSensitivity = 5,
    double speedSensitivity = 0,
  }) {
    return Pen(color, width, pressureSensitivity, speedSensitivity);
  }
}
