import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'note.dart';

class NoteController extends GetxController {
  RxList<Widget> showList = <Widget>[].obs;
  int _totalNoteCount = 0; // 总笔记数量
  static const int _maxLineNoteCount = 7; // 每行最多显示的笔记数量
  static const double _spaceWidth = 64; // 笔记之间的间距
  static const double _spaceHeight = 20; // 笔记之间的间距

  final ScrollController scrollController = ScrollController();

  NoteController() {
    // 这里需要从磁盘中加载笔记数据 TODO
    debugPrint("warn: 这里需要从磁盘中加载笔记数据");
  }

  void _addNote() {} // 这里需要写添加笔记的后端 TODO
  void addNote(String name, String path) {
    if (_totalNoteCount == 0) {
      // 如果没有笔记，添加在第一行
      showList.add(
        Row(
          children: [
            SizedBox(width: _spaceWidth),
            NoteRect(noteName: name, notePicPath: path),
            SizedBox(width: _spaceWidth),
          ],
        ),
      );
    } else if (_totalNoteCount % _maxLineNoteCount == 0) {
      // 如果存在笔记，且添加新行
      showList.add(SizedBox(height: _spaceHeight));
      showList.add(
        Row(
          children: [
            SizedBox(width: _spaceWidth),
            NoteRect(noteName: name, notePicPath: path),
            SizedBox(width: _spaceWidth),
          ],
        ),
      );
    } else {
      // 如果存在笔记，且添加在当前行
      showList[showList.length - 1] = Row(
        children:
            (showList[showList.length - 1] as Row).children +
            [
              NoteRect(noteName: name, notePicPath: path),
              SizedBox(width: _spaceWidth),
            ],
      );
    }

    _totalNoteCount++;

    // 滚动到底部
    Future.delayed(Duration(milliseconds: 150), () {
      if (scrollController.hasClients) {
        final distance =
            scrollController.position.maxScrollExtent - scrollController.offset;

        // 计算时间：比如每 300 像素耗时 100 毫秒，最小 200ms，最大 1000ms
        final durationMs = distance.clamp(0, 1500).toInt() ~/ 3;
        final duration = Duration(milliseconds: durationMs.clamp(200, 1000));

        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: duration,
          curve: Curves.easeOutCubic,
        );
      }
    });
  }
}
