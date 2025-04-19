import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'pen.dart'; // 包含 Point 类定义

class PathOptimization {
  static const double _defaultEpsilon = .03;
  static const int _minOptimizedCount = 8;

  static Future<List<Point>> optimizePath(List<Point> pointList) async {
    final result = await compute(_optimizePathIsolate, {
      'points': pointList.map((p) => _pointToMap(p)).toList(),
      'epsilon': _defaultEpsilon,
    });

    return (result as List).map((m) => _mapToPoint(m)).toList();
  }

  /// isolate-safe 参数结构 + 返回值
  static List<Map<String, dynamic>> _optimizePathIsolate(
    Map<String, dynamic> data,
  ) {
    final List<Map<String, dynamic>> pointMaps =
        List<Map<String, dynamic>>.from(data['points']);
    final double epsilon = data['epsilon'];

    // 将 pointMaps 转为 List<Point>
    List<Point> points = pointMaps.map(_mapToPoint).toList();

    // 这里处理每一段路径
    List<Point> optimizedPoints = [];
    List<Point> currentPath = [];

    for (var point in points) {
      if (point == Point.nullPoint()) {
        // 遇到分隔符时，处理当前路径并清空
        if (currentPath.isNotEmpty) {
          optimizedPoints.addAll(
            _ramerDouglasPeuckerIterative(currentPath, epsilon),
          );
          currentPath.clear();
        }
        optimizedPoints.add(Point.nullPoint());
      } else {
        // 当前路径的点
        currentPath.add(point);
      }
    }

    // 处理最后一段路径
    if (currentPath.isNotEmpty) {
      optimizedPoints.addAll(
        _ramerDouglasPeuckerIterative(currentPath, epsilon),
      );
    }

    return optimizedPoints.map(_pointToMap).toList();
  }

  /// 非递归 RDP，返回优化后的新列表
  static List<Point> _ramerDouglasPeuckerIterative(
    List<Point> points,
    double epsilon,
  ) {
    if (points.length < _minOptimizedCount) return List.from(points);

    List<bool> keep = List.filled(points.length, false);
    keep[0] = true;
    keep[points.length - 1] = true;

    List<List<int>> stack = [
      [0, points.length - 1],
    ];

    while (stack.isNotEmpty) {
      final range = stack.removeLast();
      int start = range[0];
      int end = range[1];

      double maxDistance = 0.0;
      int index = 0;

      for (int i = start + 1; i < end; i++) {
        double distance = _perpendicularDistance(
          points[i].offset,
          points[start].offset,
          points[end].offset,
        );
        if (distance > maxDistance) {
          index = i;
          maxDistance = distance;
        }
      }

      if (maxDistance > epsilon) {
        keep[index] = true;
        stack.add([start, index]);
        stack.add([index, end]);
      }
    }

    // 返回新列表
    List<Point> optimized = [];
    for (int i = 0; i < points.length; i++) {
      if (keep[i]) {
        optimized.add(points[i]);
      }
    }
    
    return optimized;
  }

  /// 计算点到线段的垂直距离
  static double _perpendicularDistance(
    Offset point,
    Offset lineStart,
    Offset lineEnd,
  ) {
    double dx = lineEnd.dx - lineStart.dx;
    double dy = lineEnd.dy - lineStart.dy;

    if (dx == 0 && dy == 0) {
      return (point - lineStart).distance;
    }

    double t =
        ((point.dx - lineStart.dx) * dx + (point.dy - lineStart.dy) * dy) /
        (dx * dx + dy * dy);
    t = t.clamp(0.0, 1.0);

    Offset projection = Offset(lineStart.dx + t * dx, lineStart.dy + t * dy);

    return (point - projection).distance;
  }

  /// Point 转 Map
  static Map<String, dynamic> _pointToMap(Point p) => {
    'dx': p.offset.dx,
    'dy': p.offset.dy,
    'pressure': p.pressure,
    'speed': p.speed,
    'stamp': p.stamp,
  };

  /// Map 转 Point
  static Point _mapToPoint(Map<String, dynamic> m) {
    return Point(Offset(m['dx'], m['dy']), m['pressure'], m['speed']);
  }
}
