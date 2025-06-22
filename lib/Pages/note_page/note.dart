// 单一的笔记块，包含笔记的封面图片
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NoteRect extends StatelessWidget {
  static const double _noteWidth = 90; // 笔记宽度
  static const double _noteHeight = 127.26; // 笔记高度，该值必须为width的1.414倍（A4的长宽比例）
  static const double _radius = 8; // 圆角半径

  late final RxString _noteName; // 笔记名称
  late final RxString _notePicPath; // 笔记封面图片路径

  NoteRect({super.key, required String noteName, required String notePicPath})
    : _noteName = noteName.obs,
      _notePicPath = notePicPath.obs;

  String get noteName => _noteName.value;
  String get notePicPath => _notePicPath.value;
  set noteName(String name) => _noteName.value = name;
  set notePicPath(String path) => _notePicPath.value = path;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _noteWidth,
      height: _noteHeight + 80,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Container(
              width: _noteWidth,
              height: _noteHeight,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 115, 221, 235), // 背景颜色
                borderRadius: BorderRadius.circular(_radius), // 圆角半径
              ),
              child: Image.asset(notePicPath, fit: BoxFit.cover),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        noteName,
                        style: TextStyle(color: Colors.blue, fontSize: 14),
                        softWrap: true,
                        maxLines: 2, // 最大显示三行
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 5),
                IconButton(
                  onPressed: () {
                    print("aaa");
                  },
                  icon: Icon(
                    Icons.more_vert,
                    color: const Color.fromARGB(255, 201, 184, 23),
                    size: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
