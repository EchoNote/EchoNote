import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'note.dart';  // 引入 NoteRect

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

  // 添加笔记
  void addNote(String name, String path) {
    final RxString noteName = name.obs;
    final noteKey = UniqueKey();  // 使用 UniqueKey

    // 计算当前最后一行笔记数量
    int lastLineNoteCount = 0;
    if (showList.isNotEmpty) {
      final lastRow = showList.last as Row;
      lastLineNoteCount = lastRow.children.whereType<NoteRect>().length;
    }

    // 只有在最后一行已满时才创建新行
    if (_totalNoteCount == 0 || lastLineNoteCount >= _maxLineNoteCount) {
      // 每行添加笔记时创建一个新的 Row
      showList.add(
        Row(
          key: UniqueKey(), // 为每行生成独立的Key
          children: [
            SizedBox(width: _spaceWidth),
            NoteRect(
              noteName: noteName,
              notePicPath: path,
              noteKey: noteKey,
              onDelete: () {
                deleteNote(noteKey);  // 删除笔记
              },
            ),
            SizedBox(width: _spaceWidth),
          ],
        ),
      );
      print("创建新行，当前行数: ${showList.length}");
    } else {
      // 如果当前行还没有满，就在上一行后继续添加笔记
      final lastRow = showList.last as Row;
      final newChildren = [
        ...lastRow.children,
        NoteRect(
          noteName: noteName,
          notePicPath: path,
          noteKey: noteKey,
          onDelete: () {
            deleteNote(noteKey);  // 删除笔记
          },
        ),
        SizedBox(width: _spaceWidth),
      ];
      
      showList[showList.length - 1] = Row(
        key: lastRow.key, // 保留原行的Key
        children: newChildren,
      );
      print("添加到现有行，当前行笔记数: ${newChildren.whereType<NoteRect>().length}");
    }

    _totalNoteCount++;

    // 滚动到底部
    Future.delayed(Duration(milliseconds: 150), () {
      if (scrollController.hasClients) {
        final distance = scrollController.position.maxScrollExtent - scrollController.offset;

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

  // 删除指定笔记 - 增强版：支持多行前移
  void deleteNote(Key noteKey) {
    print("删除笔记：$noteKey");

    bool isDeleted = false;
    int foundRowIndex = -1;
    int foundNoteIndex = -1;

    // 第一步：查找要删除的笔记位置
    for (int rowIndex = 0; rowIndex < showList.length; rowIndex++) {
      final row = showList[rowIndex] as Row;
      for (int childIndex = 0; childIndex < row.children.length; childIndex++) {
        final child = row.children[childIndex];
        
        // 检查子组件是否是NoteRect并且key匹配
        if (child is NoteRect && child.noteKey == noteKey) {
          foundRowIndex = rowIndex;
          foundNoteIndex = childIndex;
          isDeleted = true;
          print("找到笔记：$noteKey 在行 $rowIndex, 位置 $childIndex");
          break;
        }
      }
      if (isDeleted) break;
    }

    if (!isDeleted) {
      print("未找到笔记：$noteKey");
      return;
    }

    // 第二步：获取目标行并移除笔记
    final targetRow = showList[foundRowIndex] as Row;
    final newChildren = List<Widget>.from(targetRow.children);
    
    // 移除笔记及其后的间距（如果存在）
    if (foundNoteIndex < newChildren.length) {
      newChildren.removeAt(foundNoteIndex); // 删除笔记
      // 如果删除的是笔记，且后面跟着间距，也删除间距
      if (foundNoteIndex < newChildren.length && newChildren[foundNoteIndex] is SizedBox) {
        newChildren.removeAt(foundNoteIndex);
      }
    }

    // 第三步：处理行更新或删除
    if (newChildren.isEmpty) {
      // 如果行中没有其他元素，删除整行
      showList.removeAt(foundRowIndex);
      print("删除整行：$foundRowIndex");
    } else {
      // 重建行
      showList[foundRowIndex] = Row(
        key: targetRow.key,
        children: newChildren,
      );
      print("更新行：$foundRowIndex");
    }

    _totalNoteCount--;

    // 第四步：将后续所有行的笔记向前移动
    cascadeMoveNotes(foundRowIndex);

    // 打印当前行状态
    printCurrentRowStats();

    showList.refresh(); // 强制刷新UI
    print("成功删除笔记：$noteKey");
    print("剩余笔记数量：$_totalNoteCount");
  }

  // 级联移动笔记：从被删除行开始，将后续所有行的笔记向前移动
  void cascadeMoveNotes(int startRowIndex) {
    print("开始级联移动笔记，从行 $startRowIndex");
    
    // 从被删除行开始，逐行处理
    for (int rowIndex = startRowIndex; rowIndex < showList.length; rowIndex++) {
      // 如果当前行是最后一行，不需要移动
      if (rowIndex >= showList.length - 1) {
        print("到达最后一行，停止移动");
        break;
      }
      
      final currentRow = showList[rowIndex] as Row;
      final nextRow = showList[rowIndex + 1] as Row;
      
      final currentChildren = List<Widget>.from(currentRow.children);
      final nextChildren = List<Widget>.from(nextRow.children);
      
      // 计算当前行剩余空间（最多7个笔记）
      final currentNoteCount = currentChildren.whereType<NoteRect>().length;
      final spaceLeft = _maxLineNoteCount - currentNoteCount;
      
      // 如果当前行已满，跳过
      if (spaceLeft <= 0) {
        print("行 $rowIndex 已满 ($currentNoteCount/$_maxLineNoteCount)，跳过");
        continue;
      }
      
      print("行 $rowIndex 有 $spaceLeft 个空间可填充");
      
      // 从下一行移动笔记到当前行（最多移动spaceLeft个）
      int movedCount = 0;
      List<Widget> notesToMove = [];
      List<int> indicesToRemove = [];
      
      // 收集要移动的笔记（跳过间距）
      for (int i = 0; i < nextChildren.length && movedCount < spaceLeft; i++) {
        if (nextChildren[i] is NoteRect) {
          // 添加笔记
          notesToMove.add(nextChildren[i]);
          indicesToRemove.add(i);
          movedCount++;
          
          // 如果笔记后面有间距，也一起移动
          if (i + 1 < nextChildren.length && nextChildren[i + 1] is SizedBox) {
            notesToMove.add(nextChildren[i + 1]);
            indicesToRemove.add(i + 1);
            i++; // 跳过间距
          }
        }
      }
      
      // 如果没有可移动的笔记，跳过
      if (notesToMove.isEmpty) {
        print("下一行没有可移动的笔记");
        continue;
      }
      
      print("准备移动 $movedCount 个笔记从行 ${rowIndex + 1} 到行 $rowIndex");
      
      // 1. 添加到当前行
      // 确保当前行末尾有间距（如果当前行非空且添加的不是间距）
      if (currentChildren.isNotEmpty && 
          currentChildren.last is! SizedBox && 
          notesToMove.first is! SizedBox) {
        currentChildren.add(SizedBox(width: _spaceWidth));
      }
      
      currentChildren.addAll(notesToMove);
      
      // 2. 从下一行移除这些笔记（从后往前移除以避免索引问题）
      indicesToRemove.sort((a, b) => b.compareTo(a)); // 降序排序
      for (int index in indicesToRemove) {
        if (index < nextChildren.length) {
          nextChildren.removeAt(index);
        }
      }
      
      // 3. 更新当前行
      showList[rowIndex] = Row(
        key: currentRow.key,
        children: currentChildren,
      );
      
      // 4. 更新下一行
      if (nextChildren.isEmpty) {
        // 如果下一行已空，删除整行
        showList.removeAt(rowIndex + 1);
        print("删除空行：${rowIndex + 1}");
      } else {
        showList[rowIndex + 1] = Row(
          key: nextRow.key,
          children: nextChildren,
        );
        print("更新下一行：${rowIndex + 1}，剩余笔记: ${nextChildren.whereType<NoteRect>().length}");
      }
      
      print("成功移动 $movedCount 个笔记");
    }
  }

  // 打印当前行状态
  void printCurrentRowStats() {
    print("当前行状态 (共 ${showList.length} 行):");
    for (int i = 0; i < showList.length; i++) {
      final row = showList[i] as Row;
      final noteCount = row.children.whereType<NoteRect>().length;
      print("行 $i: $noteCount 个笔记");
    }
  }

  // 更新笔记名称
  void updateNoteName(RxString noteName, String newName) {
    noteName.value = newName;
  }
}